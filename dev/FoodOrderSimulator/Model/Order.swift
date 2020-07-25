//
//  Order.swift
//  DeliveryOrders
//
//  Created by Matthew Homer on 7/6/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import Foundation

public enum TemperatureEnum: String, Decodable {
    case hot
    case cold
    case frozen
    case any
}

public class Order: Decodable {
    let id: String
    let name: String
    let temp: TemperatureEnum
    var shelfLife: Double   //  will be updated if order gets moved to overflow shelf
    let decayRate: Double
    
    var time: Date
    var shelf: Shelf
    var courier: Courier?

    //  handle different name for temp in JSON
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case temp
        case shelfLife
        case decayRate
    }
    
    //  returns a range of [0.0-1.0], discard if value reaches 0
    public func calculateValue() -> Double {
        return max((shelfLife - decayRate * -time.timeIntervalSinceNow * shelf.decayModifier) / shelfLife, 0.0)
    }
    
    public init(id: String, name: String, temp: TemperatureEnum, shelfLife: Double, decayRate: Double) {
        time = Date()
        shelf = Shelf(type: .any, capacity: 0, decayModifier: 0)    // this will be updated when the order is placed
        self.id = id
        self.name = name
        self.temp = temp
        self.shelfLife = shelfLife
        self.decayRate = decayRate
    }

    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(String.self, forKey: .id)
        self.name = try values.decode(String.self, forKey: .name)
        self.temp = try values.decode(TemperatureEnum.self, forKey: .temp)
        self.shelfLife = try values.decode(Double.self, forKey: .shelfLife)
        self.decayRate = try values.decode(Double.self, forKey: .decayRate)
                
        time = Date()
        shelf = Shelf(type: .any, capacity: 0, decayModifier: 0)  //  this will be updated when the order is placed
    }
    
    deinit {
        courier?.cancel()
 //       print("deinit-  \(self)")
    }   
}

extension Order: CustomStringConvertible {
    public var description: String {
    "\(id)  \(name)  \(temp)  \(calculateValue().formatString(digits: 3))  \(shelf)"
    }
}
