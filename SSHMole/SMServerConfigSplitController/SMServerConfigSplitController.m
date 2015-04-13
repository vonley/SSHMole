//
//  SMServerConfigSplitController.m
//  SSHMole
//
//  Created by openthread on 4/5/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import "SMServerConfigSplitController.h"

//Subviews
#import "SMServerListView.h"
#import "SMServerConfigView.h"

//Managers & models
#import "SMServerConfig.h"
#import "SMServerConfigStorage.h"
#import "SMSSHTaskManager.h"

@interface SMServerConfigSplitController () <NSSplitViewDelegate, SMServerListViewDelegate, SMServerConfigViewDelegate>
@property (nonatomic, weak) IBOutlet SMServerListView *serverListView;
@property (nonatomic, weak) IBOutlet SMServerConfigView *serverConfigView;
@property (nonatomic, strong) SMServerConfig *currentConfig;
@end

@implementation SMServerConfigSplitController
{
}

#warning disable save button at config picked, enable when text changed
#warning change connection button function for different status
#warning update traffic light color when disconnect button touched
#warning save when connect button clicked
#warning table view ui problem should be fix
#warning context menu and status bar icon
#warning change network settings
#warning pac server use cocoa server

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    return proposedMinimumPosition + 150.f;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    return proposedMaximumPosition - 350.f;
}

#pragma mark - List table callback

//User did select add config table row.
- (void)serverListViewDidPickAddConfig:(SMServerListView *)serverListView
{
    self.currentConfig = nil;
    
    self.serverConfigView.serverAddressString = @"";
    self.serverConfigView.serverPort = 0;//server config view will use default 22 port
    self.serverConfigView.accountString = @"";
    self.serverConfigView.passwordString = @"";
    self.serverConfigView.localPort = 0;//server config view will use default 7070 port
    self.serverConfigView.remarkString = @"";
    
    [self.serverConfigView.window makeFirstResponder:self.serverConfigView];
}

//User did select existing server config.
- (void)serverListView:(SMServerListView *)serverListView didPickAddConfig:(SMServerConfig *)config
{
    self.currentConfig = config;
    
    self.serverConfigView.serverAddressString = config.serverAddress;
    self.serverConfigView.serverPort = config.serverPort;//server config view will use default 22 port
    self.serverConfigView.accountString = config.account;
    self.serverConfigView.passwordString = config.password;
    self.serverConfigView.localPort = config.localPort;//server config view will use default 7070 port
    self.serverConfigView.remarkString = config.remark;
    
    [self.serverConfigView.window makeFirstResponder:self.serverConfigView];
    
    [self.serverConfigView setSaveButtonEnabled:NO];
}

- (void)serverListViewDeleteKeyDown:(SMServerListView *)serverListView onConfig:(SMServerConfig *)config
{
    [[SMServerConfigStorage defaultStorage] removeConfig:config];
    [self.serverListView reloadData];
    
    [self.serverConfigView setSaveButtonEnabled:NO];
}

#pragma mark - Server config view call back

- (void)serverConfigViewConnectButtonTouched:(SMServerConfigView *)configView
{
    [[SMSSHTaskManager defaultManager] beginConnectWithServerConfig:self.currentConfig callback:^(SMSSHTaskStatus status, NSError *error)
    {
        //Generate info
        NSMutableDictionary *infoDictionary = [NSMutableDictionary dictionary];
        infoDictionary[@"Status"] = [NSNumber numberWithUnsignedInteger:status];
        if (error)
        {
            infoDictionary[@"Error"] = error;
        }
        //Call on main thread
        if ([NSThread isMainThread])
        {
            [self updateUIForConnectionStatusChangedWithInfo:infoDictionary];
        }
        else
        {
            [self performSelectorOnMainThread:@selector(updateUIForConnectionStatusChangedWithInfo:)
                                   withObject:infoDictionary
                                waitUntilDone:NO];
        }
    }];
    
    [[SMSSHTaskManager defaultManager] performSelector:@selector(disconnect) withObject:nil afterDelay:10];
}

- (void)updateUIForConnectionStatusChangedWithInfo:(NSDictionary *)info
{
    [self.serverListView reloadData];
    if (info[@"Error"])
    {
        NSError *error = info[@"Error"];
        NSAlert *alert = [[NSAlert alloc]init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:error.domain];
        [alert runModal];
    }
}

- (void)serverConfigViewSaveButtonTouched:(SMServerConfigView *)view
{
    if (!self.currentConfig)
    {
        self.currentConfig = [[SMServerConfig alloc] init];
    }
    else
    {
        [self.currentConfig removeFromKeychain];
    }
    
    //Generate a new config
    self.currentConfig.serverAddress = view.serverAddressString;
    self.currentConfig.serverPort = view.serverPort;
    self.currentConfig.account = view.accountString;
    self.currentConfig.password = view.passwordString;
    self.currentConfig.localPort = view.localPort;
    self.currentConfig.remark = view.remarkString;
    
    //Save to storage
    [[SMServerConfigStorage defaultStorage] addConfig:self.currentConfig];
    
    [self.serverListView reloadData];
}

@end
