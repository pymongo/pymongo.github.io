# [编写安卓测试用例](/2020/03/android_test.md)

安卓测试方法分三类
1. UnitTest: JUnit、Mockito。缺点：运行在PC的JVM上并不是在安卓机上运行。优点：轻量，运行速度极快(因为没有UI )
2. InstrumentationTest: JUnit、Mockito
3. UI Test: androidx.test.espresso


## 运行安卓测试时的两个报错

> junit.framework.AssertionFailedError: No tests found in

`(app)build.gradle->defaultConfig`

testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"

> Error=Unable to find instrumentation info for: ComponentInfo{ }

Build Variant: 先选
























