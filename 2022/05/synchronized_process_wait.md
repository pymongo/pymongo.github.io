# [synchronized wait](/2022/05/synchronized_process_wait.md)

今天遇到/学习了 java.lang.IllegalMonitorStateException: current thread is not owner

报错原因是 Process.wait 没加 synchronized; 与之类似的 waitFor 则不需要加

要是 wait 没加 sync 能在编译时检查就好了
例如来个 `wait not impl Send/Sync, can't send/share between threads safety` 编译报错提示

https://twitter.com/ospopen/status/1523589984389038081

```java
package com.example;
import java.io.IOException;

public class Main {
    public static void main(String[] args) {
        var processBuilder = new ProcessBuilder("pwd");
        //processBuilder.directory(new File(dir));
        processBuilder.inheritIO();
        try {
            var p = processBuilder.start();
            // waitFor not require synchronized
            //p.waitFor();
            synchronized (p) {
                p.wait();
            }
            if (p.exitValue() != 0) {
                System.err.println("err");
            }
        } catch (IOException | InterruptedException e) {
            e.printStackTrace();
        }
    }
}
```
