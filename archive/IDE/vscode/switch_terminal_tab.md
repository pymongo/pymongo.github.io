# [vscode添加切换terminal tab的快捷键](archive/IDE/vscode/switch_terminal_tab)

<i class="fa fa-hashtag"></i>
[参考链接](https://stackoverflow.com/questions/44065101/vs-code-key-binding-for-quick-switch-between-terminal-screens)

打开vscode keyboard json

```
{ 
  "key": "ctrl+tab",            
  "command": "workbench.action.openNextRecentlyUsedEditorInGroup",
  "when": "editorFocus" 
},
{ "key": "shift+ctrl+tab",      
  "command": "workbench.action.openPreviousRecentlyUsedEditorInGroup",
  "when": "editorFocus" 
},
{
  "key": "ctrl+tab",
  "command": "workbench.action.terminal.focusNext",
  "when": "terminalFocus"
},
{
  "key": "ctrl+shift+tab",
  "command": "workbench.action.terminal.focusPrevious",
  "when": "terminalFocus"
}
```
