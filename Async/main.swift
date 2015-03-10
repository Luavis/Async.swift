//
//  main.swift
//  Async
//
//  Created by 강성일 on 3/10/15.
//  Copyright (c) 2015 Luavis. All rights reserved.
//

import Foundation

println("Hello, World!")


Async.series([
  {(cb) -> Void in
    dispatch_async(dispatch_queue_create("Test", nil), { () -> Void in
//      sleep(1)
      println("Hello, World1")
      cb(err: nil, result: 30)
    })
  },
  {(cb) -> Void in
    dispatch_async(dispatch_queue_create("Test", nil), { () -> Void in
//      sleep(1)
      println("Hello, World2")
      cb(err: nil, result: 20)
    })
  },
  {(cb) -> Void in
    dispatch_async(dispatch_queue_create("Test", nil), { () -> Void in
//      sleep(1)
      println("Hello, World3")
      cb(err: nil, result: 10)
    })
  },
  {(cb) -> Void in
    dispatch_async(dispatch_queue_create("Test", nil), { () -> Void in
//      sleep(1)
      println("Hello, World4")
      cb(err: nil, result: 1)
    })
  },
  ], callback : {(err:AnyObject?, result:Array<Int?>?) -> Void in
    
    println(result)
    
});

CFRunLoopRun()