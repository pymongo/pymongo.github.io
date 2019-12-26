# [Rails跳转到页面特定位置(id,anchor,location)](/2019/12_2/redirect_to_anchor.md)

例如页面有个标题是`\<h2 id="help-title">Help</h2>`

那么controller跳转到#help-title的代码是：

`redirect_to xx_path(anchor: "help-title")`

😂redirect_to `:bank` 就没法加anchor参数了跳转到页面特定位置了

<i class="fa fa-hashtag"></i>
参考链接

[https://stackoverflow.com/questions/13791556/how-to-redirect-to-a-certain-location-in-a-page](https://stackoverflow.com/questions/13791556/how-to-redirect-to-a-certain-location-in-a-page)
