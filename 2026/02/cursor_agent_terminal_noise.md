# [我的agent要罢工](/2026/02/cursor_agent_terminal_noise.md)

我 cursor agent 调用 terminal 总报错 -e command not found

> The shell seems to have a noisy env. Let me try a different approach to build.

> sleep 30 && cat /home/w/.cursor/projects/home-w-arb/terminals/65444.txt | tail -20

于是 AI 就罢工了 各种调用不了命令

经过AI对话 我注释掉 .bashrc 以下内容

```
# If not running interactively, don't do anything
#case $- in
#    *i*) ;;
#      *) return;;
#esac
```

还有 vscode settings "terminal.integrated.defaultProfile.linux": "bash"


关于 agent 编排，每次让 claude 干活之前最好先让 AI 列出 plan 计划 免得AI陷入死循环一直不能解决问题 几分钟花掉我7$
