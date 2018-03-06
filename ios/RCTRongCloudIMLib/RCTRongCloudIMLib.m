//
//  RCTRongCloudIMLib.m
//  RCTRongCloudIMLib
//
//  Created by lovebing on 3/21/2016.
//  Copyright © 2016 lovebing.org. All rights reserved.
//

#import "RCTRongCloudIMLib.h"


@implementation RCTRongCloudIMLib
@synthesize bridge = _bridge;

RCT_EXPORT_MODULE(RongCloudIMLibModule)


RCT_EXPORT_METHOD(initWithAppKey:(NSString *) appkey) {
    NSLog(@"initWithAppKey %@", appkey);
    [[self getClient] initWithAppKey:appkey];

    [[self getClient] setReceiveMessageDelegate:self object:nil];
}

RCT_EXPORT_METHOD(setDeviceToken:(NSString *) deviceToken) {
    [[self getClient] setDeviceToken:deviceToken];
}

RCT_EXPORT_METHOD(connectWithToken:(NSString *) token
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    NSLog(@"connectWithToken %@", token);
    //NSLog(@"connect_status %ld", (long)[[self getClient] getConnectionStatus]);

    void (^successBlock)(NSString *userId);
    successBlock = ^(NSString* userId) {
        NSArray *events = [[NSArray alloc] initWithObjects:userId,nil];
        resolve(@[[NSNull null], events]);
    };

    void (^errorBlock)(RCConnectErrorCode status);
    errorBlock = ^(RCConnectErrorCode status) {
        NSString *errcode;
        switch (status) {
            case RC_CONN_ID_REJECT:
                errcode = @"RC_CONN_ID_REJECT";
                break;
            case RC_CONN_TOKEN_INCORRECT:
                errcode = @"RC_CONN_TOKEN_INCORRECT";
                break;
            case RC_CONN_NOT_AUTHRORIZED:
                errcode = @"RC_CONN_NOT_AUTHRORIZED";
                break;
            case RC_CONN_PACKAGE_NAME_INVALID:
                errcode = @"RC_CONN_PACKAGE_NAME_INVALID";
                break;
            case RC_CONN_APP_BLOCKED_OR_DELETED:
                errcode = @"RC_CONN_APP_BLOCKED_OR_DELETED";
                break;
            case RC_DISCONN_KICK:
                errcode = @"RC_DISCONN_KICK";
                break;
            case RC_CLIENT_NOT_INIT:
                errcode = @"RC_CLIENT_NOT_INIT";
                break;
            case RC_INVALID_PARAMETER:
                errcode = @"RC_INVALID_PARAMETER";
                break;
            case RC_INVALID_ARGUMENT:
                errcode = @"RC_INVALID_ARGUMENT";
                break;

            default:
                errcode = @"OTHER";
                break;
        }
        reject(errcode, errcode, nil);
    };
    void (^tokenIncorrectBlock)();
    tokenIncorrectBlock = ^() {
        reject(@"TOKEN_INCORRECT", @"tokenIncorrect", nil);
    };

    NSInteger connectStatus = [[self getClient] getConnectionStatus];

    if(connectStatus != ConnectionStatus_Connected
       && connectStatus != ConnectionStatus_Connecting){
        [[self getClient] connectWithToken:token success:successBlock error:errorBlock tokenIncorrect:tokenIncorrectBlock];
    }
    else if(connectStatus == ConnectionStatus_Connected){
        // resolve(@[[NSNull null], @"ConnectionStatus_Connected"]);
        reject(@"ConnectionStatus_Connected", @"ConnectionStatus_Connected", nil);
    }
    else if(connectStatus == ConnectionStatus_Connecting){
        reject(@"ConnectionStatus_Connecting", @"ConnectionStatus_Connecting", nil);
    }

    //NSLog(@"connect_status %ld", (long)[[self getClient] getConnectionStatus]);

}

RCT_EXPORT_METHOD(sendTextMessage:(NSString *)type
                  targetId:(NSString *)targetId
                  content:(NSString *)content
                  pushContent:(NSString *) pushContent
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {

    RCTextMessage *messageContent = [RCTextMessage messageWithContent:content];
    [self sendMessage:type targetId:targetId content:messageContent pushContent:pushContent resolve:resolve reject:reject];


}

RCT_EXPORT_METHOD(sendImageMessage:(NSString *)type
                  targetId:(NSString *)targetId
                  imagePath:(NSString *) imagePath
                  pushContent:(NSString *) pushContent
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
//    imagePath = [imagePath substringFromIndex:7];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    RCImageMessage * messageContent = [RCImageMessage messageWithImage:image];
//
//    RCImageMessage *messageContent = [RCImageMessage messageWithImageURI:imagePath];
//    messageContent.originalImage = image;

    [self sendImageMsg:type targetId:targetId content:messageContent pushContent:pushContent resolve:resolve reject:reject];
}

RCT_EXPORT_METHOD(getSDKVersion:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    NSString* version = [[self getClient] getSDKVersion];
    resolve(version);
}

- (RCConnectionStatus)getResolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject{

    return  [RCIMClient sharedRCIMClient].getConnectionStatus;
}

RCT_EXPORT_METHOD(disconnect:(BOOL)isReceivePush
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject
                                            ) {
    @try {
        [[self getClient] disconnect:isReceivePush];
        resolve(@[[NSNull null], @"disconnect success"]);
    }
    @catch (NSException *exception) {
        reject(@"disconnect fail", @"disconnect fail", nil);
    }
}

RCT_EXPORT_METHOD(getConnectionStatus:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    @try {
        RCConnectionStatus status = [[self getClient] getConnectionStatus];
        resolve(@(status));

    } @catch (NSException *exception) {
        reject(@"status fail", nil,  nil);
    } @finally {

    }
}

RCT_EXPORT_METHOD(getCurrentNetworkStatus:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    @try {
        RCNetworkStatus status = [[self getClient] getCurrentNetworkStatus];
        resolve(@(status));

    } @catch (NSException *exception) {
        reject(@"status fail", nil,  nil);
    } @finally {

    }
}


RCT_EXPORT_METHOD(getConversationList:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {

    NSArray *conversationList = [[self getClient]
                                 getConversationList:@[@(ConversationType_PRIVATE),
                                                       @(ConversationType_DISCUSSION),
                                                       @(ConversationType_GROUP),
                                                       @(ConversationType_SYSTEM),
                                                       @(ConversationType_APPSERVICE),
                                                       @(ConversationType_PUBLICSERVICE)]];

    NSMutableArray * arr = [[NSMutableArray alloc] init];


    for (RCConversation *conversation in conversationList) {

        //最后一条消息的发送日期
        //            NSDate*detaildate=[NSDate dateWithTimeIntervalSince1970:conversation.receivedTime];
        NSNumber * receivedTime     =   [NSNumber numberWithLongLong: conversation.receivedTime];
        NSNumber * converstationType=   [NSNumber numberWithUnsignedInteger:conversation.conversationType];
        NSNumber * unreadMsgCount   =   [NSNumber numberWithLongLong: conversation.unreadMessageCount];
        NSString * isTop            =   conversation.isTop?@"1":@"0";

        //组织会话json对象
        NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:conversation.targetId ,         @"targetId",
                                   converstationType,              @"conversationType",
                                   conversation.conversationTitle, @"conversationTitle",
                                   receivedTime,                   @"lastMessageTime",
                                   unreadMsgCount,                 @"unreadMsgCount",
                                   isTop,                          @"isTop", nil];


        if([conversation.lastestMessage isMemberOfClass:[RCTextMessage class]]){
            RCTextMessage *testMessage = (RCTextMessage*)conversation.lastestMessage;
            dict[@"lastestMessage"] = [testMessage content];
            dict[@"lastestMessagetype"] = @"text";

        }
        else if([conversation.lastestMessage isMemberOfClass:[RCImageMessage class]]) {
            dict[@"lastestMessage"] = @"[图片]";
            dict[@"lastestMessagetype"] = @"image";
        }else{
            dict[@"lastestMessage"] = @"你收到一条消息";
            dict[@"lastestMessagetype"] = @"others";
        }
        [arr addObject:dict];

    }

    //格式化会话json对象
    NSData  * jsonData = [NSJSONSerialization dataWithJSONObject:arr options:NSJSONWritingPrettyPrinted error: nil ];


    NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];


    resolve(jsonString);

}

/*!
 从服务器端获取之前的历史消息

 @param conversationType    会话类型，不支持聊天室会话类型
 @param targetId            目标会话ID
 @param recordTime          最早的发送时间，第一次可以传0
 @param count               需要获取的消息数量， 0< count <= 20
 @param successBlock        获取成功的回调 [messages:获取到的历史消息数组]
 @param errorBlock          获取失败的回调 [status:获取失败的错误码]

 @discussion 此方法从服务器端获取之前的历史消息，但是必须先开通历史消息云存储功能。
 */
RCT_EXPORT_METHOD(getRemoteHistoryMessages:(int)conversationType
                  targetId:(NSString *)targetId
                  recordTime:(NSUInteger *)recordTime
                  count:(int)count
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject){

    void (^successBlock)(NSArray *messages);
    successBlock = ^(NSArray *messages) {
        NSArray *events = [[NSArray alloc] initWithObjects:messages,nil];
        resolve(@[[NSNull null], events]);
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

    [[self getClient] getRemoteHistoryMessages: conversationType targetId:targetId recordTime:recordTime count:count success:successBlock error:errorBlock];
}

/*!
 获取某个会话中指定数量的最新消息实体

 @param conversationType    会话类型
 @param targetId            目标会话ID
 @param count               需要获取的消息数量
 @return                    消息实体RCMessage对象列表

 @discussion 此方法会获取该会话中指定数量的最新消息实体，返回的消息实体按照时间从新到旧排列。
 如果会话中的消息数量小于参数count的值，会将该会话中的所有消息返回。
 */
RCT_EXPORT_METHOD(getLatestMessages:(int)conversationType
                  targetId:(NSString *)targetId
                  count:(int)count
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject){
    NSLog(@"-------------getLatestMessages start--------------");

    NSArray *msgArray = [[self getClient] getLatestMessages:conversationType targetId:targetId count:count];
    if (msgArray) {
        NSLog(@"msg:  %@", msgArray);
        NSString *msgJsonString = [self convertMsgList:msgArray];
        NSLog(@"msg:  %@", msgJsonString);
        resolve(msgJsonString);
    } else {
        reject(@"no_lastest_local_msg", @"There were no lastest local msg", nil);
    }
    NSLog(@"-------------getLatestMessages End--------------");
}

/*!
 获取会话中，从指定消息之前、指定数量的最新消息实体

 @param conversationType    会话类型
 @param targetId            目标会话ID
 @param oldestMessageId     截止的消息ID
 @param count               需要获取的消息数量
 @return                    消息实体RCMessage对象列表

 @discussion 此方法会获取该会话中，oldestMessageId之前的、指定数量的最新消息实体，返回的消息实体按照时间从新到旧排列。
 返回的消息中不包含oldestMessageId对应那条消息，如果会话中的消息数量小于参数count的值，会将该会话中的所有消息返回。
 如：
 oldestMessageId为10，count为2，会返回messageId为9和8的RCMessage对象列表。
 */
RCT_EXPORT_METHOD(getHistoryMessages:(int)conversationType
                  targetId:(NSString *)targetId
                  oldestMessageId:(int)oldestMessageId
                  count:(int)count
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject){
    NSLog(@"-------------getHistoryMessage start--------------");

    NSArray *msgArray = [[self getClient] getHistoryMessages:conversationType targetId:targetId oldestMessageId:oldestMessageId count:count];
    if (msgArray) {
        NSLog(@"msg:  %@", msgArray);
        NSString *msgJsonString = [self convertMsgList:msgArray];
        NSLog(@"msg:  %@", msgJsonString);
        resolve(msgJsonString);
    } else {
        reject(@"no_local_msg", @"There were no local msg", nil);
    }
    NSLog(@"-------------getHistoryMessages End--------------");
}
RCT_EXPORT_METHOD(searchMessages:(int)conversationType
                  targetId:(NSString *)targetId
                  keyword:(NSString *)keyword
                  count:(int)count
                  startTime:(int)startTime
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject){
    NSLog(@"-------------getHistoryMessage start--------------");

    NSArray *msgArray = [[self getClient] searchMessages:conversationType targetId:targetId keyword:keyword count:count startTime:startTime];
    if (msgArray) {
        NSLog(@"msg:  %@", msgArray);
        NSString *msgJsonString = [self convertMsgList:msgArray];
        NSLog(@"msg:  %@", msgJsonString);
        resolve(msgJsonString);
    } else {
        reject(@"no_local_msg", @"There were no local msg", nil);
    }
    NSLog(@"-------------getHistoryMessages End--------------");
}
RCT_EXPORT_METHOD(searchConversations: (NSString *)keyword
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject){
    NSLog(@"-------------getHistoryMessage start--------------");
    NSNumber * intNumber1 = [[NSNumber alloc] initWithInt:1];
    NSNumber * intNumber2 = [[NSNumber alloc] initWithInt:2];
    NSNumber * intNumber3 = [[NSNumber alloc] initWithInt:6];
    NSArray *typeArray = @[intNumber1, intNumber2,intNumber3];
    NSArray *array3 = @[@"RC:TxtMsg", @"RC:TxtMsg"];
    NSArray *msgArray = [[self getClient] searchConversations:typeArray messageType:array3 keyword:keyword   ];
    if (msgArray) {
        NSLog(@"msg:  %@", msgArray);
        NSString *msgJsonString = [self convertMsgresultList:msgArray];
        NSLog(@"msg:  %@", msgJsonString);
        resolve(msgJsonString);

    } else {
        reject(@"no_local_msg", @"There were no local msg", nil);
    }
    NSLog(@"-------------getHistoryMessages End--------------");
}
/*!
 获取所有未读消息数量
 */
RCT_EXPORT_METHOD(getTotalUnreadCount:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject){
    NSLog(@"-------------getUnreadCount start--------------");
    int count = [[self getClient] getTotalUnreadCount];
    resolve([NSNumber numberWithUnsignedInteger:count]);
    NSLog(@"-------------getUnreadCount end--------------");
}


/*!
 获取某个会话中的未读消息数量
 @param conversationType    会话类型
 @param targetId            目标会话ID
 */
RCT_EXPORT_METHOD(getUnreadCount:(NSString *)type
                  targetId:(NSString *)targetId
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject){
    NSLog(@"-------------getUnreadCount start--------------");
    int count = [[self getClient] getUnreadCount:[self getConversationType:type] targetId:targetId];
    resolve([NSNumber numberWithUnsignedInteger:count]);
    NSLog(@"-------------getUnreadCount end--------------");
}


/*!
 清除某个会话中的所有未读消息数量
 @param conversationType    会话类型
 @param targetId            目标会话ID
 */
RCT_EXPORT_METHOD(clearMessagesUnreadStatus:(NSString *)type
                  targetId:(NSString *)targetId
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject){

    @try {
        bool result = [[self getClient] clearMessagesUnreadStatus:[self getConversationType:type] targetId:targetId];
        if(result)
            resolve(@[[NSNull null], @"discoclearMessagesUnreadStatusnnect success"]);
        else
            reject(@"discoclearMessagesUnreadStatusnnect fail", @"discoclearMessagesUnreadStatusnnect fail", nil);
    }
    @catch (NSException *exception) {
        reject(@"discoclearMessagesUnreadStatusnnect fail", @"discoclearMessagesUnreadStatusnnect fail", nil);
    }

}
RCT_EXPORT_METHOD(removeConversation:(NSString *)type
                  targetId:(NSString *)targetId
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject){

    @try {
        bool result = [[self getClient] removeConversation:[self getConversationType:type] targetId:targetId];
        if(result)
            resolve(@[[NSNull null], @"removeConversation success"]);
        else
            reject(@"removeConversation fail", @"removeConversation fail", nil);
    }
    @catch (NSException *exception) {
        reject(@"removeConversation fail", @"removeConversation fail", nil);
    }

}


-(RCIMClient *) getClient {
    return [RCIMClient sharedRCIMClient];
}

/**
 将js字符转化为conversationType
 */
-(RCConversationType) getConversationType:(NSString *) type{
    RCConversationType conversationType;
    if([type isEqualToString:@"PRIVATE"]) {
        conversationType = ConversationType_PRIVATE;
    }
    else if([type isEqualToString:@"DISCUSSION"]) {
        conversationType = ConversationType_DISCUSSION;
    }
    else {
        conversationType = ConversationType_SYSTEM;
    }
    return conversationType;
}
/*
    发送文本信息
 */
-(void)sendMessage:(NSString *)type
          targetId:(NSString *)targetId
           content:(RCMessageContent *)content
       pushContent:(NSString *) pushContent
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject {

    RCConversationType conversationType = [self getConversationType:type];
//    if([type isEqualToString:@"PRIVATE"]) {
//        conversationType = ConversationType_PRIVATE;
//    }
//    else if([type isEqualToString:@"DISCUSSION"]) {
//        conversationType = ConversationType_DISCUSSION;
//    }
//    else {
//        conversationType = ConversationType_SYSTEM;
//    }

    void (^successBlock)(long messageId);
    successBlock = ^(long messageId) {
        NSString* id = [NSString stringWithFormat:@"%ld",messageId];
        resolve(id);
    };

    void (^errorBlock)(RCErrorCode nErrorCode , long messageId);
    errorBlock = ^(RCErrorCode nErrorCode , long messageId) {
        reject(nil, nil, nil);
    };


    [[self getClient] sendMessage:conversationType targetId:targetId content:content pushContent:pushContent success:successBlock error:errorBlock];

}

/*
 发送图片信息
 */
-(void)sendImageMsg:(NSString *)type
          targetId:(NSString *)targetId
           content:(RCMessageContent *)content
       pushContent:(NSString *) pushContent
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject {

    RCConversationType conversationType;
    if([type isEqualToString:@"PRIVATE"]) {
        conversationType = ConversationType_PRIVATE;
    }
    else if([type isEqualToString:@"DISCUSSION"]) {
        conversationType = ConversationType_DISCUSSION;
    }
    else {
        conversationType = ConversationType_SYSTEM;
    }

    void (^successBlock)(long messageId);
    successBlock = ^(long messageId) {
        NSString* id = [NSString stringWithFormat:@"%ld",messageId];
        resolve(id);
    };

    void (^errorBlock)(RCErrorCode nErrorCode , long messageId);
    errorBlock = ^(RCErrorCode nErrorCode , long messageId) {
        reject(nil, nil, nil);
    };

    void (^processBlock)(int progress, long messageId);
    processBlock = ^(int progress, long messageId) {
        //processFunc(progress, messageId);
        NSLog(@"------upload image loading %d--------",progress);
    };


    [[self getClient] sendImageMessage:conversationType targetId:targetId content:content pushContent:pushContent progress:processBlock success:successBlock error:errorBlock];

}

-(void)onReceived:(RCMessage *)message
             left:(int)nLeft
           object:(id)object {

    NSLog(@"onRongCloudMessageReceived");

    NSMutableDictionary *body = [self getEmptyBody];
    NSMutableDictionary *_message = [self getEmptyBody];
    _message[@"targetId"] = message.targetId;
    _message[@"senderUserId"] = message.senderUserId;
    _message[@"messageId"] = [NSString stringWithFormat:@"%ld",message.messageId];
    _message[@"sentTime"] = [NSString stringWithFormat:@"%lld",message.sentTime];
    _message[@"conversationType"] = [NSString stringWithFormat:@"%ld",message.conversationType];
    if ([message.content isMemberOfClass:[RCTextMessage class]]) {
        RCTextMessage *testMessage = (RCTextMessage *)message.content;
        _message[@"content"] = testMessage.content;
    }
    else if([message.content isMemberOfClass:[RCImageMessage class]]) {
        RCImageMessage *imageMessage = (RCImageMessage *)message.content;
        _message[@"imageUrl"] = imageMessage.imageUrl;
        _message[@"thumbnailImage"] = imageMessage.thumbnailImage;
    }
    else if([message.content isMemberOfClass:[RCRichContentMessage class]]) {
        RCRichContentMessage *richMessage = (RCRichContentMessage *)message.content;
    }


    body[@"left"] = [NSString stringWithFormat:@"%d",nLeft];
    body[@"message"] = _message;
    body[@"errcode"] = @"0";

    [self sendEvent:@"onRongCloudMessageReceived" body:body];
}
/*
    将RCMessage转化为NSMutableDictionary，以便之后转为json
 */
-(NSMutableDictionary *)convertMessage:(RCMessage *)message{
    NSMutableDictionary *_message = [self getEmptyBody];
    _message[@"targetId"] = message.targetId;
    _message[@"senderUserId"] = message.senderUserId;
    _message[@"messageId"] = [NSString stringWithFormat:@"%ld",message.messageId];
    _message[@"sentTime"] = [NSString stringWithFormat:@"%lld",message.sentTime];
    _message[@"sentStatus"] = [NSString stringWithFormat:@"%lu",message.sentStatus];

    if ([message.content isMemberOfClass:[RCTextMessage class]]) {
        RCTextMessage *testMessage = (RCTextMessage *)message.content;
        _message[@"content"] = testMessage.content;
    }
    else if([message.content isMemberOfClass:[RCImageMessage class]]) {
        RCImageMessage *imageMessage = (RCImageMessage *)message.content;
        _message[@"imageUrl"] = imageMessage.imageUrl;
        /*imageMessage.thumbnailImage 是一个UIImage对象，不能直接这样json化
         *如果需要缩略图信息，请将UIImage对象摊开JSON化
         */
//        _message[@"thumbnailImage"] = imageMessage.thumbnailImage;

    }
    return _message;
}
-(NSMutableDictionary *)convertsearchMessage:(RCSearchConversationResult *)message{
    NSMutableDictionary *_message = [self getEmptyBody];

    _message[@"conversationType"]=  [NSNumber numberWithUnsignedInteger:message.conversation.conversationType];
    _message[@"targetId"]=  message.conversation.targetId;
    _message[@"lastMessageTime"] = [NSNumber numberWithLongLong:message.conversation.receivedTime];
    _message[@"conversationTitle"] = message.conversation.conversationTitle;
    _message[@"senderUserId"] = message.conversation.senderUserId;
    _message[@"sentTime"] = [NSNumber numberWithLongLong:message.conversation.sentTime];
    _message[@"sentStatus"] = [NSString stringWithFormat:@"%lu",message.conversation.sentStatus];


    if ([message.conversation.lastestMessage isMemberOfClass:[RCTextMessage class]]) {
        RCTextMessage *testMessage = (RCTextMessage *)message.conversation.lastestMessage;
        _message[@"lastestMessage"] = testMessage.content;
    }
    else if([message.conversation.lastestMessage isMemberOfClass:[RCImageMessage class]]) {
        RCImageMessage *imageMessage = (RCImageMessage *)message.conversation.lastestMessage;
        _message[@"imageUrl"] = imageMessage.imageUrl;
        /*imageMessage.thumbnailImage 是一个UIImage对象，不能直接这样json化
         *如果需要缩略图信息，请将UIImage对象摊开JSON化
         */
        //        _message[@"thumbnailImage"] = imageMessage.thumbnailImage;

    }
    return _message;
}
/*
    将RCMessage的NSArray转为jsonString
 */
-(NSString *)convertMsgList:(NSArray *) msgList{

    NSMutableArray * arr = [[NSMutableArray alloc] init];

    for(RCMessage * message in msgList){
        NSMutableDictionary *dict = [self convertMessage: message];
        [arr addObject: dict];
    }
    NSData  * jsonData = [NSJSONSerialization dataWithJSONObject:arr options:NSJSONWritingPrettyPrinted error: nil ];
    NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

-(NSString *)convertMsgresultList:(NSArray *) msgList{

    NSMutableArray * arr = [[NSMutableArray alloc] init];
    //这里的message就是RCSearchConversationResult的对象了
    for(RCSearchConversationResult * message in msgList){
        NSMutableDictionary *dict = [self convertsearchMessage: message];
        [arr addObject: dict];
    }
    NSData  * jsonData = [NSJSONSerialization dataWithJSONObject:arr options:NSJSONWritingPrettyPrinted error: nil ];
    NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

-(NSMutableDictionary *)getEmptyBody {
    NSMutableDictionary *body = @{}.mutableCopy;
    return body;
}

-(void)sendEvent:(NSString *)name body:(NSMutableDictionary *)body {

    [self.bridge.eventDispatcher sendDeviceEventWithName:name body:body];
}

@end
