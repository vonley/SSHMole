//
//  SMSSHTask.h
//  SSHMole
//
//  Created by openthread on 4/4/15.
//  Copyright (c) 2015 openthread. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMServerConfig.h"

typedef NS_ENUM(NSUInteger, SMSSHTaskStatus) {
    SMSSHTaskStatusConnecting,
    SMSSHTaskStatusConnected,
    SMSSHTaskStatusErrorOccured,
    SMSSHTaskStatusDisconnected,
};

typedef NS_ENUM(NSUInteger, SMSSHTaskErrorCode) {
    SMSSHTaskErrorCodeGeneralError,
    SMSSHTaskErrorCodeRefused,
    SMSSHTaskErrorCodeHostNotFound,
    SMSSHTaskErrorCodeLocalPortCouldNotForward,
    SMSSHTaskErrorCodeBadLocalPort,
    SMSSHTaskErrorCodePrivilegedLocalPortUnavailable,
    SMSSHTaskErrorCodeLocalPortUsed,
    SMSSHTaskErrorCodeBadRemotePort,
    SMSSHTaskErrorCodeRemotePortClosedByServer,
    SMSSHTaskErrorCodeSyntaxError,
    SMSSHTaskErrorCodeWrongPassword,
};

@interface SMSSHTask : NSObject

@property (nonatomic, readonly) BOOL connectionInProgress;
@property (nonatomic, readonly) BOOL connected;

- (id)initWithServerConfig:(SMServerConfig *)config;

- (void)connect;

- (void)disconnect;

@end
