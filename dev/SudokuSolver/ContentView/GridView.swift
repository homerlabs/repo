/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct GridView<Content, T>: View where Content: View {
  var columns: Int
  var items: [T]
  let content: (T) -> Content
  let scaleFactor: CGFloat = 0.8
    let overlayScaleFactorX: CGFloat = 0.85
    let overlayScaleFactorY: CGFloat = 0.85

  init(columns: Int, items: [T],
       @ViewBuilder content: @escaping (T) -> Content) {
    self.columns = columns
    self.items = items
    self.content = content
  }
  
  var numberRows: Int {
    guard  items.count > 0 else {
      return 0
    }
    
    return items.count / columns
  }
  
  func elementFor(row: Int, column: Int) -> Int? {
    let index = row * self.columns + column
    return index < items.count ? index : nil
  }
  
    var body: some View {
        GeometryReader { geometry in
            ZStack {
            VStack {
                Spacer()
                ForEach(0..<self.numberRows) { row in
                    HStack {
                        Spacer()
                        ForEach(0..<self.columns) { column in
                            self.content(self.items[self.elementFor(row: row, column: column)!])
                                .multilineTextAlignment(.center)
                                .padding(5)
                                .frame(width: scaleFactor*geometry.size.width / CGFloat(self.columns),
                                       height: scaleFactor*geometry.size.width / CGFloat(self.columns))
                        }
                        Spacer()
                    }
                }
                Spacer()
                }
                OverlayView(width: overlayScaleFactorX*geometry.size.width/3.0, height: overlayScaleFactorY*geometry.size.height/3.0).opacity(0.1)
            }
            }
        }
    }

struct GridView_Previews: PreviewProvider {
  static var previews: some View {
    let data = Array(Range(10001...10081))
    GridView(columns: 9, items: data) { item in
      Text("\(item)")
    }
  }
}
