# [跳转到ts函数的js实现](/2024/09/ts_go_to_js_define.md)

<https://github.com/solana-labs/solana-web3.js/blob/7a599f0963053102872f7fbd6368698fe132e241/packages/rpc-api/src/getSlot.ts#L9>  
solana Connection 的 getAccountInfo 方法 vscode 默认会跳转到 index.d.ts 的函数签名定义 而源码实现在同名 js 文件下

node_modules/@solana/web3.js/lib/index.d.ts  
node_modules/@solana/web3.js/lib/index.cjs.js

有人说那我就只能在node_modules里面用正则表达式/关键词找函数实现的js代码

其实vscode配置 `"typescript.preferGoToSourceDefinition": true` 就可以"二次跳转"到js代码了

solana ts sdk 这样 100% ts 代码的库会编译成 js+d.ts(函数原型定义) 上传到 npm 所以读ts代码的时候能跳转到"晦涩难懂"的编译后js代码将就凑合看看代码也够了
