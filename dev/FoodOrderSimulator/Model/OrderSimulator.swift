//
//  OrderSimulator.swift
//  DeliveryOrders
//
//  Created by Matthew Homer on 7/6/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import Foundation

public class OrderSimulator {
    let orderCreationRate = 0.5 //  2 per second
    
    public var orders: [Order] = []
    public var shelfManager = ShelfManager()
    private var placeOrderTimer: Timer?
    
    public func simulatorSetup() {
        //  load order data (Bundle resource: JSON file)
        do {
            var ordersURL = Bundle.main.url(forResource: "orders", withExtension: "json")
            var runningXCTests = false
            
            //  handle test bundle vs main bundle for JSON resource
            //  this is a good spot to determine if we are running XCTests
            if ordersURL == nil {
                runningXCTests = true
                let testBundle = Bundle(for: type(of: self))
                ordersURL = testBundle.url(forResource: "orders", withExtension: "json")
            }
            let data = try Data(contentsOf: ordersURL!)
            
            let decoder = JSONDecoder()
            orders = try! decoder.decode([Order].self, from: data)

            if !runningXCTests {
                placeOrderTimer = Timer.scheduledTimer(withTimeInterval: orderCreationRate, repeats: true) { _ in
                    self.placeOrder()
                }
            }
        }
        catch {
            print("try Data failed!!")
        }
    }
    
    public func printSimulatorState() {
        print("shelfManager: \(shelfManager)\n")
    }
    
    public func placeOrder() {
        //  if out of data, invalidate placeOrderTimer
        guard !orders.isEmpty else {
            placeOrderTimer?.invalidate()
            print("\nFood Order Simulation has consumed all input data.")
            printSimulatorState()
            return
        }
        
        let order = orders.removeFirst()
        shelfManager.addOrder(order)
    }
}
