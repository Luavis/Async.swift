//
//  Async.swift
//  Async
//
//  Created by 강성일 on 3/10/15.
//  Copyright (c) 2015 Luavis. All rights reserved.
//

import Foundation

struct AsyncCallbackType<ResultType> {
  typealias ManagerCallback = (error: AnyObject?, results:Array<ResultType>?) -> Void
  typealias SeriesCallback = (err: AnyObject?, result: ResultType?) -> Void
  typealias SeriesTaskCallback = (SeriesCallback) -> Void

}

internal class AbstractAsyncTaskManager : Equatable {
  
}

func ==(lhs: AbstractAsyncTaskManager, rhs: AbstractAsyncTaskManager) -> Bool {
  return (ObjectIdentifier(lhs).uintValue() == ObjectIdentifier(rhs).uintValue());
}


internal class AsyncTaskManager<TaskType, ResultType> : AbstractAsyncTaskManager {
  
  var tasks:Array<TaskType> = []
  var isEnd:Bool = false
  var callback:AsyncCallbackType<ResultType>.ManagerCallback?
  
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

internal class AsyncSeriesTaskManager<ResultType> : AsyncTaskManager<AsyncCallbackType<ResultType>.SeriesTaskCallback, ResultType> {
  
  // property
  
  var currentPivot:Int = 0 // current pivot index
  var results:Array<ResultType> = []
  
  lazy var nextCallback:AsyncCallbackType<ResultType>.SeriesCallback = {
    [unowned self] (err: AnyObject?, result: ResultType?) -> Void in
    
      if let err:AnyObject = err? {
        
        if let callback = self.callback? {
          callback(error:err, results:nil);
        }
        
      }
      else {
        if let result:ResultType = result? {
          self.results.append(result);
        }
        
        self.doNext()
      }
  };
  
  // methods
  
  init(tasks:Array<AsyncCallbackType<ResultType>.SeriesTaskCallback>, callback: AsyncCallbackType<ResultType>.ManagerCallback?) {
    super.init()
    self.tasks = tasks
    self.callback = callback
  }
  
  func doNext() -> Void {
    self.currentPivot++ // up current pivot
    self.run()
  }
  
  func run() -> Void {
    
    if self.currentPivot < tasks.count && !self.isEnd { // validate up
      
      var task:(AsyncCallbackType<ResultType>.SeriesTaskCallback) = tasks[self.currentPivot]
      task(self.nextCallback)
    }
    else {
      self.isEnd = true
      
      if let callback = self.callback? {
        callback(error:nil, results:self.results);
      }
      
      Async.dismissTaskManager(self)
    }
    
  }
  
}

var _taskManagers:Array<AbstractAsyncTaskManager> = []

class Async {
  
  class func series(tasks:Array<AsyncCallbackType<Void>.SeriesTaskCallback>) {
    self.series(tasks, callback: nil)
  }
  
  class func series<ResultType>(tasks:Array<AsyncCallbackType<ResultType>.SeriesTaskCallback>, callback:AsyncCallbackType<ResultType>.ManagerCallback?) {
    var task:AsyncSeriesTaskManager = AsyncSeriesTaskManager<ResultType>(tasks: tasks, callback)
    Async.registerTaskManger(task)
    task.run()
  }
  
  private class func registerTaskManger(taskManager: AbstractAsyncTaskManager) -> Void {
    _taskManagers.append(taskManager)
  }
  
  private class func dismissTaskManager(taskManager: AbstractAsyncTaskManager) -> Void {
    _taskManagers.removeObject(taskManager)
  }
  
}
