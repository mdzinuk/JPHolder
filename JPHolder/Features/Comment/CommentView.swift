//
//  CommentView.swift
//  JPHolder
//
//  Created by Mohammad Arafat Hossain on 9/03/21.
//

import SwiftUI

/**
 CommentView: Depends on CommentViewModel, observed, triggered event. Based on stage changes view behaviours.
 */
struct CommentView: View {
    @ObservedObject var viewModel: CommentViewModel
    
    var body: some View {
        contentView
            .onAppear { self.viewModel.send(event: .onAppear) }
            .eraseToAnyView()
    }
    
    private var contentView: some View {
        switch viewModel.state {
        case .didFinishLoading(let comments):
            return List(comments) { comment in
                ItemRow(item: comment)
            }
            .navigationBarTitle("Comments", displayMode: .automatic)
            .eraseToAnyView()
        case .didFinishLoadingWithError(let error):
            return Text(error.description)
                .eraseToAnyView()
        default:
            return Spinner()
                .eraseToAnyView()
        }
    }
}

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentView(viewModel: CommentViewModel(-2))
    }
}
