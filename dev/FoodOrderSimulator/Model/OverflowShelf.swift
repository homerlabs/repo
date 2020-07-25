//
//  OverflowShelf.swift
//  FoodOrderSimulator
//
//  Created by Matthew Homer on 7/25/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import Foundation

//  special Shelf class that can move an order back to its preferred shelf
public class OverflowShelf: Shelf {
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
}
