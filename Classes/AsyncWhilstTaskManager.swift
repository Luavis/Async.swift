//
//  AsyncWhilstTaskManager.swift
//  Async
//
//  Created by 강성일 on 3/10/15.
//  Copyright (c) 2015 Luavis. All rights reserved.
//

import Foundation

class AsyncWhilstTaskManager<ResultType> : AsyncTaskManager<AsyncCallbackType<ResultType>.WhilstTaskCallback, ResultType> {
  
  // property
  
  var completedCount = 0
  var runIndex = 0;
  
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
  
  init(tasks:Array<AsyncCallbackType<ResultType>.WhilstTaskCallback>, callback: AsyncCallbackType<ResultType>.ManagerCallback?) {
    super.init()
    self.tasks = tasks
    self.callback = callback
    
    self.results = Array<ResultType?>(count: self.tasks.count, repeatedValue: nil)
  }
  
  override func run() -> Void {
    
    if self.completedCount < tasks.count && !self.isEnd { // validate up
      for (index, task:(AsyncCallbackType<ResultType>.WhilstTaskCallback)) in enumerate(self.tasks) {
        task(self.createCallback(index))
      }
    }
  }
  
  
}

