//
//  FoodOrderSimulatorTests.swift
//  FoodOrderSimulatorTests
//
//  Created by Matthew Homer on 7/25/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import XCTest
@testable import FoodOrderSimulator

//  this test set will verify all 4 order operations: place, deliver, discard and move
class FoodOrderSimulatorTests: XCTestCase {

    let simulator = OrderSimulator()
    let expectationForDelivery = XCTestExpectation(description: "Wait for courier to 'pickup order'")
    let expectationForDiscard = XCTestExpectation(description: "Wait for courier to 'pickup order' with zero food value")
    let aLittleExtraTime = 1.0  //  give the test a little more time to wait for the deliveryTimer

    //  consume JSON data and place one order with its deliveryTimer disabled
    //  so that the shelfs are never fully empty to prevent the app from terminating
    override func setUp()  {
        simulator.simulatorSetup()
        if let order = simulator.placeOrder() {
            order.courier?.cancel()
        }

    }

    func testAddOrder() {
        let prePlacementCount = simulator.shelfManager.totalOrdersPlaced
        
        let order = simulator.placeOrder()
        XCTAssert(order != nil, "placeOrder failed to create an order")
  //      print("*************************    simulator: \(simulator.shelfManager)")
        
        XCTAssert(simulator.shelfManager.totalOrdersPlaced == prePlacementCount+1, "addOrder did not increment totalOrdersPlaced counter!")
    }

    //  place order and wait to its deliveryTimer to fire
    //  need to create new courier using self as delegate
    func testDeliverOrder() {
        let order = simulator.placeOrder()
        XCTAssert(order != nil, "placeOrder failed to create an order")
        
        replaceCourierInOrder(order!)
  
        let waitTime = order!.courier!.deliveryTime + aLittleExtraTime
        wait(for: [expectationForDelivery], timeout: waitTime)
    }

    //  place order with shelfLive near zero and wait for deliveryTimer to fire
    //  when timer fires, food value with be zero
    //  need to create new courier using self as delegate
    func testDiscardOrder() {
        let order = simulator.placeOrder()
        XCTAssert(order != nil, "placeOrder failed to create an order")
        
        order!.shelfLife = 0.1
        
        replaceCourierInOrder(order!)
        
        let waitTime = order!.courier!.deliveryTime + aLittleExtraTime
        wait(for: [expectationForDiscard], timeout: waitTime)
    }

    func testMoveOrder() {
        let order = simulator.orders.removeFirst()
        order.courier = Courier(order: order, deliveryTime: 1.0, delegate: simulator.shelfManager)
        let shelf = simulator.shelfManager.shelfOverflow.addOrder(order)
        XCTAssert(shelf != nil , "order was not added to shelf!")

        let moveToShelf = simulator.shelfManager.returnShelf(type: order.temp)
        let preMoveOverflowShelfCount = simulator.shelfManager.shelfOverflow.ordersDict.count
        let preMovePreferredShelfCount = moveToShelf.ordersDict.count
        
    //    print("*************************    pre  move simulator: \(simulator.shelfManager)")
        let success = simulator.shelfManager.shelfOverflow.moveOrder(order, to: moveToShelf)
    //    print("*************************    post move simulator: \(simulator.shelfManager)")
        
        let postMoveOverflowShelfCount = simulator.shelfManager.shelfOverflow.ordersDict.count
        let postMovePreferredShelfCount = moveToShelf.ordersDict.count
        
        XCTAssert(preMoveOverflowShelfCount == postMoveOverflowShelfCount+1, "moveOrder did not remove order from overflow shelf!")
        XCTAssert(preMovePreferredShelfCount+1 == postMovePreferredShelfCount, "moveOrder did not add order to preferred shelf!")
        XCTAssert(success, "moveOrder failed!")

    }
    
    func replaceCourierInOrder(_ order: Order) {
        //  replace courier with updated delegate
        let currentDeliveryTime = order.courier!.deliveryTime
        order.courier = Courier(order: order, deliveryTime: currentDeliveryTime, delegate: self)
    }
}

//  gets called by courier when courier 'arrives' to pick up order
extension FoodOrderSimulatorTests: OrderCompletation {
    public func deliverOrder(_ order: Order) {
    //    print("deliverOrder     *************************    simulator: \(simulator.shelfManager)")
        expectationForDelivery.fulfill()
    }
    
    public func discardOrder(_ order: Order) {
   //     print("discardOrder     *************************    simulator: \(simulator.shelfManager)")
        expectationForDiscard.fulfill()
    }
}
