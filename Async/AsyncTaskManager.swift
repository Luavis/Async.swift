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
  
}

internal class AbstractAsyncTaskManager : Equatable {
  func run() -> Void {}
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
  var results:Array<ResultType?> = []
  
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
  
  override func run() -> Void {
    
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

internal class AsyncParallelTaskManager<ResultType> : AsyncTaskManager<AsyncCallbackType<ResultType>.ParallelTaskCallback, ResultType> {
  
  // property
  
  var completedCount = 0
  var runIndex = 0;
  
  var results:Array<ResultType?> = []
  
  lazy var nextCallback:AsyncCallbackType<ResultType>.ParallelCallback = {
    [unowned self] (err: AnyObject?, result: ResultType?) -> Void in
    
    if let err:AnyObject = err? {
      
      if let callback = self.callback? {
        callback(error:err, results:nil);
      }
      
    }
    else {
      
      if let result:ResultType = result? {
        //        var index:Int = -1
        
        //        if index != -1 {
        self.results.insert(result, atIndex:0)
        //        }
      }
      
      self.completedCount++
      if self.completedCount >= self.tasks.count {
        self.isEnd = true
        
        if let callback = self.callback? {
          callback(error:nil, results:self.results)
        }
        
        Async.dismissTaskManager(self)
      }
    }
  };
  
  
  func createCallback(index:Int) -> (AsyncCallbackType<ResultType>.ParallelCallback) {
    
    
    return {
      [unowned self] (err: AnyObject?, result: ResultType?) -> Void in
      
      if let err:AnyObject = err? {
        
        if let callback = self.callback? {
          callback(error:err, results:nil);
        }
        
      }
      else {
        
        if let result:ResultType = result? {
          //        var index:Int = -1
          
          //        if index != -1 {
          self.results[index] = result
          //        }
        }
        
        self.completedCount++
        if self.completedCount >= self.tasks.count {
          self.isEnd = true
          
          if let callback = self.callback? {
            callback(error:nil, results:self.results)
          }
          
          Async.dismissTaskManager(self)
        }
      }
    };
  }
  
  // methods
  
  init(tasks:Array<AsyncCallbackType<ResultType>.ParallelTaskCallback>, callback: AsyncCallbackType<ResultType>.ManagerCallback?) {
    super.init()
    self.tasks = tasks
    self.callback = callback
    
    self.results = Array<ResultType?>(count: self.tasks.count, repeatedValue: nil)
  }
  
  override func run() -> Void {
    
    if self.completedCount < tasks.count && !self.isEnd { // validate up
      for (index, task:(AsyncCallbackType<ResultType>.ParallelTaskCallback)) in enumerate(self.tasks) {
        task(self.createCallback(index))
      }
    }
  }
  
}