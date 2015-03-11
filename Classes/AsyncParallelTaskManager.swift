//
//  AsyncParallelTaskManager.swift
//  Async
//
//  Created by 강성일 on 3/10/15.
//  Copyright (c) 2015 Luavis. All rights reserved.
//

import Foundation

class AsyncParallelTaskManager<ResultType> : AsyncTaskManager<AsyncCallbackType<ResultType>.ParallelTaskCallback, ResultType> {
  
  // property
  
  var completedCount = 0
  var runIndex = 0;
  
  var results:Array<ResultType?> = []
  
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
