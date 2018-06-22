# EasyKVO
系统的KVO存在很多问题，例如重复添加导致的多次回调，以及重复移除或忘记移除导致的崩溃。所以我基于Runtime写了套自定义的KVO，调用方式和原生的一样，并提供了block方式的回调，使代码更紧凑。

写的比较简单，可能会有一些其他bug。仅供技术交流，项目中尽量不要使用。如果要使用的话，推荐使用Facebook的[KVOController](https://github.com/facebook/KVOController)。

#### 原文地址

[KVO原理分析及使用进阶](https://www.jianshu.com/p/badf5cac0130)