//
//  ViewController.m
//  MomentSever
//  controlCode
//  ready   111
//  pause  333
//  photo  666
//  Created by yanglle on 17/3/2.
//  Copyright © 2017年 yanglle. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"
@implementation ViewController
@synthesize socket = _socket;
@synthesize url = _url;

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (IBAction)margeImage:(id)sender {
 [self InvokingShellScriptAtPath:@"/Users/yanglle/Desktop/test/video.sh"];
    }
-(id) InvokingShellScriptAtPath :(NSString*) shellScriptPath
{
    
    NSTask *shellTask = [[NSTask alloc]init];
    [shellTask setLaunchPath:@"/bin/sh"];
    NSString *shellStr = [NSString stringWithFormat:@"sh %@",shellScriptPath];
    
    
    //-c 表示将后面的内容当成shellcode来执行
    [shellTask setArguments:[NSArray arrayWithObjects:@"-c",shellStr, nil]];
    
    NSPipe *pipe = [[NSPipe alloc]init];
    [shellTask setStandardOutput:pipe];
    
    [shellTask launch];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    NSData *data =[file readDataToEndOfFile];
    NSString *strReturnFromShell = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"The return content from shell script is: %@",strReturnFromShell);
    
    return strReturnFromShell;
 
}
- (IBAction)pause:(id)sender {
    NSString *string =@"333";
    [self sendMsg:string];
}
- (IBAction)takePhoto:(id)sender {
    NSString *string =@"666";
    [self sendMsg:string];
}
- (IBAction)ready:(id)sender {
    NSString *string =@"111";
    [self sendMsg:string];
}

- (IBAction)startSocket:(id)sender {
    NSLog(@"开始连接");
    NSError *error;
    [self start:&error];
}
- (BOOL)start:(NSError **)error;
{
    _connectedSockets = [NSMutableSet new];
    _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
   BOOL result = [self.socket acceptOnPort:3344 error:error];
    //BOOL result = [self.socket acceptOnUrl:self.url error:error];
    if (result) {
        NSLog(@"[Server] Started at Port: %hu",self.socket.localPort);
    }else{
        //NSLog(@"[Server] Started error: %@",&error);
    }
    return result;
}
-(void)sendMsg:(NSString *)msg;
{
    NSLog(@"send message:%@",msg);
    NSData *data =[msg dataUsingEncoding:NSUTF8StringEncoding];
    for (GCDAsyncSocket *socket in self.connectedSockets)
    {
        [socket writeData:data withTimeout:-1 tag:0];
    }
    
}

- (void)stop;
{
    _socket = nil;
    NSLog(@"[Server] Stopped.");
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket;
{
    [self.connectedSockets addObject:newSocket];
    NSLog(@"[newServer ip:%@ add]",newSocket.connectedHost);
    [newSocket readDataWithTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error;
{
    [self.connectedSockets removeObject:socket];
    NSLog(@"[Server] Closed connection: %@", error);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;
{
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"[Server] Received: %@", text);
    
    [sock writeData:data withTimeout:-1 tag:0];
    [sock readDataWithTimeout:-1 tag:0];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
