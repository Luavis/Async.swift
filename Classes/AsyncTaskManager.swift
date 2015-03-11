//
//  AsyncTaskManager.swift
//  Async
//
//  Created by 강성일 on 3/10/15.
//  Copyright (c) 2015 Luavis. All rights reserved.
//

import Foundation

struct AsyncCallbackType<ResultType> {
  typealias ManagerCallback = (error: AnyObject?, results:Array<ResultType?>?) -> Void
  
  typealias SeriesCallback = (err: AnyObject?, result: ResultType?) -> Void
  typealias SeriesTaskCallback = (SeriesCallback) -> Void
  
  typealias ParallelCallback = (err: AnyObject?, result: ResultType?) -> Void
  typealias ParallelTaskCallback = (ParallelCallback) -> Void
  
  typealias WhilstCallback = (err: AnyObject?) -> Void
  typealias WhilstTaskCallback = (WhilstCallback) -> Void
  
}

internal class AbstractAsyncTaskManager : Equatable {
  func run() -> Void {}
}

func ==(lhs: AbstractAsyncTaskManager, rhs: AbstractAsyncTaskManager) -> Bool {
  return (ObjectIdentifier(lhs).uintValue() == ObjectIdentifier(rhs).uintValue());
}


class AsyncTaskManager<TaskType, ResultType> : AbstractAsyncTaskManager {
  
  var tasks:Array<TaskType> = []
  var isEnd:Bool = false
  var callback:AsyncCallbackType<ResultType>.ManagerCallback?
  
  override init(){}
}

extension Array {
  mutating func removeObject<U: Equatable>(object: U) {
    var index: Int?
    for (idx, objectToCompare) in enumerate(self) {
      if let to = objectToCompare as? U {
        if object == to {
          index = idx
        }
      }
    }
    
    if(index != nil) {
      self.removeAtIndex(index!)
    }
  }
}
