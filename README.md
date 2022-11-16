# QJComponentsDome
## 封装的一些常用的组件功能集合

### 分类
#### 1. NSObject+PPObserver.h
    - KVO功能

### UIViewController+PPPresentTransition.h 
    - 用于当 UIViewController modal 或 push 等方式展示时，实际都是以 push 方式展示，但 modal 的效果还是保留
    
### PPMultiTargetProxy
    - 用于消息转发，一个是主体接收消息，还有副体也同时接收想要的消息

## 容器类
### PPTapMenumContainerView
    - item 容器

### QJBaseTableViewController
    - tableView 相关
    
## 图形
### QJWavyLinesView
    - 声音波形图

## UIKit基本类扩展
### 1. PPExtensibleLabel
    - 带展开Label内容的按钮

### 2. QJFormatTextField
    - 显示指定格式的输入框
    
### 3. PPGifLoaderManager
    - 动图SDK封装
    
    
## ReactNative 相关
### PPNativeModuleHander
    - RN 与 原生 之前的交互
    
### RN 热更新方案
    - PPReactNativeUpdateManager 更新管理入口
    - PPReactNativeDownloadManager 下载包管理 -》流转到热更新
    - PPReactNativeInfoManager 热更新操作文件更新
    - PPReactNativeFileHandler 文件管理器
