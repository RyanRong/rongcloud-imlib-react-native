//
//  RCTRongCloudDiscLib.h
//  RCTRongCloudIMLib
//
//  Created by sstonehu on 2017/4/12.
//  Copyright © 2017年 lovebing.org. All rights reserved.
//


#import <React/RCTBridgeModule.h>
#import "RCTEventDispatcher.h"
#import <React/RCTBridge.h>
#import <RongIMLib/RongIMLib.h>
#import <RongIMLib/RCIMClient.h>



@interface RCTRongCloudDiscLib: NSObject <RCTBridgeModule> {
    
}
-(RCIMClient *) getClient;

@end

