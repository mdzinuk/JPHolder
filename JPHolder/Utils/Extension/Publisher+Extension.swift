//
//  Publisher+Extension.swift
//  JPHolder
//
//  Created by Mohammad Arafat Hossain on 9/03/21.
//

import Combine

/**
 System operator creates a feedback loop and bootstraps all dependencies during the VM intialization.
 - parameter initialState: system initialize state(.idle in out cases).
 - parameter reduce: reduce to single state upon receving state and event transition.
 - parameter feedback: feedback loops that produce events depending on the current system state.
 - returns: Always return current system
 */
extension Publishers {
    static func system<State, Event,
                       Scheduler: Combine.Scheduler>(initial: State, reduce: @escaping (State, Event) -> State,
                                                     scheduler: Scheduler,
                                                     feedbacks: [Feedback<State, Event>]) ->
    AnyPublisher<State, Never> {
        let stateSignal = CurrentValueSubject<State, Never>(initial)
        let eventsSignal = feedbacks.map { ($0.run(stateSignal.eraseToAnyPublisher()))}
        return Deferred {
            Publishers.MergeMany(eventsSignal)
                .receive(on: scheduler)
                .scan(initial, reduce)
                .handleEvents(receiveOutput: stateSignal.send)
                .receive(on: scheduler)
                .prepend(initial)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}

/**
 Feedback produces stream of events in response to state changes, allows side effects from moments an event been sent to when it reaches inside state reduction.
 */
struct Feedback<State, Event> {
    let run: (AnyPublisher<State, Never>) -> AnyPublisher<Event, Never>
    init<SideEffect: Publisher>(sideEffects: @escaping(State) -> SideEffect) where
        SideEffect.Output == Event, SideEffect.Failure == Never {
        self.run = { (state: (AnyPublisher<State, Never>)) -> AnyPublisher<Event, Never> in
            state.map { (s: State) in
                return sideEffects(s)
            }.switchToLatest()
            .eraseToAnyPublisher()
        }
    }
}
