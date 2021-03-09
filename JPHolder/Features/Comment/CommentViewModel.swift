//
//  CommentViewModel.swift
//  JPHolder
//
//  Created by Mohammad Arafat Hossain on 9/03/21.
//

import Foundation
import Combine
    
/**
 CommentViewModel: A reference type, will contain all business logic, update Views, manage state for dependencies.
 @property: state, remember current condition and published update if changes.
 @property: event, let it know for any view level changes
 @property: disposeBag, any cancellable to avoid memory issue.
 @method: send(:) trigger event from UI side
 @method: getposts(), retrieve available posts over Feedback<State, Event>
 @method: receiveUserEvent(:), receive UI event as Publisher and send back over Feedback<State, Event>
 */

final class CommentViewModel: ObservableObject {
    /// Properties
    @Published private(set) var state: State
    private let event = PassthroughSubject<Event, Never>()
    private var disposeBag = Set<AnyCancellable>()
    
    /// Lifecycles
    init(_ postId: Int) {
        self.state = .idle(postId)
        Publishers.system( initial: state, reduce: State.reduce, scheduler: RunLoop.main,
                           feedbacks: [
                            Self.getComments(),
                            Self.receiveUserEvent(input: event.eraseToAnyPublisher())
                           ])
            .assign(to: \.state, on: self)
            .store(in: &disposeBag)
    }
    
    deinit {
        disposeBag.removeAll()
    }
    
    /// Methods
    func send(event: Event) {
        self.event.send(event)
    }
    
    static func getComments() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case .loadingCommentFor(let pId) = state else { return Empty().eraseToAnyPublisher() }
            
            return Service.getCommentsFor(pId)
                .receive(on: DispatchQueue.main)
                .map ({ Event.onCommentLoadingSuccess($0) })
                .catch {( Just(Event.onCommentLoadingFailure($0)) )}
                .eraseToAnyPublisher()
        }
    }
    
    static func receiveUserEvent(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback { _ in input }
    }
}

/**
 States and Event are for uniques to PostViewModel, they don't need to know by other classes so keeping them Post feature only.
 */
extension CommentViewModel {
    enum State {
        case idle(Int)
        case loadingCommentFor(Int)
        case didFinishLoading([Post.Comment])
        case didFinishLoadingWithError(JPHError)
        
        static func reduce(_ state: State, _ event: Event) -> State {
            switch (state, event) {
            case (.idle(let postId), .onAppear):
                return .loadingCommentFor(postId)
            case (loadingCommentFor, .onCommentLoadingSuccess(let comment)):
                return .didFinishLoading(comment)
            case (loadingCommentFor, .onCommentLoadingFailure(let error)):
                return .didFinishLoadingWithError(error)
            default:
                return state
            }
        }
    }
    
    enum Event {
        case onAppear
        case onCommentLoadingSuccess([Post.Comment])
        case onCommentLoadingFailure(JPHError)
    }
}
