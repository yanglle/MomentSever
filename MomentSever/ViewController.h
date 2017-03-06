//
//  ViewController.h
//  MomentSever
//
//  Created by yanglle on 17/3/2.
//  Copyright © 2017年 yanglle. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GCDAsyncSocket.h"
@interface ViewController : NSViewController
@property (strong) GCDAsyncSocket *socket;
@property (readonly) NSMutableSet *connectedSockets;
@property (strong) NSURL *url;

@end

