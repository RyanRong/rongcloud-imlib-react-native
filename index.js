import {
    NativeModules,
    DeviceEventEmitter
} from 'react-native';

const RongCloudIMLib = NativeModules.RongCloudIMLibModule;
const RongCloudDiscLib = NativeModules.RongCloudDiscLibModule;


var _onRongCloudMessageReceived = function(resp) {

}
DeviceEventEmitter.addListener('onRongCloudMessageReceived', resp => {
    typeof _onRongCloudMessageReceived === 'function' && _onRongCloudMessageReceived(resp);
});

const ConversationType = {
    PRIVATE: 'PRIVATE',
    DISCUSSION: 'DISCUSSION',
    SYSTEM: 'SYSTEM'
};

export default {
    ConversationType: ConversationType,
    onReceived (callback) {
        _onRongCloudMessageReceived = callback;
    },
    initWithAppKey (appKey) {
        return RongCloudIMLib.initWithAppKey(appKey);
    },
    connectWithToken (token) {
        return RongCloudIMLib.connectWithToken(token);
    },
    /*!
     断开连接
     @param isReceivePush  [true|false]  App在断开连接之后，是否还接收远程推送.
     [[RCIM sharedRCIM] disconnect:YES]与[[RCIM sharedRCIM] disconnect]完全一致;
     [[RCIM sharedRCIM] disconnect:NO]与[[RCIM sharedRCIM] logout]完全一致.
     因此只封装disconnect:方法，通过传入参数来判断是否仍然接受推送信息。
     */
    disconnect(isReceivePush) {
        return RongCloudIMLib.disconnect(isReceivePush);
    },
    getConnectionStatus(){
      return RongCloudIMLib.getConnectionStatus();
    },
    getCurrentNetworkStatus(){
      return RongCloudIMLib.getCurrentNetworkStatus();
    },
    //获得会话列表
    getConversationList (){
        return RongCloudIMLib.getConversationList();
    },
    //获得会话中的聊天信息
    getRemoteHistoryMessages(RCConversationType, targetId, recordTime, count){
        return RongCloudIMLib.getRemoteHistoryMessages(RCConversationType, targetId, recordTime, count);
    },
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
    getHistoryMessages(conversationType, targetId, oldestMessageId, count){
        return RongCloudIMLib.getHistoryMessages(conversationType, targetId, oldestMessageId, count);
    },
    searchMessages(conversationType, targetId, keyword, count,startTime){
        return RongCloudIMLib.searchMessages(conversationType, targetId, keyword, count,startTime);
    },
    searchConversations(keyword){
        return RongCloudIMLib.searchConversations(keyword);

    },
    /*!
     获取某个会话中指定数量的最新消息实体

     @param conversationType    会话类型
     @param targetId            目标会话ID
     @param count               需要获取的消息数量
     @return                    消息实体RCMessage对象列表

     @discussion 此方法会获取该会话中指定数量的最新消息实体，返回的消息实体按照时间从新到旧排列。
     如果会话中的消息数量小于参数count的值，会将该会话中的所有消息返回。
     */
    getLatestMessages(conversationType, targetId, count){
        return RongCloudIMLib.getLatestMessages(conversationType, targetId, count);
    },

    //发送消息
    sendTextMessage (conversationType, targetId, content) {
        return RongCloudIMLib.sendTextMessage(conversationType, targetId, content, content);
    },

    //发送图片信息
    sendImageMessage(conversationType, targetId, imagePath){
        if(imagePath.startsWith('file://')){
            imagePath = imagePath.substr(7);
        }
        return RongCloudIMLib.sendImageMessage(conversationType, targetId, imagePath, '[图片]');
    },
    sendImageMessageandroid(conversationType, targetId, imagePath){

        return RongCloudIMLib.sendImageMessageandroid(conversationType, targetId, imagePath, '[图片]','[图片]');
    },
    /*!
     获取所有未读消息数量
     */
    getTotalUnreadCount(){
        return RongCloudIMLib.getTotalUnreadCount();
    },
    /*!
     获取某个会话中的未读消息数量
     @param conversationType    会话类型
     @param targetId            目标会话ID
     */
    getUnreadCount(conversationType, targetId){
        return RongCloudIMLib.getUnreadCount(conversationType, targetId);
    },
    /*!
     清除某个会话中的所有未读消息数量
     @param conversationType    会话类型
     @param targetId            目标会话ID
     */
    clearMessagesUnreadStatus(conversationType, targetId){
        return RongCloudIMLib.clearMessagesUnreadStatus(conversationType, targetId);
    },
    removeConversation(conversationType, targetId){
        return RongCloudIMLib.removeConversation(conversationType, targetId);
    },
    /*!
     创建讨论组
     @param name            讨论组名称
     @param userIdList      用户ID的列表

     @discussion 设置的讨论组名称长度不能超过40个字符，否则将会截断为前40个字符。
     */
    createDiscussion(discName, userIdList){
        return RongCloudDiscLib.createDiscussion(discName, userIdList);
    },

    /*!
     讨论组加人，将用户加入讨论组
     @param discussionId    讨论组ID
     @param userIdList      需要加入的用户ID列表
     */
    addMemberToDiscussion(discussionId, userIdList){
        return RongCloudDiscLib.addMemberToDiscussion(discussionId, userIdList);

    },

    /*!
     讨论组踢人，将用户移出讨论组
     @param discussionId    讨论组ID
     @param userId          需要移出的用户ID
     */
    removeMemberFromDiscussion(discussionId, userId){
        return RongCloudDiscLib.removeMemberFromDiscussion(discussionId, userId);
    },

    /*!
     退出当前讨论组
     @param discussionId    讨论组ID
     */
    quitDiscussion(discussionId){
        return RongCloudDiscLib.quitDiscussion(discussionId);
    },

    /*!
     获取讨论组的信息
     @param discussionId    需要获取信息的讨论组ID
     */
    getDiscussion(discussionId){
        return RongCloudDiscLib.getDiscussion(discussionId);
    },

    /*!
     设置讨论组名称
     @param targetId                需要设置的讨论组ID
     @param discussionName          需要设置的讨论组名称，discussionName长度<=40
     */
    setDiscussionName(targetId, name){
        return RongCloudDiscLib.setDiscussionName(targetId, name);
    },

    /*!
     设置讨论组是否开放加人权限
     @param targetId        讨论组ID
     @param isOpen          是否开放加人权限
     @discussion 讨论组默认开放加人权限，即所有成员都可以加人。
     如果关闭加人权限之后，只有讨论组的创建者有加人权限。
     */
    setDiscussionInviteStatus(targetId, isOpen){
        return RongCloudDiscLib.setDiscussionInviteStatus(targetId, isOpen);
    }


};
