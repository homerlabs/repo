//
//  ShelfManager.swift
//  ShelfManager
//
//  Created by Matthew Homer on 7/8/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import Foundation
import Cocoa

public protocol OrderCompletation: class {
    func deliverOrder(_ order: Order)
    func discardOrder(_ order: Order)
}

public class ShelfManager {
    let deliveryTimeRange = 2.0...6.0
    
    let shelfHotCapacity = 10
    let shelfColdCapacity = 10
    let shelfFrozenCapacity = 10
    let shelfOverflowCapacity = 15

    internal var shelfHot: Shelf
    internal var shelfCold: Shelf
    internal var shelfFrozen: Shelf
    internal var shelfOverflow: OverflowShelf
    
    public var totalOrdersPlaced = 0
    public var totalOrdersDelivered = 0
    public var totalOrdersDiscarded = 0
    public var totalOrdersMoved = 0
        
    private let semaphore = DispatchSemaphore(value: 1)
    public var verboseDebug = false

    public func addOrder(_ order: Order) {
        var shelf: Shelf? = returnShelf(type: order.temp)
        order.time = Date()
        let deliveryTime = Double.random(in: deliveryTimeRange)
        order.courier = Courier(order: order, deliveryTime: deliveryTime, delegate: self)
        
        semaphore.wait()
            shelf = shelf!.addOrder(order)
        semaphore.signal()
        
       //  check if we are done
        if  shelf == nil {
            makeRoomOnOverFlowShelf()
            
            let spaceAvailable = shelfOverflow.spaceAvailabe()
            if !spaceAvailable {
                printStateVerbose()
                assert(false)
            }
            
            semaphore.wait()
                //  this will always succeed
                shelf = shelfOverflow.addOrder(order)
            semaphore.signal()
        }
        
        order.shelf = shelf!
        totalOrdersPlaced += 1
        print("place  :\(totalOrdersPlaced)\t\(order)")
    }
    //  search for a 'movable' order and if found, move it to it's preferred shelf
    //  if none are found, discard random order on overflow shelf
    //  one way or the other, will always succeed in making room for the new order
    private func makeRoomOnOverFlowShelf() {
        //  nothing to do if space available
        guard !shelfOverflow.spaceAvailabe() else { return }
        
        //  look for a 'movable' order and if one is found, move it to it's preferred shelf
        //  a 'movable' order is an order whose preferred shelf has space for at least one
        for (_, order) in shelfOverflow.ordersDict {
            let preferredShelf: Shelf = returnShelf(type: order.temp)
            
            if preferredShelf.spaceAvailabe() {
                let moveSucceeded = shelfOverflow.moveOrder(order, to: returnShelf(type: order.temp))
              
                if moveSucceeded {
                    totalOrdersMoved += 1
                    print("move   :\(totalOrdersMoved)\t\(order)")
                    
                    //  adjust shelfLife for time spent of overflow shelf
                    order.shelfLife *= order.calculateValue()
                    
                    //  reset start time
                    order.time = Date()
                    
                    //  reset deliveryTime with adjusted time
                    let time = order.courier!.deliveryTime
                    let newTime = time + order.time.timeIntervalSinceNow
                    order.courier = Courier(order: order, deliveryTime: newTime, delegate: self)
                }
                
                //  found an order that was movable and moved it off the overflow shelf
                return
            }
        }
        
       //  as the last resort, discard random order on overflow shelf to make room for new order
        if let (_, order) = shelfOverflow.ordersDict.randomElement() {
            discardOrder(order)    //  OrderCompletation protocol
        }
    }
        
    //  for a given temperature, return the appropriate shelf
    internal func returnShelf(type: TemperatureEnum) -> Shelf {
        switch type {
            case .hot:      return shelfHot
            case .cold:     return shelfCold
            case .frozen:   return shelfFrozen
            case .any:      return shelfOverflow
        }
    }
    
    public func printStateVerbose() {
        print("\(self)")
 //       print("shelfHot: \(shelfHot.ordersDict)  \nshelfCold: \(shelfCold.ordersDict)  \nshelfFrozen: \(shelfFrozen.ordersDict)  \nshelfOverflow: \(shelfOverflow.ordersDict)")
    }
   
    public init() {
        shelfHot = Shelf(type: .hot, capacity: shelfHotCapacity, decayModifier: 1)
        shelfCold = Shelf(type: .cold, capacity: shelfColdCapacity, decayModifier: 1)
        shelfFrozen = Shelf(type: .frozen, capacity: shelfFrozenCapacity, decayModifier: 1)
        shelfOverflow = OverflowShelf(type: .any, capacity: shelfOverflowCapacity, decayModifier: 2)
    }
}

extension ShelfManager: CustomStringConvertible {
    public var description: String {
    "\tHot:\(shelfHot.ordersDict.count)  Cold:\(shelfCold.ordersDict.count)  Frozen:\(shelfFrozen.ordersDict.count)  Overflow:\(shelfOverflow.ordersDict.count)" +
    " \tPlaced:\(totalOrdersPlaced) \tDelivered:\(totalOrdersDelivered) \tDiscarded:\(totalOrdersDiscarded) \tMoved:\(totalOrdersMoved)"
    }
}

//  there are 2 ways an order is 'completed'
//  the order is either delivered or discarded
//  this can happen when the courier deliveryTimer fires or if the overflow shelf does a random discard
extension ShelfManager: OrderCompletation {

    //  gets called by courier when courier deliveryTimer fires
    //  checks if simulation is done and if so, terminates simulation
    public func deliverOrder(_ order: Order) {
        semaphore.wait()
            totalOrdersDelivered += 1
            if verboseDebug {
                printStateVerbose()
            }
            if let removedOrder = order.shelf.removeOrder(order) {
                print("deliver:\(totalOrdersDelivered)\t\(removedOrder)")
            }
            else {
                print("deliver order:\(totalOrdersDelivered) \(order) from shelf: \(order.shelf) NOT FOUND!!")
                printStateVerbose()
                assert(false, "\(order.shelf).removeOrder: \(order) failed!")
            }
        semaphore.signal()

        if activeOrders() == 0 {
            simulationCompleted()
        }
    }
    
    //  using orderOperationQueue, remove order from shelf and update totalOrdersDiscarded
    //  checks if simulation is done and if so, terminates simulation
    public func discardOrder(_ order: Order) {
        semaphore.wait()
            totalOrdersDiscarded += 1
            if verboseDebug {
                printStateVerbose()
            }
            let removedOrder = order.shelf.removeOrder(order)
            if removedOrder != nil {
                print("discarded:\(totalOrdersDiscarded)\t\(order)")
            }
            else {
                print("****  discarded order:\(totalOrdersDiscarded) \(order) from: \(order.shelf) NOT FOUND!!")
                printStateVerbose()
                assert(false, "\(order.shelf).removeOrder: \(order) failed!")
            }
        semaphore.signal()
        
        if activeOrders() == 0 {
            simulationCompleted()
        }
    }
    
    private func activeOrders() -> Int {
        totalOrdersPlaced - (totalOrdersDelivered + totalOrdersDiscarded)
    }
    
    private func simulationCompleted() {
        print("\nFood Order Simulation Completed.")
        print(self)
        
        NSApp.terminate(self)    //  spec said to terminate when completed
    }
}
