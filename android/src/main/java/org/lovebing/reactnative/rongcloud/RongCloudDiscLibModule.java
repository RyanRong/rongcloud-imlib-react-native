package org.lovebing.reactnative.rongcloud;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;

import java.util.ArrayList;

import io.rong.imlib.RongIMClient;
import io.rong.imlib.model.Discussion;

/**
 * Created by lgp on 2017/6/26.
 */

public class RongCloudDiscLibModule extends ReactContextBaseJavaModule {
    protected ReactApplicationContext context;

    public RongCloudDiscLibModule(ReactApplicationContext reactContext) {
        super(reactContext);
        context = reactContext;
    }
    @Override
    public String getName() {
        return "RongCloudDiscLibModule";
    }

    @ReactMethod
    public void createDiscussion(String name, ReadableArray str , final Promise promise) {
//        String[] string=str;
//         str.getArray(str.size());
        ArrayList<String> li=new ArrayList<String>()  ;
        for(int i=0;i<str.size();i++){
            li.add(str.getString(i));
        }

        RongIMClient.getInstance().createDiscussion (name, li, new RongIMClient.CreateDiscussionCallback() {

            @Override
            public void onSuccess(String s) {
                promise.resolve(s);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                promise.reject("" + errorCode.getValue(), errorCode.getMessage());
            }
        });
    }
    @ReactMethod
    public void addMemberToDiscussion(String discussionId, ReadableArray str, final Promise promise) {
 
        ArrayList<String> li=new ArrayList<String>()  ;
        for(int i=0;i<str.size();i++){
            li.add(str.getString(i));
        }
        RongIMClient.getInstance().addMemberToDiscussion (discussionId, li, new RongIMClient.OperationCallback() {


            @Override
            public void onSuccess() {
                promise.resolve("addMemberToDiscussion success");
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                promise.reject("" + errorCode.getValue(), errorCode.getMessage());
            }
        });
    }
    @ReactMethod
    public void removeMemberFromDiscussion(String discussionId, String userlist, final Promise promise) {
        RongIMClient.getInstance().removeMemberFromDiscussion (discussionId, userlist, new RongIMClient.OperationCallback() {


            @Override
            public void onSuccess() {
                promise.resolve("removeMemberFromDiscussion success");
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                promise.reject("" + errorCode.getValue(), errorCode.getMessage());
            }
        });
    }
    @ReactMethod
    public void quitDiscussion(String discussionId,   final Promise promise) {
        RongIMClient.getInstance().quitDiscussion (discussionId,   new RongIMClient.OperationCallback() {


            @Override
            public void onSuccess() {
                promise.resolve("quitDiscussion success");
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                promise.reject("" + errorCode.getValue(), errorCode.getMessage());
            }
        });
    }
    @ReactMethod
    public void getDiscussion(String discussionId,   final Promise promise) {
        RongIMClient.getInstance().getDiscussion (discussionId,   new RongIMClient.ResultCallback<Discussion>() {


            @Override
            public void onSuccess(Discussion discussion) {
                WritableMap ret = Arguments.createMap();
                WritableArray data = Arguments.createArray();
                if(discussion.getMemberIdList() != null && !discussion.getMemberIdList().isEmpty()) {
                    for(int i = 0; i < discussion.getMemberIdList().size(); i++) {

                        data.pushString(discussion.getMemberIdList().get(i));
                    }
                }
                ret.putBoolean("isopen", discussion.isOpen());
                ret.putString("discussionName", discussion.getName());
                ret.putArray("memberIdList", data);
                ret.putString("discussionId", discussion.getId());
                ret.putString("creatorId", discussion.getCreatorId());
                promise.resolve(ret);
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                promise.reject("" + errorCode.getValue(), errorCode.getMessage());
            }
        });
    }
    @ReactMethod
    public void setDiscussionName(String discussionId,  String name , final Promise promise) {
        RongIMClient.getInstance().setDiscussionName (discussionId,  name, new RongIMClient.OperationCallback() {


            @Override
            public void onSuccess() {
                promise.resolve("setDiscussionName success");
            }

            @Override
            public void onError(RongIMClient.ErrorCode errorCode) {
                promise.reject("" + errorCode.getValue(), errorCode.getMessage());
            }
        });
    }
}
