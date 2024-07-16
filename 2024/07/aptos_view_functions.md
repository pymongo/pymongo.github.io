# [aptos #[view]](/2024/07/aptos_view_functions.md)

aptos move 带 `#[view]` 修饰的函数没有修改数据，可以无需gas获取数据，但例如获取订单簿5档的调用内部会进行计算操作将订单价格合并

aptos 中获取 hello sui todo_list 例子中 list 长度用 function call 形式获取即便是只读操作也会消耗 GAS

> sui client call --package 0x702815e66354365ec77e0ea708912725be4e8e0407b041e11f3b3f733c2a4a53 --module todo_list --function length --args 0x6d08e394bcc4dec6a8349f1ffb4e5630c0cd55df1ba9882cfe66dfa5b1f7d130

例如一个获取 DEX 用户余额的 aptos move 函数 https://github.com/econia-labs/econia/blob/main/src/move/econia/sources/user.move#L952

POST https://fullnode.mainnet.aptoslabs.com/v1/view

payload: {"function":"0xc0deb00c405f84c85dc13442e305df75d1288100cdd82675695f6148c7ece51c::user::get_market_account","type_arguments":[],"arguments":["0xb411e3fd045765c73deca67f91be38131373dbf9eec0309068403558fe0bc202","7","0"]}
