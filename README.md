# BySwitcher
[![pub package](https://img.shields.io/badge/pub-v1.0.1-brightgreen?style=flat&logo=flutter)](https://pub.dev/packages/byswitcher) 
[![author](https://img.shields.io/badge/author-:byk-4189d5?style=flat&logo=github)](https://github.com/bluesofy)

A Switch Button for Flutter.

## Feature
- 参考Flutter自带Switch实现，增加了“加载中”的状态，适用于开关需要网络请求的场景；
- 可自定义开关底图（例如：开/关）；
- 可自定义按钮图

## Get Started
### Add Dependency
```yaml
dependencies:
  byswitcher: ^1.0.1
```

### Usage
```dart
import 'package:byswitcher/byswitcher.dart';

/// Normal Switcher
child: BySwitcher();

/// Has Loading State Default 
child: BySwitcher.loading();
```
