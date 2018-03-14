# rongcloud-imlib-react-native
Rongcloud IMLib Module For React Native


## install
npm install rongcloud-imlib-react-native --save

react-native link rongcloud-imlib-react-native

##IOS Config


Add Libs:

Target -> APP -> Build Phases -> Link Binary With Libraries -> add Other:

* libopencore-amrnb.a  ( from ../node_modules/rongcloud-imlib-react-native/ios/lib)

* RongIMLib.framework ( from ../node_modules/rongcloud-imlib-react-native/ios/lib)


* libsqlite3.tbd 


add framework search paths & library search paths "$(PROJECT_DIR)/../node_modules/rongcloud-imlib-react-native/ios/lib"


##Android Config

settings.gradle

	include ':rongcloud-imlib-react-native'
	project(":rongcloud-imlib-react-native").projectDir = file("../node_modules/rongcloud-imlib-react-native/android")

app/build.gradle

	dependencies {
    compile project(':rongcloud-imlib-react-native')}
    
MainApplication

 		@Override
        protected List<ReactPackage> getPackages() {
            return Arrays.<ReactPackage>asList(
                    new MainReactPackage(),
                    new RongCloudPackage()
            );
        }
        
AndroidManifest.xml

    <application>
	  <!-- imlib config begin -->
        <meta-data
            android:name="RONG_CLOUD_APP_KEY"
            android:value="your key" />

        <service
            android:name="io.rong.imlib.ipc.RongService"
            android:exported="true"
            android:process=":ipc" />

        <service android:name="io.rong.imlib.ReConnectService" />

        <receiver android:name="io.rong.imlib.ConnectChangeReceiver" />

        <receiver
            android:name="io.rong.imlib.HeartbeatReceiver"
            android:process=":ipc" />
        <!-- imlib config end -->
            </application>
 
 
PS:if you have any problem,you wirte issue to me.