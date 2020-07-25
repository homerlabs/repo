//
//  Shelf.swift
//  DeliveryOrders
//
//  Created by Matthew Homer on 7/6/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import Foundation

public class Shelf {
    public let capacity: Int
    public let decayModifier: Double
    public  var ordersDict: [String: Order] = [:]
    public  let type: TemperatureEnum
        
    //  attempt to add order to shelf
    //  returns the shelf where the order was added or nil
    public func addOrder(_ order: Order) -> Shelf? {
        if spaceAvailabe() {
            order.shelf = self
            order.time = Date() //  must be set here, not when JSON file read
      //      order.courier!.shelf = self
            ordersDict[order.id] = order
            return self
        }
        
        return nil
    }
    
    //  return true if successful
    //  does not disable the deliveryTimer
    public func moveOrder(_ order: Order, to shelf: Shelf) -> Bool {
        var success = false
        if let movedOrder = ordersDict[order.id] {
            movedOrder.courier?.cancel()
            ordersDict[movedOrder.id] = nil
            let spaceAvailable = shelf.spaceAvailabe()
            assert(spaceAvailable, ">>>>>>> moveOrder attempted but no space available \(movedOrder)")
            order.shelf = shelf
            shelf.ordersDict[order.id] = order
            success = true
        }
        
        return success
     }

    //  returns removed order if successful
    //  disables the deliveryTimer
    public func removeOrder(_ order: Order) -> Order? {
        let removedOrder = ordersDict[order.id]
        removedOrder?.courier?.cancel()
        ordersDict[order.id] = nil
        return removedOrder
     }

   //   returns true if an order can be added to the shelf
    public func spaceAvailabe() -> Bool {
        ordersDict.count < capacity
    }
    
    public init(type: TemperatureEnum, capacity: Int, decayModifier: Double) {
        self.type = type
        self.capacity = capacity
        self.decayModifier = decayModifier
    }
}

extension Shelf: CustomStringConvertible {
    public var description: String {
    "Shelf:\(type).\(ordersDict.count)"
    }
}
