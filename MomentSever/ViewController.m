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
#import "Core/HTTPConnection.h"

@implementation ViewController
@synthesize socket = _socket;
@synthesize url = _url;
NSString *path;
NSString *home;
NSString *output;
NSString *shellRoot;
NSFileManager *fileManager;
BOOL isConnected = 0;
BOOL isReady=0;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    
    
}
-(void)initView;{
    //初始化本地文件夹
    fileManager = [NSFileManager defaultManager];
    home=[NSHomeDirectory() stringByAppendingString:@"/Desktop/photos/"];
    output=[NSHomeDirectory() stringByAppendingString:@"/Desktop/output/"];
    shellRoot = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"sh" inDirectory:@"web"];
    if (![fileManager fileExistsAtPath:home]) {
        [self cmd:[@"mkdir " stringByAppendingString:home]];
    }
    if (![fileManager fileExistsAtPath:output]) {
        [self cmd:[@"mkdir " stringByAppendingString:output]];
    }

}
- (IBAction)montage:(id)sender {
    [self InvokingShellScriptAtPath:shellRoot];
    }

- (IBAction)takePhoto:(id)sender {
    if (isConnected&&isReady) {
        [self sendMsg:@"666"];
        [self appendToMyTextView:@"拍照"];
    }else{
        [self appendToMyTextView:@"请先点击准备按钮 进入就绪状态"];
    }
    

}
- (IBAction)ready:(id)sender {
    if (isConnected) {
        if (isReady) {
            [self sendMsg:@"333"];
            [self appendToMyTextView:@"暂停"];
            isReady=0;
            _readyBtn.title=@"准备";
        } else {
            [self sendMsg:@"111"];
            [self appendToMyTextView:@"准备"];
            isReady=1;
            _readyBtn.title=@"暂停";
        }
    }else{
        [self appendToMyTextView:@"请先点击开始按钮 启动服务"];
    }


}

- (IBAction)startSocket:(id)sender {
    NSLog(@"开始连接");
    NSError *error;
    if (isConnected) {
        [self stop];
    }else{
        [self start:&error];
    }
   
}
#pragma mark socket
- (BOOL)start:(NSError **)error;
{
    _connectedSockets = [NSMutableSet new];
    _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
   BOOL result = [self.socket acceptOnPort:3344 error:error];
    //BOOL result = [self.socket acceptOnUrl:self.url error:error];
    if (result) {
        NSLog(@"[Server] Started at Port: %hu",self.socket.localPort);
        isConnected=1;
        _startBtn.title=@"结束";
        [self appendToMyTextView:@"[Server] Started"];
    }else{
        //NSLog(@"[Server] Started error: %@",&error);
    }
    /*
    NSString *base=@"mkdir /Users/XXX/Desktop/photos";
    path = [self cmd:@"whoami"];
    //取出的用户名末尾带一位回车符 去掉
    path = [path substringToIndex:[path length]-1];
    //用用户名代替XXX得到正确路径
    path = [base stringByReplacingOccurrencesOfString:@"XXX" withString:path];
    [self cmd:path];
    [self appendToMyTextView:path];
     */
    return result;
}
-(void)sendMsg:(NSString *)msg;
{
    //NSLog(@"send message:%@",msg);
    NSData *data =[msg dataUsingEncoding:NSUTF8StringEncoding];
    for (GCDAsyncSocket *socket in self.connectedSockets)
    {
        [socket writeData:data withTimeout:-1 tag:0];
    }
    
}

- (void)stop;
{
    [_socket disconnect];
    isConnected=0;
    _startBtn.title=@"开始";
    [self appendToMyTextView:@"[Server] Stopped."];
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
{   NSLog(@"tag:%ld",tag);
    
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"[Server] Received: %@", text);
    [self appendToMyTextView:text];
    [sock readDataWithTimeout:-1 tag:0];
    [sock writeData:data withTimeout:-1 tag:0];
    
}
#pragma mark 工具类

-(void)saveImg:(NSData *)img withChannel:(NSString *)channel;{
    
    NSString *filepath=  [home stringByAppendingString:[channel stringByAppendingString:@".jpg"]];
    [self appendToMyTextView:filepath];
    [fileManager createFileAtPath:filepath contents:img attributes:nil];
}

- (void)appendToMyTextView :( NSString*)text
{
    text =[text stringByAppendingString:@"\n"];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAttributedString* attr = [[NSAttributedString alloc] initWithString:text];
        
        [[_consoleTF textStorage] appendAttributedString:attr];
        [_consoleTF scrollRangeToVisible:NSMakeRange([[_consoleTF string] length], 0)];
    });
}
- (NSString *)cmd:(NSString *)cmd
{
    // 初始化并设置shell路径
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/bash"];
    // -c 用来执行string-commands（命令字符串），也就说不管后面的字符串里是什么都会被当做shellcode来执行
    NSArray *arguments = [NSArray arrayWithObjects: @"-c", cmd, nil];
    [task setArguments: arguments];
    
    // 新建输出管道作为Task的输出
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    // 开始task
    NSFileHandle *file = [pipe fileHandleForReading];
    [task launch];
    
    // 获取运行结果
    NSData *data = [file readDataToEndOfFile];
    return [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
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
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
