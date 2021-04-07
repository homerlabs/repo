//
//  ContentView.swift
//  HLNews
//
//  Created by Matthew Homer on 3/20/21.
//

import SwiftUI
//  https://newsapi.org/docs
//  http://www.mypet.com/img/basic-pet-care/how-long-leave-cat-alone-lead.jpg

struct ContentView: View {
    let searchBackgroundColor = Color(red: 0.1, green: 0.3, blue: 0.4, opacity: 0.3)
    
    @ObservedObject var newsViewModel = HLNewsViewModel()
    var body: some View {
        NavigationView {
            VStack {
                HStack(alignment: .center) {
                    Text("Search: ")
                    TextField(newsViewModel.searchString, text: $newsViewModel.searchString, onCommit: {
                        if newsViewModel.searchString.count > 0 {
                            newsViewModel.fetchSearch(newsViewModel.searchString)
                        }
                        else {
                            newsViewModel.fetchTopHeadlines()
                        }
                        print("newsViewModel.fetch")
                    })
                    .background(searchBackgroundColor)
                }

                List(newsViewModel.articles, id: \.url) { article in
                    ArticleRowView(article: article)
                }
            }
            .navigationBarTitle("Top Stories", displayMode: .inline)
           }
            .onAppear {
                print("onAppear")
                newsViewModel.fetchTopHeadlines()
        }
        .navigationViewStyle(StackNavigationViewStyle())
   //     .padding([.top, .trailing])
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
