# [vscode C++ lldb](/2023/07/vscode_cpp_lldb.md)

.vscode/tasks.json

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "build_demo_cpp",
            "type": "shell",
            "command": "g++ -g -I./include -lmylib -Wno-write-strings demo.cpp -o target/demo"
        },
        {
            "label": "run_demo",
            // or shell
            "type": "process",
            "dependsOn": ["build_demo"],
            "command": "./target/demo",
        }
    ]
}
```

.vscode/launch.json

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "debug demo.cpp",
            "type": "lldb",
            /*
            launch to create a new process,
            attach to attach to an already running process,
            custom to configure session "manually" using LLDB commands.
            */
            "request": "launch",
            "program": "${workspaceFolder}/target/demo",
            "args": [],
            "cwd": "${workspaceFolder}",
            "preLaunchTask": "build_demo_cpp"
        }
    ]
}
```

如果有多个 debug launch configurations 如何切换

1. 侧边栏进入 Run and Debug 菜单
2. Run and Debug 界面的左上角的下拉菜单选中
