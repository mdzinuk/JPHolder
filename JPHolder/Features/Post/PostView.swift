//
//  PostView.swift
//  JPHolder
//
//  Created by Mohammad Arafat Hossain on 9/03/21.
//

import SwiftUI

/**
 PostView: Depends on PostViewModel, observed, triggered event. Based on stage changes view behaviours.
 */
struct PostView: View {
    @ObservedObject var viewModel: PostViewModel
    
    var body: some View {
        contentView
            .onAppear { self.viewModel.send(event: .onAppear) }
            .eraseToAnyView()
    }
    
    private var contentView: some View {
        switch viewModel.state {
        case .didFinishWithPost(let posts):
            return NavigationView {
                List(posts) { post in
                    NavigationLink(destination: CommentView(viewModel: CommentViewModel(post.counter))) {
                        ItemRow(item: post)
                    }
                }
                .navigationBarTitle(Text("Posts"))
                .navigationViewStyle(DoubleColumnNavigationViewStyle())
            }
            .eraseToAnyView()
        case .didFinishWithError(let error):
            return Text(error.description)
                .eraseToAnyView()
        default:
            return Spinner()
                .eraseToAnyView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(viewModel: PostViewModel())
    }
}
