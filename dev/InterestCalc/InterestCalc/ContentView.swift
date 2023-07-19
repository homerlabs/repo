//
//  ContentView.swift
//  InterestCalc
//
//  Created by Matthew Homer on 6/5/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
            .onAppear {
                let startingSum = 10_000.0
                let compoundsPerYear = 2.0
                let annualInterest = 0.09
                let interest = annualInterest / compoundsPerYear
                let numberOfYears = 20
                
                var runningSum = startingSum
                var totalValue = 0.0
                
                let interestString = String(format: "%.2f", annualInterest*100)
                print("InterestCalc.app using \(interestString) interest rate")
                for index in 1...Int(compoundsPerYear)*numberOfYears {
                    let interestSum = runningSum * interest
                    runningSum += interestSum
                    if index % Int(compoundsPerYear) == 0 {
                        totalValue += runningSum
                        print("\(index/Int(compoundsPerYear))  YearlyProfit: \(Int(runningSum-startingSum))  TotalValue: \(Int(totalValue))")
                    }
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
