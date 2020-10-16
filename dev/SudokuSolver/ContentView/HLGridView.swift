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

struct HLGridView<Content, T>: View where Content: View {

    var columns: Int
    var numberOfRows: Int {
        (items.count - 1) / columns
    }
    var items: [T]
    let content: (T) -> Content
    
    let scaleFactor: CGFloat = 0.75
    let overlayScaleFactor: CGFloat = 0.82

    init(columns: Int, items: [T],
            @ViewBuilder content: @escaping (T) -> Content) {
        self.columns = columns
        self.items = items
        self.content = content
    }
    
    func elementFor(row: Int, column: Int) -> Int? {
        let index = row * self.columns + column
        return index < items.count ? index : nil
    }
    
    var body: some View {
        GeometryReader { geometry in
            //  VStact ->  Spacer | 9x9 | Spacer
            //  vertical certering
            ZStack {
                VStack {
                    //       Spacer()

                    //  HStact ->  Spacer | 9x9 | Spacer
                    //  horzontal certering
                    HStack {
                        Spacer()
                        VStack {
                            ForEach(0...self.numberOfRows, id: \.self) { row in
                                HStack {
                                    ForEach(0..<self.columns, id: \.self) { column in
                                            Group {
                                            if self.elementFor(row: row, column: column) != nil {
                                                self.content(
                                                   self.items[self.elementFor(row: row, column: column)!])
                                                        .multilineTextAlignment(.center)
                                                        .frame(width: self.scaleFactor * geometry.size.width / CGFloat(self.columns),
                                                            height: self.scaleFactor * geometry.size.height / CGFloat(self.columns), alignment: .center)
                                                        .padding(2)
                                            } else {
                                                Spacer()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
               //     Spacer()
                }
                
                OverlayView(width: overlayScaleFactor*geometry.size.width/3.0, height: overlayScaleFactor*geometry.size.height/3.0).opacity(0.1)
            }
        }
    }
}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        let data = Array(Range(10001...10081))
        return HLGridView(columns: 9, items: data) { item in
            Text("\(item)")
        }
    }
}
