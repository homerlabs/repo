//
//  Double+Extension.swift
//  DeliveryOrders
//
//  Created by Matthew Homer on 7/10/20.
//  Copyright © 2020 Matthew Homer. All rights reserved.
//

import Foundation

extension Double {

    public func formatString(digits: Int) -> String {
        String.init(format: "%.\(digits)f", self)
    }
}
