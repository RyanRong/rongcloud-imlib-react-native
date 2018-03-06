//
//  RCTRongCloudDiscLib.m
//  RCTRongCloudIMLib
//
//  Created by sstonehu on 2017/4/12.
//  Copyright © 2017年 lovebing.org. All rights reserved.
//


#import "RCTRongCloudDiscLib.h"

@implementation RCTRongCloudDiscLib
@synthesize bridge = _bridge;

RCT_EXPORT_MODULE(RongCloudDiscLibModule)


RCT_EXPORT_METHOD(createDiscussion:(NSString *)name
                  userIdList:(NSArray *)userIdList
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    NSLog(@"------------- createDiscussion start name: %@, userIdList: %d--------------", name, userIdList);
    void (^successBlock)(RCDiscussion * disc);
    successBlock = ^(RCDiscussion* disc) {
        if (disc) {
            NSLog(@"disc:  %@", disc);
            NSString *discJsonString = [self getDiscJsonStr:disc];
            NSLog(@"disc:  %@", discJsonString);
            resolve(discJsonString);
        } else {
            reject(@"NO_RETURN_DISC", @"There were no return disc", nil);
        }
    };
    
    void (^errorBlock)(RCErrorCode status);
    errorBlock = ^(RCErrorCode status) {
        NSString *errcode;
        switch (status) {
            case ERRORCODE_UNKNOWN:
                errcode = @"ERRORCODE_UNKNOWN";
                break;
            case REJECTED_BY_BLACKLIST:
                errcode = @"REJECTED_BY_BLACKLIST";
                break;
            case ERRORCODE_TIMEOUT:
                errcode = @"ERRORCODE_TIMEOUT";
                break;
            case SEND_MSG_FREQUENCY_OVERRUN:
                errcode = @"SEND_MSG_FREQUENCY_OVERRUN";
                break;
            case NOT_IN_DISCUSSION:
                errcode = @"NOT_IN_DISCUSSION";
                break;
            case NOT_IN_GROUP:
                errcode = @"NOT_IN_GROUP";
                break;
            case FORBIDDEN_IN_GROUP:
                errcode = @"FORBIDDEN_IN_GROUP";
                break;
            case NOT_IN_CHATROOM:
                errcode = @"NOT_IN_CHATROOM";
                break;
            case FORBIDDEN_IN_CHATROOM:
                errcode = @"FORBIDDEN_IN_CHATROOM";
                break;
            case KICKED_FROM_CHATROOM:
                errcode = @"KICKED_FROM_CHATROOM";
                break;
            case RC_CHATROOM_NOT_EXIST:
                errcode = @"RC_CHATROOM_NOT_EXIST";
                break;
            case RC_CHATROOM_IS_FULL:
                errcode = @"RC_CHATROOM_IS_FULL";
                break;
            case RC_CHANNEL_INVALID:
                errcode = @"RC_CHANNEL_INVALID";
                break;
            case RC_NETWORK_UNAVAILABLE:
                errcode = @"RC_NETWORK_UNAVAILABLE";
                break;
            case CLIENT_NOT_INIT:
                errcode = @"CLIENT_NOT_INIT";
                break;
            case DATABASE_ERROR:
                errcode = @"DATABASE_ERROR";
                break;
            case INVALID_PARAMETER:
                errcode = @"INVALID_PARAMETER";
                break;
            case MSG_ROAMING_SERVICE_UNAVAILABLE:
                errcode = @"MSG_ROAMING_SERVICE_UNAVAILABLE";
                break;
            case INVALID_PUBLIC_NUMBER:
                errcode = @"INVALID_PUBLIC_NUMBER";
                break;
            default:
                errcode = @"OTHER";
                break;
        }
        reject(errcode, errcode, nil);
    };

    [[self getClient] createDiscussion:name userIdList:userIdList success:successBlock error:errorBlock];

}

/*!
 讨论组加人，将用户加入讨论组
 
 @param discussionId    讨论组ID
 @param userIdList      需要加入的用户ID列表
 @param successBlock    讨论组加人成功的回调 [discussion:讨论组加人成功返回的讨论组对象]
 @param errorBlock      讨论组加人失败的回调 [status:讨论组加人失败的错误码]
 
 @discussion 设置的讨论组名称长度不能超过40个字符，否则将会截断为前40个字符。
 */
RCT_EXPORT_METHOD(addMemberToDiscussion:(NSString *)discussionId
                  userIdList:(NSArray *)userIdList
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    NSLog(@"------------- addMemberToDiscussion start discussionId: %@, userIdList: %d--------------", discussionId, userIdList);
    void (^successBlock)(RCDiscussion * disc);
    successBlock = ^(RCDiscussion* disc) {
        if (disc) {
            NSString *discJsonString = [self getDiscJsonStr:disc];
            resolve(discJsonString);
        } else {
            reject(@"NO_RETURN_DISC", @"There were no return disc", nil);
        }
    };
    
    //TODO:  Abstract the errorBlock and successBlock to Template function
    void (^errorBlock)(RCErrorCode status);
    errorBlock = ^(RCErrorCode status) {
        NSString *errcode;
        switch (status) {
            case ERRORCODE_UNKNOWN:
                errcode = @"ERRORCODE_UNKNOWN";
                break;
            case REJECTED_BY_BLACKLIST:
                errcode = @"REJECTED_BY_BLACKLIST";
                break;
            case ERRORCODE_TIMEOUT:
                errcode = @"ERRORCODE_TIMEOUT";
                break;
            case SEND_MSG_FREQUENCY_OVERRUN:
                errcode = @"SEND_MSG_FREQUENCY_OVERRUN";
                break;
            case NOT_IN_DISCUSSION:
                errcode = @"NOT_IN_DISCUSSION";
                break;
            case NOT_IN_GROUP:
                errcode = @"NOT_IN_GROUP";
                break;
            case FORBIDDEN_IN_GROUP:
                errcode = @"FORBIDDEN_IN_GROUP";
                break;
            case NOT_IN_CHATROOM:
                errcode = @"NOT_IN_CHATROOM";
                break;
            case FORBIDDEN_IN_CHATROOM:
                errcode = @"FORBIDDEN_IN_CHATROOM";
                break;
            case KICKED_FROM_CHATROOM:
                errcode = @"KICKED_FROM_CHATROOM";
                break;
            case RC_CHATROOM_NOT_EXIST:
                errcode = @"RC_CHATROOM_NOT_EXIST";
                break;
            case RC_CHATROOM_IS_FULL:
                errcode = @"RC_CHATROOM_IS_FULL";
                break;
            case RC_CHANNEL_INVALID:
                errcode = @"RC_CHANNEL_INVALID";
                break;
            case RC_NETWORK_UNAVAILABLE:
                errcode = @"RC_NETWORK_UNAVAILABLE";
                break;
            case CLIENT_NOT_INIT:
                errcode = @"CLIENT_NOT_INIT";
                break;
            case DATABASE_ERROR:
                errcode = @"DATABASE_ERROR";
                break;
            case INVALID_PARAMETER:
                errcode = @"INVALID_PARAMETER";
                break;
            case MSG_ROAMING_SERVICE_UNAVAILABLE:
                errcode = @"MSG_ROAMING_SERVICE_UNAVAILABLE";
                break;
            case INVALID_PUBLIC_NUMBER:
                errcode = @"INVALID_PUBLIC_NUMBER";
                break;
            default:
                errcode = @"OTHER";
                break;
        }
        reject(errcode, errcode, nil);
    };
    
    [[self getClient] addMemberToDiscussion:discussionId userIdList:userIdList success:successBlock error:errorBlock];
}
/*!
 讨论组踢人，将用户移出讨论组
 
 @param discussionId    讨论组ID
 @param userId          需要移出的用户ID
 @param successBlock    讨论组踢人成功的回调 [discussion:讨论组踢人成功返回的讨论组对象]
 @param errorBlock      讨论组踢人失败的回调 [status:讨论组踢人失败的错误码]
 
 @discussion 如果当前登陆用户不是此讨论组的创建者并且此讨论组没有开放加人权限，则会返回错误。
 
 @warning 不能使用此接口将自己移除，否则会返回错误。
 如果您需要退出该讨论组，可以使用-quitDiscussion:success:error:方法。
 */
RCT_EXPORT_METHOD(removeMemberFromDiscussion:(NSString *)discussionId
                  userId:(NSString *)userId
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    NSLog(@"------------- removeMemberFromDiscussion start discussionId: %@, userIdList: %d--------------", discussionId, userId);
    void (^successBlock)(RCDiscussion * disc);
    successBlock = ^(RCDiscussion* disc) {
        if (disc) {
            NSString *discJsonString = [self getDiscJsonStr:disc];
            resolve(discJsonString);
        } else {
            reject(@"NO_RETURN_DISC", @"There were no return disc", nil);
        }
    };
    
    void (^errorBlock)(RCErrorCode status);
    errorBlock = ^(RCErrorCode status) {
        NSString *errcode;
        switch (status) {
            case ERRORCODE_UNKNOWN:
                errcode = @"ERRORCODE_UNKNOWN";
                break;
            case REJECTED_BY_BLACKLIST:
                errcode = @"REJECTED_BY_BLACKLIST";
                break;
            case ERRORCODE_TIMEOUT:
                errcode = @"ERRORCODE_TIMEOUT";
                break;
            case SEND_MSG_FREQUENCY_OVERRUN:
                errcode = @"SEND_MSG_FREQUENCY_OVERRUN";
                break;
            case NOT_IN_DISCUSSION:
                errcode = @"NOT_IN_DISCUSSION";
                break;
            case NOT_IN_GROUP:
                errcode = @"NOT_IN_GROUP";
                break;
            case FORBIDDEN_IN_GROUP:
                errcode = @"FORBIDDEN_IN_GROUP";
                break;
            case NOT_IN_CHATROOM:
                errcode = @"NOT_IN_CHATROOM";
                break;
            case FORBIDDEN_IN_CHATROOM:
                errcode = @"FORBIDDEN_IN_CHATROOM";
                break;
            case KICKED_FROM_CHATROOM:
                errcode = @"KICKED_FROM_CHATROOM";
                break;
            case RC_CHATROOM_NOT_EXIST:
                errcode = @"RC_CHATROOM_NOT_EXIST";
                break;
            case RC_CHATROOM_IS_FULL:
                errcode = @"RC_CHATROOM_IS_FULL";
                break;
            case RC_CHANNEL_INVALID:
                errcode = @"RC_CHANNEL_INVALID";
                break;
            case RC_NETWORK_UNAVAILABLE:
                errcode = @"RC_NETWORK_UNAVAILABLE";
                break;
            case CLIENT_NOT_INIT:
                errcode = @"CLIENT_NOT_INIT";
                break;
            case DATABASE_ERROR:
                errcode = @"DATABASE_ERROR";
                break;
            case INVALID_PARAMETER:
                errcode = @"INVALID_PARAMETER";
                break;
            case MSG_ROAMING_SERVICE_UNAVAILABLE:
                errcode = @"MSG_ROAMING_SERVICE_UNAVAILABLE";
                break;
            case INVALID_PUBLIC_NUMBER:
                errcode = @"INVALID_PUBLIC_NUMBER";
                break;
            default:
                errcode = @"OTHER";
                break;
        }
        reject(errcode, errcode, nil);
    };
    
    [[self getClient] removeMemberFromDiscussion:discussionId userId:userId success:successBlock error:errorBlock];
}

/*!
 退出当前讨论组
 
 @param discussionId    讨论组ID
 @param successBlock    退出成功的回调 [discussion:退出成功返回的讨论组对象] 注：此处不会返回discussion，文档有误！
 @param errorBlock      退出失败的回调 [status:退出失败的错误码]
 */
RCT_EXPORT_METHOD(quitDiscussion:(NSString *)discussionId
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    NSLog(@"------------- quitDiscussion start discussionId: %@ -------------------", discussionId);
    void (^successBlock)(RCDiscussion * disc);
    successBlock = ^(RCDiscussion* disc) {
        resolve(@"QUIT_DISCUSSION_SUCCESS");
//        if (disc) {
//            NSString *discJsonString = [self getDiscJsonStr:disc];
//            resolve(discJsonString);
//        } else {
//            reject(@"NO_RETURN_DISC", @"There were no return disc", nil);
//        }
    };
    
    void (^errorBlock)(RCErrorCode status);
    errorBlock = ^(RCErrorCode status) {
        NSString *errcode;
        switch (status) {
            case ERRORCODE_UNKNOWN:
                errcode = @"ERRORCODE_UNKNOWN";
                break;
            case REJECTED_BY_BLACKLIST:
                errcode = @"REJECTED_BY_BLACKLIST";
                break;
            case ERRORCODE_TIMEOUT:
                errcode = @"ERRORCODE_TIMEOUT";
                break;
            case SEND_MSG_FREQUENCY_OVERRUN:
                errcode = @"SEND_MSG_FREQUENCY_OVERRUN";
                break;
            case NOT_IN_DISCUSSION:
                errcode = @"NOT_IN_DISCUSSION";
                break;
            case NOT_IN_GROUP:
                errcode = @"NOT_IN_GROUP";
                break;
            case FORBIDDEN_IN_GROUP:
                errcode = @"FORBIDDEN_IN_GROUP";
                break;
            case NOT_IN_CHATROOM:
                errcode = @"NOT_IN_CHATROOM";
                break;
            case FORBIDDEN_IN_CHATROOM:
                errcode = @"FORBIDDEN_IN_CHATROOM";
                break;
            case KICKED_FROM_CHATROOM:
                errcode = @"KICKED_FROM_CHATROOM";
                break;
            case RC_CHATROOM_NOT_EXIST:
                errcode = @"RC_CHATROOM_NOT_EXIST";
                break;
            case RC_CHATROOM_IS_FULL:
                errcode = @"RC_CHATROOM_IS_FULL";
                break;
            case RC_CHANNEL_INVALID:
                errcode = @"RC_CHANNEL_INVALID";
                break;
            case RC_NETWORK_UNAVAILABLE:
                errcode = @"RC_NETWORK_UNAVAILABLE";
                break;
            case CLIENT_NOT_INIT:
                errcode = @"CLIENT_NOT_INIT";
                break;
            case DATABASE_ERROR:
                errcode = @"DATABASE_ERROR";
                break;
            case INVALID_PARAMETER:
                errcode = @"INVALID_PARAMETER";
                break;
            case MSG_ROAMING_SERVICE_UNAVAILABLE:
                errcode = @"MSG_ROAMING_SERVICE_UNAVAILABLE";
                break;
            case INVALID_PUBLIC_NUMBER:
                errcode = @"INVALID_PUBLIC_NUMBER";
                break;
            default:
                errcode = @"OTHER";
                break;
        }
        reject(errcode, errcode, nil);
    };
    
    [[self getClient] quitDiscussion:discussionId success:successBlock error:errorBlock];
}

/*!
 获取讨论组的信息
 
 @param discussionId    需要获取信息的讨论组ID
 @param successBlock    获取讨论组信息成功的回调 [discussion:获取的讨论组信息]
 @param errorBlock      获取讨论组信息失败的回调 [status:获取讨论组信息失败的错误码]
 */
RCT_EXPORT_METHOD(getDiscussion:(NSString *)discussionId
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    NSLog(@"------------- quitDiscussion start discussionId: %@ -------------------", discussionId);
    void (^successBlock)(RCDiscussion * disc);
    successBlock = ^(RCDiscussion* disc) {
        if (disc) {
            NSString *discJsonString = [self getDiscJsonStr:disc];
            resolve(discJsonString);
        } else {
            reject(@"NO_RETURN_DISC", @"There were no return disc", nil);
        }
    };
    
    void (^errorBlock)(RCErrorCode status);
    errorBlock = ^(RCErrorCode status) {
        NSString *errcode;
        switch (status) {
            case ERRORCODE_UNKNOWN:
                errcode = @"ERRORCODE_UNKNOWN";
                break;
            case REJECTED_BY_BLACKLIST:
                errcode = @"REJECTED_BY_BLACKLIST";
                break;
            case ERRORCODE_TIMEOUT:
                errcode = @"ERRORCODE_TIMEOUT";
                break;
            case SEND_MSG_FREQUENCY_OVERRUN:
                errcode = @"SEND_MSG_FREQUENCY_OVERRUN";
                break;
            case NOT_IN_DISCUSSION:
                errcode = @"NOT_IN_DISCUSSION";
                break;
            case NOT_IN_GROUP:
                errcode = @"NOT_IN_GROUP";
                break;
            case FORBIDDEN_IN_GROUP:
                errcode = @"FORBIDDEN_IN_GROUP";
                break;
            case NOT_IN_CHATROOM:
                errcode = @"NOT_IN_CHATROOM";
                break;
            case FORBIDDEN_IN_CHATROOM:
                errcode = @"FORBIDDEN_IN_CHATROOM";
                break;
            case KICKED_FROM_CHATROOM:
                errcode = @"KICKED_FROM_CHATROOM";
                break;
            case RC_CHATROOM_NOT_EXIST:
                errcode = @"RC_CHATROOM_NOT_EXIST";
                break;
            case RC_CHATROOM_IS_FULL:
                errcode = @"RC_CHATROOM_IS_FULL";
                break;
            case RC_CHANNEL_INVALID:
                errcode = @"RC_CHANNEL_INVALID";
                break;
            case RC_NETWORK_UNAVAILABLE:
                errcode = @"RC_NETWORK_UNAVAILABLE";
                break;
            case CLIENT_NOT_INIT:
                errcode = @"CLIENT_NOT_INIT";
                break;
            case DATABASE_ERROR:
                errcode = @"DATABASE_ERROR";
                break;
            case INVALID_PARAMETER:
                errcode = @"INVALID_PARAMETER";
                break;
            case MSG_ROAMING_SERVICE_UNAVAILABLE:
                errcode = @"MSG_ROAMING_SERVICE_UNAVAILABLE";
                break;
            case INVALID_PUBLIC_NUMBER:
                errcode = @"INVALID_PUBLIC_NUMBER";
                break;
            default:
                errcode = @"OTHER";
                break;
        }
        reject(errcode, errcode, nil);
    };
    
    [[self getClient] getDiscussion:discussionId success:successBlock error:errorBlock];
}

/*!
 设置讨论组名称
 
 @param targetId                需要设置的讨论组ID
 @param discussionName          需要设置的讨论组名称，discussionName长度<=40
 @param successBlock            设置成功的回调
 @param errorBlock              设置失败的回调 [status:设置失败的错误码]
 
 @discussion 设置的讨论组名称长度不能超过40个字符，否则将会截断为前40个字符。
 */
RCT_EXPORT_METHOD(setDiscussionName:(NSString *)targetId
                  name:(NSString *)discussionName
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    NSLog(@"------------- setDiscussionName start discussionId: %@, set as name: %@ -------------------", targetId, discussionName);
    void (^successBlock)();
    successBlock = ^() {
        resolve(@"SUCCESS_WITHi_NO_RETURN_VALUE");
    };
    
    void (^errorBlock)(RCErrorCode status);
    errorBlock = ^(RCErrorCode status) {
        NSString *errcode;
        switch (status) {
            case ERRORCODE_UNKNOWN:
                errcode = @"ERRORCODE_UNKNOWN";
                break;
            case REJECTED_BY_BLACKLIST:
                errcode = @"REJECTED_BY_BLACKLIST";
                break;
            case ERRORCODE_TIMEOUT:
                errcode = @"ERRORCODE_TIMEOUT";
                break;
            case SEND_MSG_FREQUENCY_OVERRUN:
                errcode = @"SEND_MSG_FREQUENCY_OVERRUN";
                break;
            case NOT_IN_DISCUSSION:
                errcode = @"NOT_IN_DISCUSSION";
                break;
            case NOT_IN_GROUP:
                errcode = @"NOT_IN_GROUP";
                break;
            case FORBIDDEN_IN_GROUP:
                errcode = @"FORBIDDEN_IN_GROUP";
                break;
            case NOT_IN_CHATROOM:
                errcode = @"NOT_IN_CHATROOM";
                break;
            case FORBIDDEN_IN_CHATROOM:
                errcode = @"FORBIDDEN_IN_CHATROOM";
                break;
            case KICKED_FROM_CHATROOM:
                errcode = @"KICKED_FROM_CHATROOM";
                break;
            case RC_CHATROOM_NOT_EXIST:
                errcode = @"RC_CHATROOM_NOT_EXIST";
                break;
            case RC_CHATROOM_IS_FULL:
                errcode = @"RC_CHATROOM_IS_FULL";
                break;
            case RC_CHANNEL_INVALID:
                errcode = @"RC_CHANNEL_INVALID";
                break;
            case RC_NETWORK_UNAVAILABLE:
                errcode = @"RC_NETWORK_UNAVAILABLE";
                break;
            case CLIENT_NOT_INIT:
                errcode = @"CLIENT_NOT_INIT";
                break;
            case DATABASE_ERROR:
                errcode = @"DATABASE_ERROR";
                break;
            case INVALID_PARAMETER:
                errcode = @"INVALID_PARAMETER";
                break;
            case MSG_ROAMING_SERVICE_UNAVAILABLE:
                errcode = @"MSG_ROAMING_SERVICE_UNAVAILABLE";
                break;
            case INVALID_PUBLIC_NUMBER:
                errcode = @"INVALID_PUBLIC_NUMBER";
                break;
            default:
                errcode = @"OTHER";
                break;
        }
        reject(errcode, errcode, nil);
    };
    
    [[self getClient] setDiscussionName:targetId name:discussionName success:successBlock error:errorBlock];
}

/*!
 设置讨论组是否开放加人权限
 
 @param targetId        讨论组ID
 @param isOpen          是否开放加人权限
 @param successBlock    设置成功的回调
 @param errorBlock      设置失败的回调[status:设置失败的错误码]
 
 @discussion 讨论组默认开放加人权限，即所有成员都可以加人。
 如果关闭加人权限之后，只有讨论组的创建者有加人权限。
 */
RCT_EXPORT_METHOD(setDiscussionInviteStatus:(NSString *)targetId
                  isOpen:(BOOL)isOpen
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    NSLog(@"------------- setDiscussionInviteStatus start discussionId: %@, isOpen:%i -------------------", targetId, isOpen);
    void (^successBlock)(RCDiscussion * disc);
    successBlock = ^(RCDiscussion* disc) {
        if (disc) {
            NSString *discJsonString = [self getDiscJsonStr:disc];
            resolve(discJsonString);
        } else {
            reject(@"NO_RETURN_DISC", @"There were no return disc", nil);
        }
    };
    
    void (^errorBlock)(RCErrorCode status);
    errorBlock = ^(RCErrorCode status) {
        NSString *errcode;
        switch (status) {
            case ERRORCODE_UNKNOWN:
                errcode = @"ERRORCODE_UNKNOWN";
                break;
            case REJECTED_BY_BLACKLIST:
                errcode = @"REJECTED_BY_BLACKLIST";
                break;
            case ERRORCODE_TIMEOUT:
                errcode = @"ERRORCODE_TIMEOUT";
                break;
            case SEND_MSG_FREQUENCY_OVERRUN:
                errcode = @"SEND_MSG_FREQUENCY_OVERRUN";
                break;
            case NOT_IN_DISCUSSION:
                errcode = @"NOT_IN_DISCUSSION";
                break;
            case NOT_IN_GROUP:
                errcode = @"NOT_IN_GROUP";
                break;
            case FORBIDDEN_IN_GROUP:
                errcode = @"FORBIDDEN_IN_GROUP";
                break;
            case NOT_IN_CHATROOM:
                errcode = @"NOT_IN_CHATROOM";
                break;
            case FORBIDDEN_IN_CHATROOM:
                errcode = @"FORBIDDEN_IN_CHATROOM";
                break;
            case KICKED_FROM_CHATROOM:
                errcode = @"KICKED_FROM_CHATROOM";
                break;
            case RC_CHATROOM_NOT_EXIST:
                errcode = @"RC_CHATROOM_NOT_EXIST";
                break;
            case RC_CHATROOM_IS_FULL:
                errcode = @"RC_CHATROOM_IS_FULL";
                break;
            case RC_CHANNEL_INVALID:
                errcode = @"RC_CHANNEL_INVALID";
                break;
            case RC_NETWORK_UNAVAILABLE:
                errcode = @"RC_NETWORK_UNAVAILABLE";
                break;
            case CLIENT_NOT_INIT:
                errcode = @"CLIENT_NOT_INIT";
                break;
            case DATABASE_ERROR:
                errcode = @"DATABASE_ERROR";
                break;
            case INVALID_PARAMETER:
                errcode = @"INVALID_PARAMETER";
                break;
            case MSG_ROAMING_SERVICE_UNAVAILABLE:
                errcode = @"MSG_ROAMING_SERVICE_UNAVAILABLE";
                break;
            case INVALID_PUBLIC_NUMBER:
                errcode = @"INVALID_PUBLIC_NUMBER";
                break;
            default:
                errcode = @"OTHER";
                break;
        }
        reject(errcode, errcode, nil);
    };
    
    [[self getClient] setDiscussionInviteStatus:targetId isOpen:isOpen success:successBlock error:errorBlock];
}



-(RCIMClient *) getClient {
    return [RCIMClient sharedRCIMClient];
}

/*
 将RCDiscussion转化为NSMutableDictionary，以便之后转为json
 */
-(NSMutableDictionary *)convertDisc:(RCDiscussion *)disc{
    NSMutableDictionary *_disc = [self getEmptyBody];
    _disc[@"discussionId"]      = disc.discussionId;
    _disc[@"discussionName"]    = disc.discussionName;
    _disc[@"creatorId"]         = disc.creatorId;
    _disc[@"isOpen"]         = [NSNumber numberWithInt:disc.inviteStatus];
    
    NSData  * memberData = [NSJSONSerialization dataWithJSONObject:disc.memberIdList options:NSJSONWritingPrettyPrinted error: nil ];
    NSString * memberString = [[NSString alloc] initWithData:memberData encoding:NSUTF8StringEncoding];
    
    _disc[@"memberIdList"]      = memberString;
    return _disc;
}

-(NSString *)getDiscJsonStr:(RCDiscussion *) disc{
    NSMutableDictionary * _disc = [self convertDisc:disc];
    NSData  * _discData = [NSJSONSerialization dataWithJSONObject:_disc options:NSJSONWritingPrettyPrinted error: nil ];
    NSString * _discJsonStr = [[NSString alloc] initWithData:_discData encoding:NSUTF8StringEncoding];
    return _discJsonStr;

}

-(NSMutableDictionary *)getEmptyBody {
    NSMutableDictionary *body = @{}.mutableCopy;
    return body;
}

@end
