# rongcloud-imlib-react-native
Rongcloud IMLib Module For React Native


## ios config
1. 下面两个文件放在工程ios目录下。 在工程YCParApp的Libraries上点右键，将这两个文件加到项目中
- libopencore-amrnb.a
- RongIMLib.framework


2. Target > YCParApp > BuildPhase > Link Binary With Libraries > + > 输入libsqlite3.tbd
- libsqlite3.tbd


3. add framework search paths & library search paths 
Target > YCParApp > Build Setting > Search Paths 

- $(PROJECT_DIR)/../node_modules/rongcloud-imlib-react-native/ios/lib



## android config
- config AndroidManifest.xml
- fix settings.gradle
```
// file: android/settings.gradle
// ...
include ':rongcloud-imlib-react-native'
project(":rongcloud-imlib-react-native").projectDir = file("../node_modules/rongcloud-imlib-react-native/android")
```
```
// file: android/app/build.gradle

dependencies {
    // ...
    compile project(':rongcloud-imlib-react-native')
}

```

## import
```
import RongCloud from 'rongcloud-imlib-react-native'
```
```

```
