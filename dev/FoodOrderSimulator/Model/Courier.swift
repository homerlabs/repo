//
//  Courier.swift
//  DeliveryOrders
//
//  Created by Matthew Homer on 7/8/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import Foundation

public class Courier {
    public let deliveryTime: Double
    public unowned let order: Order
    public var deliveryTimer: Timer?
    internal weak var delegate: OrderCompletation?
    
    //  don't want the timer to fire if order is discarded
    public func cancel() {
        deliveryTimer?.invalidate()
    }
    
    public init(order: Order, deliveryTime: Double, delegate: OrderCompletation) {
  //      print("init: \(order) \(deliveryTime.formatString(digits: 1))  delegate: \(delegate)")
        self.order = order
        self.deliveryTime = deliveryTime
        self.delegate = delegate
        
        //  when timer fires, order will be checked for foodValue > 0, then 'delivered'
        //  else the order will be 'discarded'
        deliveryTimer = Timer.scheduledTimer(withTimeInterval: deliveryTime, repeats: false) { _ in
            let foodValue = order.calculateValue()
            if foodValue > 0 {
                delegate.deliverOrder(order)
            }
            
            //  don't deliver if foodValue is 0
            else {
                delegate.discardOrder(order)
            }
        }
    }
    
    deinit {
        deliveryTimer?.invalidate()
    //    print("Courier-  deinit") //  just making sure no memory leak
    }
}

extension Courier: CustomStringConvertible {
    public var description: String {
    return "orderId: \(order.id)  deliveryTime: " + deliveryTime.formatString(digits: 1)
    }
}
