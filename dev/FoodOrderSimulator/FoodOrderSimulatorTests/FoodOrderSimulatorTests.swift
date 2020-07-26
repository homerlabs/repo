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
//    let expectationForDiscardOrderWithZeroFoodValue = XCTestExpectation(description: "Wait for food value to reach zero'")

    override func setUp()  {
        simulator.simulatorSetup()
    }

    func testAddOrder() {
        let order = simulator.orders.removeFirst()
        let prePlacementCount = simulator.shelfManager.totalOrdersPlaced
        simulator.shelfManager.addOrder(order)
        print("*************************    simulator: \(simulator.shelfManager)")
        print("*************************    simulator: \(simulator)   order.shelf: \(order.shelf)")
        
        XCTAssert(simulator.shelfManager.totalOrdersPlaced == prePlacementCount+1, "addOrder did not increment totalOrdersPlaced counter!")
    }

    //  place first order from data array and call shelfManager.addOrder(order)
    //  check that shelfManager.totalOrdersPlaced is incremented by one
    //  note:  need to place 2 orders before removing 1 to prevent activeOrders() becoming zero
    //  also need to disable deliveryTimer in courier
    func testDeliverOrder() {
        let prePlacementCount = simulator.shelfManager.totalOrdersPlaced
        let order1 = simulator.orders.removeFirst()
        simulator.shelfManager.addOrder(order1)
        order1.courier?.cancel()
        let order2 = simulator.orders.removeFirst()
        simulator.shelfManager.addOrder(order2)
        order2.courier?.cancel()
 //       print("*************************    simulator: \(simulator.shelfManager)")
       XCTAssert(simulator.shelfManager.totalOrdersPlaced == prePlacementCount+2, "addOrder did not increment totalOrdersPlaced counter!")
  
        let waitTime = order2.courier!.deliveryTime + 2.0
        wait(for: [expectationForDelivery], timeout: waitTime)

/*        let preDeliveryCount = simulator.shelfManager.totalOrdersDelivered
        simulator.shelfManager.deliverOrder(order1)
//        print("*************************    simulator: \(simulator.shelfManager)")
        XCTAssert(simulator.shelfManager.totalOrdersDelivered == preDeliveryCount+1, "deliveryOrder did not increment totalOrdersDelivered counter!")*/
    }

    //  place first order from data array and call shelfManager.addOrder(order)
    //  check that shelfManager.totalOrdersPlaced is incremented by one
    //  note:  need to place 2 orders before removing 1 to prevent activeOrders() becoming zero
    //  also need to disable deliveryTimer in courier
    func testDiscardOrder() {
        let prePlacementCount = simulator.shelfManager.totalOrdersPlaced
        let order1 = simulator.orders.removeFirst()
        simulator.shelfManager.addOrder(order1)
        order1.courier?.cancel()
        let order2 = simulator.orders.removeFirst()
        simulator.shelfManager.addOrder(order2)
        order2.courier?.cancel()
  //      print("*************************    simulator: \(simulator.shelfManager)")
        XCTAssert(simulator.shelfManager.totalOrdersPlaced == prePlacementCount+2, "addOrder did not increment totalOrdersPlaced counter!")
  
  
        let preDiscardCount = simulator.shelfManager.totalOrdersDiscarded
        simulator.shelfManager.discardOrder(order1)
//        print("*************************    simulator: \(simulator.shelfManager)")
        XCTAssert(simulator.shelfManager.totalOrdersDiscarded == preDiscardCount+1, "discaredOrder did not increment totalOrdersDiscarded counter!")
    }

    func testMoveOrder() {
        let order = simulator.orders.removeFirst()
        order.courier = Courier(order: order, deliveryTime: 1.0, delegate: simulator.shelfManager)
        let shelf = simulator.shelfManager.shelfOverflow.addOrder(order)
        XCTAssert(shelf != nil , "order was not added to shelf!")
        let moveToShelf = simulator.shelfManager.returnShelf(type: order.temp)
  //      print("*************************    simulator: \(simulator.shelfManager)")
        let success = simulator.shelfManager.shelfOverflow.moveOrder(order, to: moveToShelf)
   //     print("*************************    simulator: \(simulator.shelfManager)")
        XCTAssert(success, "moveOrder did not succeed!")

    }
}

//  gets called by courier when courier 'arrives' to pick up order
extension FoodOrderSimulatorTests: OrderCompletation {
    public func deliverOrder(_ order: Order) {
    //    print("deliverOrder     *************************    simulator: \(simulator.shelfManager)")
        expectationForDelivery.fulfill()
    }
    
    public func discardOrder(_ order: Order) {
        print("discardOrder     *************************    simulator: \(simulator.shelfManager)")
  //      expectationForDiscardOrderWithZeroFoodValue.fulfill()
    }
}
