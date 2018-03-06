package org.lovebing.reactnative.rongcloud;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.support.annotation.Nullable;
import android.support.v4.app.NotificationCompat;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.modules.core.RCTNativeAppEventEmitter;

import java.util.List;

import io.rong.imlib.RongIMClient;
import io.rong.imlib.model.Conversation;
import io.rong.imlib.model.Message;
import io.rong.imlib.model.MessageContent;
import io.rong.imlib.model.SearchConversationResult;
import io.rong.message.ImageMessage;
import io.rong.message.TextMessage;

/**
 * Created by lovebing on 3/25/16.
 */
public class RongCloudIMLibModule extends ReactContextBaseJavaModule implements RongIMClient.OnReceiveMessageListener, RongIMClient.ConnectionStatusListener, LifecycleEventListener {

    protected ReactApplicationContext context;
    boolean hostActive = true;

    /**
     * @param reactContext
     */
    public RongCloudIMLibModule(ReactApplicationContext reactContext) {
        super(reactContext);
        context = reactContext;
    }

    @Override
    public void onHostResume() {
        this.hostActive = true;
    }

    @Override
    public void onHostPause() {
        this.hostActive = false;
    }

    @Override
    public String getName() {
        return "RongCloudIMLibModule";
    }

    @Override
    public void onHostDestroy() {

    }

    private void sendDeviceEvent(String type, Object arg) {
        ReactContext context = this.getReactApplicationContext();
        context.getJSModule(RCTNativeAppEventEmitter.class)
                .emit(type, arg);

    }

    @Override
    public void onChanged(ConnectionStatus connectionStatus) {
        WritableMap map = Arguments.createMap();
        map.putInt("code", connectionStatus.getValue());
        map.putString("message", connectionStatus.getMessage());
        this.sendDeviceEvent("rongIMConnectionStatus", map);
    }

    @Override
    public boolean onReceived(Message message, int i) {
        sendDeviceEvent("onRongCloudMessageReceived", Utils.convertMessage(message));

        if (!hostActive) {
            Context context = getReactApplicationContext();
            NotificationManager mNotificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
            NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(context);
            MessageContent content = message.getContent();
            String title = content.getUserInfo() != null ? content.getUserInfo().getName() : message.getSenderUserId();

            String contentString = Utils.convertMessageContentToString(content);
            mBuilder.setSmallIcon(context.getApplicationInfo().icon)
                    .setContentTitle(title)
                    .setContentText(contentString)
                    .setTicker(contentString)
                    .setAutoCancel(true)
                    .setDefaults(Notification.DEFAULT_ALL);

            Intent intent = new Intent();
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            Uri.Builder builder = Uri.parse("rong://" + context.getPackageName()).buildUpon();

            builder.appendPath("conversation").appendPath(message.getConversationType().getName())
                    .appendQueryParameter("targetId", message.getTargetId())
                    .appendQueryParameter("title", message.getTargetId());
            intent.setData(builder.build());
            mBuilder.setContentIntent(PendingIntent.getActivity(context, 0, intent, 0));

            Notification notification = mBuilder.build();
            mNotificationManager.notify(1000, notification);
        }
        return true;
    }

    @ReactMethod
    public void initWithAppKey(String appKey) {
        RongIMClient.init(context, appKey);
    }


    @ReactMethod
    public void connectWithToken(String token, final Promise promise) {
        final RongCloudIMLibModule instance = this;

        RongIMClient.setOnReceiveMessageListener(new RongIMClient.OnReceiveMessageListener() {
            @Override
            public boolean onReceived(Message message, int i) {

                WritableMap map = Arguments.createMap();
                WritableMap msg = instance.formatMessage(message);

                map.putMap("message", msg);
                map.putString("left", "0");
                map.putString("errcode", "0");

                instance.sendEvent("onRongCloudMessageReceived", map);
                return true;
            }
        });

        RongIMClient.connect(token, new RongIMClient.ConnectCallback() {

            /**
             * Token 错误，在线上环境下主要是因为 Token 已经过期，您需要向 App Server 重新请求一个新的 Token
             */
            @Override
            public void onTokenIncorrect() {
                promise.reject("-1", "tokenIncorrect");
            }

            /**
             * 连接融云成功
             * @param userid 当前 token
             */
            @Override
            public void onSuccess(String userid) {
                WritableMap map = Arguments.createMap();
                map.putString("userid", userid);
                promise.resolve(map);
            }

            /**
             * 连接融云失败
             * @param errorCode 错误码，可到官网 查看错误码对应的注释
             */
            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                String code = errorCode.getValue() + "";
                String msg = errorCode.getMessage();
                promise.reject(code, msg);
            }
        });
    }

    @ReactMethod
    public void getConnectionStatus(final Promise promise) {
        WritableMap map = Arguments.createMap();
        ConnectionStatus connectionStatus = RongIMClient.getInstance().getCurrentConnectionStatus();
        map.putInt("code", connectionStatus.getValue());
        map.putString("message", connectionStatus.getMessage());
        promise.resolve(map);
    }

    @ReactMethod
    public void disconnect(boolean data, final Promise promise) {
        WritableArray array = Arguments.createArray();
        RongIMClient.getInstance().disconnect();
        array.pushNull();
        array.pushString("disconnect success");
        promise.resolve(array);
    }

    @ReactMethod
    public void getConversationList(final Promise promise) {

        RongIMClient.getInstance().getConversationList(new RongIMClient.ResultCallback<List<Conversation>>() {

            @Override
            public void onSuccess(List<Conversation> conversations) {
                promise.resolve(Utils.convertConversationList(conversations));
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                promise.reject("" + errorCode.getValue(), errorCode.getMessage());
            }
        });
    }

    @ReactMethod
    public void removeConversation(String type, String targetId, final Promise promise) {

        RongIMClient.getInstance().removeConversation(Conversation.ConversationType.valueOf(type.toUpperCase()), targetId, new RongIMClient.ResultCallback<Boolean>() {

            @Override
            public void onSuccess(Boolean aBoolean) {
                promise.resolve(null);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                promise.reject("" + errorCode.getValue(), errorCode.getMessage());
            }
        });
    }

    @ReactMethod
    public void clearMessagesUnreadStatus(String type, String targetId, final Promise promise) {

        RongIMClient.getInstance().clearMessagesUnreadStatus(Conversation.ConversationType.valueOf(type.toUpperCase()), targetId, new RongIMClient.ResultCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean aBoolean) {
                promise.resolve(null);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                promise.reject("" + errorCode.getValue(), errorCode.getMessage());
            }
        });
    }

    @ReactMethod
    public void getTotalUnreadCount(final Promise promise) {
        RongIMClient.getInstance().getTotalUnreadCount(new RongIMClient.ResultCallback<Integer>() {
            @Override
            public void onSuccess(Integer num) {
//                WritableMap map = Arguments.createMap();
//                map.putInt("unreadMsgCount", num);
                promise.resolve(num);

            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                promise.reject("" + errorCode.getValue(), errorCode.getMessage());
            }
        });
    }

    @ReactMethod
    public void getLocalLatestMessages(String type, String targetId, int count, final Promise promise) {
        Conversation.ConversationType conversationType = ConversationType(type);
        RongIMClient.getInstance().getLatestMessages(conversationType, targetId, count, new RongIMClient.ResultCallback<List<Message>>() {
            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                promise.reject(errorCode.getValue() + "", errorCode.getMessage());
            }


            @Override
            public void onSuccess(List<Message> messages) {
                WritableArray data = Arguments.createArray();
                if (messages != null && !messages.isEmpty()) {
                    for (int i = 0; i < messages.size(); i++) {
                        Message message = messages.get(i);
                        WritableMap item = formatMessage(message);
                        data.pushMap(item);
                    }
                }
                promise.resolve(data);
            }
        });
    }

    @ReactMethod
    public void getLatestMessages(String type, String targetId, int count, final Promise promise) {
        RongIMClient.getInstance().getLatestMessages(Conversation.ConversationType.valueOf(type.toUpperCase()),
                targetId, count, new RongIMClient.ResultCallback<List<Message>>() {

                    @Override
                    public void onSuccess(List<Message> messages) {
                        promise.resolve(Utils.convertMessageList(messages));
                    }

                    @Override
                    public void onError(RongIMClient.ErrorCode errorCode) {
                        promise.reject("" + errorCode.getValue(), errorCode.getMessage());
                    }
                });
    }

    @ReactMethod
    public void searchMessages(String type, String targetId, String keyword, int count, int beginTime, final Promise promise) {

        RongIMClient.getInstance().searchMessages(Conversation.ConversationType.valueOf(type.toUpperCase()),
                targetId, keyword, count, beginTime, new RongIMClient.ResultCallback<List<Message>>() {

                    @Override
                    public void onSuccess(List<Message> messages) {
                        promise.resolve(Utils.convertMessageList(messages));
                    }

                    @Override
                    public void onError(RongIMClient.ErrorCode errorCode) {
                        promise.reject("" + errorCode.getValue(), errorCode.getMessage());
                    }
                });
    }

    @ReactMethod
    public void searchConversations(String keyword, final Promise promise) {


        Conversation.ConversationType type[] = new Conversation.ConversationType[]{Conversation.ConversationType.DISCUSSION, Conversation.ConversationType.PRIVATE};
        String objectNames[] = new String[]{"RC:TxtMsg", "RC:TxtMsg"};
        RongIMClient.getInstance().searchConversations(keyword, type,
                objectNames, new RongIMClient.ResultCallback<List<SearchConversationResult>>() {

                    @Override
                    public void onSuccess(List<SearchConversationResult> searchConversationResults) {
                        promise.resolve(Utils.convertsearchConversationResultsList(searchConversationResults));

                    }

                    @Override
                    public void onError(RongIMClient.ErrorCode errorCode) {
                        promise.reject("" + errorCode.getValue(), errorCode.getMessage());
                    }
                });
    }

    @ReactMethod
    public void getHistoryMessages(String type, String targetId, int oldestMessageId, int count, final Promise promise) {

        RongIMClient.getInstance().getHistoryMessages(Conversation.ConversationType.valueOf(type.toUpperCase()),
                targetId, oldestMessageId, count, new RongIMClient.ResultCallback<List<Message>>() {

                    @Override
                    public void onSuccess(List<Message> messages) {
                        promise.resolve(Utils.convertMessageList(messages));
                    }

                    @Override
                    public void onError(RongIMClient.ErrorCode errorCode) {
                        promise.reject("" + errorCode.getValue(), errorCode.getMessage());
                    }
                });
    }

    @ReactMethod
    public void sendTextMessage(final String type, final String targetId, final String content,
                                final String pushContent, final Promise promise) {
        TextMessage ret = new TextMessage(content);
        RongIMClient.getInstance().sendMessage(
                Conversation.ConversationType.valueOf(type.toUpperCase()),
                targetId, ret, pushContent, "",
                new RongIMClient.SendMessageCallback() {
                    @Override
                    public void onError(Integer messageId, RongIMClient.ErrorCode e) {
                        WritableMap ret = Arguments.createMap();
                        ret.putInt("messageId", messageId);
                        ret.putInt("errCode", e.getValue());
                        ret.putString("errMsg", e.getMessage());
                        sendDeviceEvent("msgSendFailed", ret);
                    }

                    @Override
                    public void onSuccess(Integer messageId) {
                        sendDeviceEvent("msgSendOk", messageId);

                    }

                }, new RongIMClient.ResultCallback<Message>() {
                    @Override
                    public void onError(RongIMClient.ErrorCode errorCode) {
                        promise.reject("" + errorCode.getValue(), errorCode.getMessage());
                    }

                    @Override
                    public void onSuccess(Message message) {
                        promise.resolve(Utils.convertMessage(message));
                    }

                });
    }

    @ReactMethod
    public void sendImageMessageandroid(final String type, final String targetId, final String imagePath,
                                        final String pushContent, final String pushData, final Promise promise) {

        Utils.getImage(Uri.parse(imagePath), null, new Utils.ImageCallback() {

            @Override
            public void invoke(@Nullable Bitmap bitmap) {
                if (bitmap == null) {
                    promise.reject("loadImageFailed", "Cannot open image uri ");
                    return;
                }
                MessageContent content;
                try {
                    content = Utils.convertImageMessageContent(getReactApplicationContext(), bitmap);
                } catch (Throwable e) {
                    promise.reject("cacheImageFailed", e);
                    return;
                }
                RongIMClient.getInstance().sendImageMessage(
                        Conversation.ConversationType.valueOf(type.toUpperCase()),
                        targetId, content, pushContent, pushData,
                        new RongIMClient.SendImageMessageCallback() {

                            @Override
                            public void onAttached(Message message) {
                                promise.resolve(Utils.convertMessage(message));
                            }

                            @Override
                            public void onError(Message message, RongIMClient.ErrorCode e) {
                                WritableMap ret = Arguments.createMap();
                                ret.putInt("messageId", message.getMessageId());
                                ret.putInt("errCode", e.getValue());
                                ret.putString("errMsg", e.getMessage());
                                sendDeviceEvent("msgSendFailed", ret);
                            }

                            @Override
                            public void onSuccess(Message message) {
                                sendDeviceEvent("msgSendOk", message.getMessageId());
                            }

                            @Override
                            public void onProgress(Message message, int i) {

                            }
                        });
            }
        });

    }

    /**
     * @param message
     * @return
     */
    protected WritableMap formatMessage(Message message) {
        WritableMap msg = Arguments.createMap();

        msg.putString("targetId", message.getTargetId());
        msg.putString("senderUserId", message.getSenderUserId());
        msg.putString("messageId", message.getMessageId() + "");
        msg.putString("sentTime", message.getSentTime() + "");
        msg.putString("conversationType", message.getConversationType().getName());
        if (message.getContent() instanceof TextMessage) {
            TextMessage textMessage = (TextMessage) message.getContent();
            msg.putString("content", textMessage.getContent());
        } else if (message.getContent() instanceof ImageMessage) {
            ImageMessage richContentMessage = (ImageMessage) message.getContent();
            msg.putString("imageUrl", richContentMessage.getRemoteUri().toString());
            msg.putString("thumbnail", richContentMessage.getThumUri().toString());
        }

        return msg;
    }

    protected Conversation.ConversationType ConversationType(String type) {
        Conversation.ConversationType conversationType;
        if (type == "PRIVATE") {
            conversationType = Conversation.ConversationType.PRIVATE;
        } else if (type == "DISCUSSION") {
            conversationType = Conversation.ConversationType.DISCUSSION;
        } else {
            conversationType = Conversation.ConversationType.SYSTEM;
        }
        return conversationType;
    }

    protected void sendMessage(String type, String targetId, MessageContent content, String pushContent, final Promise promise) {

        Conversation.ConversationType conversationType = ConversationType(type);

        String pushData = "";

        RongIMClient.getInstance().sendMessage(conversationType, targetId, content, pushContent, pushData,
                new RongIMClient.SendMessageCallback() {
                    @Override
                    public void onSuccess(Integer integer) {
                        WritableMap map = Arguments.createMap();
                        map.putString("errcode", "0");
                        //promise.resolve(map);
                    }

                    @Override
                    public void onError(Integer integer, RongIMClient.ErrorCode errorCode) {
                        //promise.reject(errorCode.getValue() + "", errorCode.getMessage());
                    }
                },
                new RongIMClient.ResultCallback<Message>() {
                    @Override
                    public void onSuccess(Message message) {
                        WritableMap map = Arguments.createMap();
                        map.putString("errcode", "0");
                        //promise.resolve(map);
                    }

                    @Override
                    public void onError(RongIMClient.ErrorCode errorCode) {
                        //promise.reject(errorCode.getValue() + "", errorCode.getMessage());
                    }
                });
    }

    protected void sendEvent(String eventName, @Nullable WritableMap params) {
        context
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }
}
