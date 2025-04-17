# [cursor MCP例子](/2025/03/cursor_mcp.md)

对 WSL 运行 ubuntu+nvm 的开发者是有点不友好

```json
{
  "mcpServers": {
    "filesystem": {
      "how_to_use": "prompt AI use filesystem list filename",
      "command": ["wsl.exe"],
      "args": [
        "bash -c 'source /home/w/.nvm/nvm.sh; npx -y @modelcontextprotocol/server-filesystem /home/w/raydium-amm'"
      ]
    }
  }
}
```

prompt 加上 use filesystem tool 就行了
