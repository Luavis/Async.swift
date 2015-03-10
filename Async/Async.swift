//
//  Async.swift
//  Async
//
//  Created by 강성일 on 3/10/15.
//  Copyright (c) 2015 Luavis. All rights reserved.
//

import Foundation

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
  
  class func parallel(tasks:Array<AsyncCallbackType<Void>.SeriesTaskCallback>) {
    self.parallel(tasks, callback: nil)
  }
  
  class func parallel<ResultType>(tasks:Array<AsyncCallbackType<ResultType>.SeriesTaskCallback>, callback:AsyncCallbackType<ResultType>.ManagerCallback?) {
    var task:AsyncParallelTaskManager = AsyncParallelTaskManager<ResultType>(tasks: tasks, callback)
    Async.registerTaskManger(task)
    task.run()
  }
  
  class func registerTaskManger(taskManager: AbstractAsyncTaskManager) -> Void {
    _taskManagers.append(taskManager)
  }
  
  class func dismissTaskManager(taskManager: AbstractAsyncTaskManager) -> Void {
    _taskManagers.removeObject(taskManager)
  }
  
}
