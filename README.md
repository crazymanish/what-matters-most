## Combine framework
--------------------------------------------

#### Books

- [x] Combine: Asynchronous Programming with Swift
    - [x] Book: https://www.kodeco.com/books/combine-asynchronous-programming-with-swift
    - [x] GitHub: https://github.com/kodecocodes/comb-materials
- [x] Practical Combine
    - [x] Book: https://donnywals.gumroad.com/l/practical-combine
- [x] WWDC
    - [x] Introducing Combine: https://www.wwdcnotes.com/notes/wwdc19/722/
    - [x] Combine in Practice: https://www.wwdcnotes.com/notes/wwdc19/721/
    - [x] Advances in Networking, Part 1: https://www.wwdcnotes.com/notes/wwdc19/712/
    - [x] Advances in Networking, Part 2: https://www.wwdcnotes.com/notes/wwdc19/713/
    - [x] GitHub: https://github.com/WWDCNotes/Content 
    
-------------------------------------------
#### Section1: Introduction

- [x] Publisher
    - [x] Read about publisher https://github.com/crazymanish/what-matters-most/pull/58
    - [x] Built-in publishers 
      - `Just` https://github.com/crazymanish/what-matters-most/pull/59, `Future` https://github.com/crazymanish/what-matters-most/pull/60  
      - `Empty` https://github.com/crazymanish/what-matters-most/pull/61, `Fail` https://github.com/crazymanish/what-matters-most/pull/62
      - `Deferred` https://github.com/crazymanish/what-matters-most/pull/63
      - `Record` https://github.com/crazymanish/what-matters-most/pull/64
    - [x] Custom publisher 
      - `DefaultValue` https://github.com/crazymanish/what-matters-most/pull/65
      - `DefaultError` https://github.com/crazymanish/what-matters-most/pull/66
    - [x] Practices 
      - `NotificationCenter` https://github.com/crazymanish/what-matters-most/pull/67
      - `URLSession` https://github.com/crazymanish/what-matters-most/pull/68
      - `UserDefaults` https://github.com/crazymanish/what-matters-most/pull/69
      - `JSON parsing` https://github.com/crazymanish/what-matters-most/pull/70
      - `assign(to:on:)` https://github.com/crazymanish/what-matters-most/pull/71
- [x] Subscriber
    - [x] Read about subscriber https://github.com/crazymanish/what-matters-most/pull/72
    - [x] Built-in subscribers
      - `sink(receiveCompletion:receiveValue:)` https://github.com/crazymanish/what-matters-most/pull/59
      - `assign(to:on:)` https://github.com/crazymanish/what-matters-most/pull/71
    - [x] Custom subscribers 
      - `IntSubscriber` https://github.com/crazymanish/what-matters-most/pull/74
    - [x] Practices
      - `sink(receiveCompletion:receiveValue:)` https://github.com/crazymanish/what-matters-most/pull/59
      - `assign(to:on:)` https://github.com/crazymanish/what-matters-most/pull/71
      - `IntSubscriber` https://github.com/crazymanish/what-matters-most/pull/74
- [x] Subject (Publisher & Subscriber)
    - [x] Read about subject https://github.com/crazymanish/what-matters-most/pull/75
    - [x] Built-in subjects
      - `PassthroughSubject` https://github.com/crazymanish/what-matters-most/pull/76
      - `CurrentValueSubject` https://github.com/crazymanish/what-matters-most/pull/77
    - [x] Custom subjects? https://github.com/crazymanish/what-matters-most/pull/76, https://github.com/crazymanish/what-matters-most/pull/77
    - [x] Practices https://github.com/crazymanish/what-matters-most/pull/76, https://github.com/crazymanish/what-matters-most/pull/77
  
  ------------------------------------------
  
#### Section2: Operators

- [x] Transforming Operators
    - [x] Collecting values https://github.com/crazymanish/what-matters-most/pull/78
    - [x] Mapping values
      - `map value` https://github.com/crazymanish/what-matters-most/pull/79
      - `map keypath value` https://github.com/crazymanish/what-matters-most/pull/80
      - `tryMap value` https://github.com/crazymanish/what-matters-most/pull/81
    - [x] Flattening publishers https://github.com/crazymanish/what-matters-most/pull/82
    - [x] Replacing/transforming upstream output
      - `replaceNil(with:)` https://github.com/crazymanish/what-matters-most/pull/83
      - `replaceEmpty(with:)` https://github.com/crazymanish/what-matters-most/pull/84
      - `scan(initialResult, with:)` https://github.com/crazymanish/what-matters-most/pull/85
    - [x] Practices https://github.com/crazymanish/what-matters-most/pull/78, https://github.com/crazymanish/what-matters-most/pull/79, https://github.com/crazymanish/what-matters-most/pull/80, https://github.com/crazymanish/what-matters-most/pull/81, https://github.com/crazymanish/what-matters-most/pull/82, https://github.com/crazymanish/what-matters-most/pull/83, https://github.com/crazymanish/what-matters-most/pull/84, https://github.com/crazymanish/what-matters-most/pull/85
- [x] Filtering Operators
    - [x] Compacting and ignoring
      - `filter(_:) tryFilter(_:)` https://github.com/crazymanish/what-matters-most/pull/87
      - `removeDuplicates(by:) tryRemoveDuplicates(by:)` https://github.com/crazymanish/what-matters-most/pull/88
      - `compactMap(_:) tryCompactMap(_:)` https://github.com/crazymanish/what-matters-most/pull/89
      - `ignoreOutput()` https://github.com/crazymanish/what-matters-most/pull/90
    - [x] Finding values
      - `first() first(where:) tryFirst(where:)` https://github.com/crazymanish/what-matters-most/pull/91
      - `last() last(where:) tryLast(where:)` https://github.com/crazymanish/what-matters-most/pull/91
    - [x] Droping values
      - `dropFirst(_:)` https://github.com/crazymanish/what-matters-most/pull/92
      - `drop(while:) tryDrop(while:)` https://github.com/crazymanish/what-matters-most/pull/92
      - `drop(untilOutputFrom:)` https://github.com/crazymanish/what-matters-most/pull/92
    - [x] Limiting values
      - `prefix(_:)` https://github.com/crazymanish/what-matters-most/pull/93
      - `prefix(while:) tryPrefix(while:)` https://github.com/crazymanish/what-matters-most/pull/93
      - `prefix(untilOutputFrom:)` https://github.com/crazymanish/what-matters-most/pull/93
    - [x] Practices https://github.com/crazymanish/what-matters-most/pull/87, https://github.com/crazymanish/what-matters-most/pull/88, https://github.com/crazymanish/what-matters-most/pull/89, https://github.com/crazymanish/what-matters-most/pull/90, https://github.com/crazymanish/what-matters-most/pull/91, https://github.com/crazymanish/what-matters-most/pull/92, https://github.com/crazymanish/what-matters-most/pull/93, https://github.com/crazymanish/what-matters-most/pull/94
- [x] Combining Operators
    - [x] Combining
      - `prepend(_:)` https://github.com/crazymanish/what-matters-most/pull/95
      - `prepend(Publisher)` https://github.com/crazymanish/what-matters-most/pull/96
      - `append(_:)` https://github.com/crazymanish/what-matters-most/pull/97
      - `switchToLatest()` https://github.com/crazymanish/what-matters-most/pull/98
      - `merge(with:)` https://github.com/crazymanish/what-matters-most/pull/99
      - `combineLatest(_:_:)` https://github.com/crazymanish/what-matters-most/pull/100
      - `zip(_:)` https://github.com/crazymanish/what-matters-most/pull/101
    - [x] Practices https://github.com/crazymanish/what-matters-most/pull/95, https://github.com/crazymanish/what-matters-most/pull/96, https://github.com/crazymanish/what-matters-most/pull/97, https://github.com/crazymanish/what-matters-most/pull/98, https://github.com/crazymanish/what-matters-most/pull/99, https://github.com/crazymanish/what-matters-most/pull/100, https://github.com/crazymanish/what-matters-most/pull/101, https://github.com/crazymanish/what-matters-most/pull/102
- [x] Time manipulation Operators
    - [x] Shifting time https://github.com/crazymanish/what-matters-most/pull/103
    - [x] Collecting values https://github.com/crazymanish/what-matters-most/pull/104
    - [x] Holding off events
      - `debounce(for:scheduler:options:)` https://github.com/crazymanish/what-matters-most/pull/105
      - `throttle(for:scheduler:latest:)` https://github.com/crazymanish/what-matters-most/pull/106
    - [x] Timing out https://github.com/crazymanish/what-matters-most/pull/107
    - [x] Measuring time https://github.com/crazymanish/what-matters-most/pull/108
    - [x] Practices https://github.com/crazymanish/what-matters-most/pull/103, https://github.com/crazymanish/what-matters-most/pull/104, https://github.com/crazymanish/what-matters-most/pull/105, https://github.com/crazymanish/what-matters-most/pull/106, https://github.com/crazymanish/what-matters-most/pull/107, https://github.com/crazymanish/what-matters-most/pull/108, https://github.com/crazymanish/what-matters-most/pull/109
- [x] Sequence Operators
    - [x] Finding values
      - `min()` https://github.com/crazymanish/what-matters-most/pull/110 `min(by:)` https://github.com/crazymanish/what-matters-most/pull/111
      - `max()` https://github.com/crazymanish/what-matters-most/pull/112 `max(by:)` https://github.com/crazymanish/what-matters-most/pull/113
      - `first()` https://github.com/crazymanish/what-matters-most/pull/114 `first(where:)` https://github.com/crazymanish/what-matters-most/pull/115
      - `last()` https://github.com/crazymanish/what-matters-most/pull/116 `last(where:)` https://github.com/crazymanish/what-matters-most/pull/117
      - `output(at:)` https://github.com/crazymanish/what-matters-most/pull/118 `output(in:)` https://github.com/crazymanish/what-matters-most/pull/119
    - [x] Query the publisher
      - `count()` https://github.com/crazymanish/what-matters-most/pull/120
      - `contains(_:)` https://github.com/crazymanish/what-matters-most/pull/121 `contains(where:)` https://github.com/crazymanish/what-matters-most/pull/122
      - `allSatisfy(_:)` https://github.com/crazymanish/what-matters-most/pull/123
      - `reduce(_:_:)` https://github.com/crazymanish/what-matters-most/pull/124 
    - [x] Practices https://github.com/crazymanish/what-matters-most/pull/110, https://github.com/crazymanish/what-matters-most/pull/111, https://github.com/crazymanish/what-matters-most/pull/112, https://github.com/crazymanish/what-matters-most/pull/113, https://github.com/crazymanish/what-matters-most/pull/114, https://github.com/crazymanish/what-matters-most/pull/115, https://github.com/crazymanish/what-matters-most/pull/116, https://github.com/crazymanish/what-matters-most/pull/117, https://github.com/crazymanish/what-matters-most/pull/118, https://github.com/crazymanish/what-matters-most/pull/119, https://github.com/crazymanish/what-matters-most/pull/120, https://github.com/crazymanish/what-matters-most/pull/121, https://github.com/crazymanish/what-matters-most/pull/122, https://github.com/crazymanish/what-matters-most/pull/123, https://github.com/crazymanish/what-matters-most/pull/124, https://github.com/crazymanish/what-matters-most/pull/125
  
  ------------------------------------------
  
#### Section3: Combine in action

- [x] Networking
    - [x] URLSession extensions https://github.com/crazymanish/what-matters-most/pull/126
    - [x] Codable support https://github.com/crazymanish/what-matters-most/pull/127
    - [x] Publishing network data https://github.com/crazymanish/what-matters-most/pull/128
    - [x] Practices https://github.com/crazymanish/what-matters-most/pull/126, https://github.com/crazymanish/what-matters-most/pull/127, https://github.com/crazymanish/what-matters-most/pull/128, https://github.com/crazymanish/what-matters-most/pull/129
- [x] Debugging
    - [x] Printing events https://github.com/crazymanish/what-matters-most/pull/130
    - [x] Acting on events https://github.com/crazymanish/what-matters-most/pull/131
    - [x] Using Breakpoint debugger https://github.com/crazymanish/what-matters-most/pull/132
    - [x] Practices https://github.com/crazymanish/what-matters-most/pull/130, https://github.com/crazymanish/what-matters-most/pull/131, https://github.com/crazymanish/what-matters-most/pull/132, https://github.com/crazymanish/what-matters-most/pull/133
- [x] Error Handling
    - [x] Never https://github.com/crazymanish/what-matters-most/pull/134
    - [x] Dealing with failure https://github.com/crazymanish/what-matters-most/pull/135
      - `try-prefixed operators i.e tryMap`
      - `mapError(_:)`
      - `replaceError(with:)`
    - [x] Practices https://github.com/crazymanish/what-matters-most/pull/134, https://github.com/crazymanish/what-matters-most/pull/135, https://github.com/crazymanish/what-matters-most/pull/136
- [x] Schedulers
    - [x] Operators for scheduling https://github.com/crazymanish/what-matters-most/pull/137
      - `subscribe(on:)` and `subscribe(on:options:)`
      - `receive(on:)` and `receive(on:options:)`
    - [x] Scheduler implementations
      - `ImmediateScheduler` https://github.com/crazymanish/what-matters-most/pull/138
      - `RunLoop` `DispatchQueue` `OperationQueue` https://github.com/crazymanish/what-matters-most/pull/139
    - [x] Practices https://github.com/crazymanish/what-matters-most/pull/137, https://github.com/crazymanish/what-matters-most/pull/138, https://github.com/crazymanish/what-matters-most/pull/139, https://github.com/crazymanish/what-matters-most/pull/140
- [ ] Timers
    - [x] Using RunLoop https://github.com/crazymanish/what-matters-most/pull/141
    - [x] Using Timer class https://github.com/crazymanish/what-matters-most/pull/142
    - [ ] Using DispatchQueue
    - [ ] Practices
- [ ] Key-value Observing
    - [ ] KVO introduction
    - [ ] ObservableObject
    - [ ] Practices

  ------------------------------------------
  
#### Section4: Production code

- [ ] Complete app
    - [ ] Build app
    - [ ] Unit testing

--------------------------------------------

#### Start SwiftUI framework
