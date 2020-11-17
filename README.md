# file_manager

一个文件管理器

## 使用方法

### 在 yaml 中引入该plugin
```yaml
    file_manager:
        git: https://github.com/nightmare-space/file_manager
```

### 使用组件
就像下面这么简单

## 功能列表

### Q&A
#### 为何是作为一个 plugin 而不是 dart packages ？
因为需要调用 java 的库来进行 apk/dex 的反编译。