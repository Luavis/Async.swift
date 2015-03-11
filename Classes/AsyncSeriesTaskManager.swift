//
//  AsyncSeriesTaskManager.swift
//  Async
//
//  Created by 강성일 on 3/10/15.
//  Copyright (c) 2015 Luavis. All rights reserved.
//

import Foundation

class AsyncSeriesTaskManager<ResultType> : AsyncTaskManager<AsyncCallbackType<ResultType>.SeriesTaskCallback, ResultType> {
  
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
