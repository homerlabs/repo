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
        VStack {
            TextField(newsViewModel.searchString, text: $newsViewModel.searchString, onCommit: {
                newsViewModel.fetchTopHeadlines()
                print("newsViewModel.fetch")
            })

         //   NavigationView {
                
                ScrollView {
              /*      List(newsViewModel.articles, id: \.url) { article in
                    ArticleRowView(article: article)
                    }*/
                    
                    ForEach(newsViewModel.articles, id: \.url) { article in
                        ArticleRowView(article: article)
                    }
         //       }
       //     .scaledToFill()
       //    .navigationBarTitle("HLNews")
            }
        }.onAppear {
            print("onAppear")
            newsViewModel.fetchTopHeadlines()
        }
   //     .padding([.top, .trailing])
        
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
