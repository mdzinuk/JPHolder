//
//  PostViewModel.swift
//  JPHolder
//
//  Created by Mohammad Arafat Hossain on 9/03/21.
//

import Combine
import SwiftUI

/**
 PostViewModel: A reference type, will contain all business logic, update Views, manage state for dependencies.
 @property: state, remember current condition and published update if changes.
 @property: event, let it know for any view level changes
 @property: disposeBag, any cancellable to avoid memory issue.
 @method: send(:) trigger event from UI side
 @method: getposts(), retrieve available posts over Feedback<State, Event>
 @method: receiveUserEvent(:), receive UI event as Publisher and send back over Feedback<State, Event>
 */

final class PostViewModel: ObservableObject {
    /// Properties
    @Published private(set) var state = State.idle
    private let event = PassthroughSubject<Event, Never>()
    private var disposeBag = Set<AnyCancellable>()
    
    /// Lifecycles
    init() {
        Publishers.system( initial: state, reduce: State.reduce, scheduler: RunLoop.main,
                           feedbacks: [
                            Self.getPosts(),
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
    
    static func getPosts() -> Feedback<State, Event> {
        Feedback { (state: State) -> AnyPublisher<Event, Never> in
            guard case .loading = state else {
                return Empty().eraseToAnyPublisher()
            }
            return Service.getAvailablePosts()
                .map { Event.onPostLoadedSuccess($0)}
                .catch { Just(Event.onPostLoadedError($0))}
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
extension PostViewModel {
    enum State {
        case idle
        case loading
        case didFinishWithPost([Post])
        case didFinishWithError(JPHError)
        
        static func reduce(_ state: State, _ event: Event) -> State {
            switch (state, event) {
            case (.idle, .onAppear):
                return .loading
            case (loading, .onPostLoadedSuccess(let posts)):
                return .didFinishWithPost(posts)
            case (loading, .onPostLoadedError(let error)):
                return .didFinishWithError(error)
            default:
                return state
            }
        }
    }
    
    enum Event {
        case onAppear
        case onPostLoadedSuccess([Post])
        case onPostLoadedError(JPHError)
    }
}
