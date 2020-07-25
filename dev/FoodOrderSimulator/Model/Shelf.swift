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
