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
    
    @ObservedObject var newsViewModel = HLNewsViewModel()
    var body: some View {
        NavigationView {
            VStack {
                TextField(newsViewModel.searchString, text: $newsViewModel.searchString, onCommit: {
                    newsViewModel.fetchTopHeadlines()
                    print("newsViewModel.fetch")
                })

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
