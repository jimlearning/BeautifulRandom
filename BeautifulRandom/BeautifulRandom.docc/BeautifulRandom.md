# ``BeautifulRandom``

一个用于生成各种美观随机效果的 Swift Framework。

## 概述

BeautifulRandom 是一个专门用于生成具有美感的随机效果的 Framework。它提供了多种随机数生成算法和预设效果，可以用于创建视觉效果、动画和交互体验。

## 特性

- 多种随机数生成算法
  - 线性随机
  - 波形随机
  - 高斯分布随机
  - 柏林噪声
  - 贝塞尔曲线随机

- 内置效果生成器
  - 音频可视化效果
  - 雷达扫描效果

## 支持的效果类别

### 音频与声音可视化
- 音频频谱柱状图
- 波形图显示
- 环形音频可视化
- 粒子音频响应
- 声波扩散效果

### 自然现象模拟
- 雨滴效果
- 雪花飘落
- 烟雾扩散
- 火焰效果
- 水波纹

### 数据可视化
- 雷达扫描图
- 热力图
- 随机分布点图
- 流体图表
- 动态折线图

### 用户界面元素
- 加载动画
- 进度指示器
- 粒子按钮效果
- 波浪边框
- 动态背景

### 游戏与交互效果
- 粒子爆炸效果
- 随机地形生成
- 角色动作随机化
- 流体模拟
- 布料物理效果

## 使用方法

### 基础随机数生成

```swift
import BeautifulRandom

// 创建一个波形随机数生成器
let generator = RandomGenerator(type: .wave)

// 获取下一个随机值
let value = generator.next()
```

### 音频可视化效果

```swift
import BeautifulRandom

// 创建音频可视化器
let visualizer = AudioVisualizer(barCount: 30)

// 生成柱状图数据
let bars = visualizer.generateBars()
```

### 雷达扫描效果

```swift
import BeautifulRandom

// 创建雷达扫描器
let scanner = RadarScanner(maxDistance: 200)

// 获取扫描结果
let points = scanner.scan()
```

## 主题

### 基础组件
- RandomGenerator
- RandomType

### 效果生成器
- AudioVisualizer
- RadarScanner

### 数据类型
- RadarScanner/POI

## 要求
- iOS 15.0+
- macOS 12.0+
- tvOS 15.0+
- watchOS 8.0+
- Swift 5.5+

## 安装

### Swift Package Manager

将以下内容添加到你的 Package.swift 文件中
```swift
dependencies: [
    .package(url: "https://github.com/yourusername/BeautifulRandom.git", from: "1.0.0")
]
```

## 许可证
MIT License