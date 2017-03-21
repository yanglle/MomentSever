//
//  AppDelegate.h
//  MomentSever
//
//  Created by yanglle on 17/3/2.
//  Copyright © 2017年 yanglle. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class HTTPServer;
@interface AppDelegate : NSObject <NSApplicationDelegate>{
   	HTTPServer *httpServer;
}


@end

