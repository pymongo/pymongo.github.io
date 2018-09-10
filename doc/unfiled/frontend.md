<marquee>This text will scroll from right to left</marquee>


## figcaption标签

[figcaption - MDN](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/figcaption)
MDN的
<figure>
    <img src="/img/figcaption.png">
    <figcaption>漂亮的图片标注</figcaption>
</figure>
<style>
figure {
    border: thin #000000 solid;
    display: flex;
    flex-flow: column;
    margin: 0;
    padding: 5px;
    width: 19em;
}

img {
    width: 100%;
}

figcaption {
    background-color: #222;
    color: #fff;
    font: italic smaller sans-serif;
    padding: 3px;
    text-align: center;
}

</style>

## ruby标签显示拼音

<ruby>
 拼音 <rt> pīn yīn </rt>
</ruby>

```html
<ruby>
 拼音 <rt> pīn yīn </rt>
</ruby>
```

## 名词缩写(虚线下划线效果)

<p>世界卫生组织<abbr title="World Health Organization">WHO</abbr></p>

abbr标签是个 border-bottom: 1px dotted 的样式

abbr常搭配dfn标签一起使用, dfn的样式是斜体

<p><dfn><abbr title="HyperText Markup Language">HTML</abbr></dfn> is the standard markup language for creating web pages.</p>

## document.referrer

获取"go back(Alt + ←)操作"的地址

Returns the URI of the page that linked to this page.

## shields.io图片组件

常见于Github的READ中

![](https://img.shields.io/badge/Alipay-donate-green.svg)
![](https://img.shields.io/badge/Wechat-donate-green.svg)
![](https://img.shields.io/badge/Paypal-donate-green.svg)

修改图片链接就可以更改图片的文本

shields.io另一种用法是显示Github项目的stars等信息
[示例](https://mathewsachin.github.io/)


## CSS权重

inspect element的时候, 常常看到一些CSS属性被下划线划掉

说明有被权重更高的相同属性定义覆盖掉了

- important/inline-styling: 1000, ID: 100, class: 10, tag: 1) 
- [CSS Specificity - MDN](https://developer.mozilla.org/en-US/docs/Web/CSS/Specificity)

## 异步加载的js不允许document.write

embedded github gist on page using document.write

> Failed to execute 'write' on 'Document': It isn't possible to write into a document from an asynchronously-loaded external script unless it is explicitly opened

异步加载的js是不允许使用document.write方法的。

因为document已经加载解析完毕，文档流已经关闭了

所以你异步加载的js不可以再往document里写东西了
