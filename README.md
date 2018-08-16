# 吴翱翔的博客

自由至上主义者，政治经济业余爱好者，常看政论节目

文章逐渐从各种专栏migrate回来中

## 临时笔记

### CSS权重

- important/inline-styling: 1000, ID: 100, class: 10, tag: 1) 
- [CSS Specificity - MDN](https://developer.mozilla.org/en-US/docs/Web/CSS/Specificity)

### document.referr

### 异步加载的js不允许document.write

embedded github gist on page using document.write

> Failed to execute 'write' on 'Document': It isn't possible to write into a document from an asynchronously-loaded external script unless it is explicitly opened

异步加载的js是不允许使用document.write方法的。

因为document已经加载解析完毕，文档流已经关闭了

所以你异步加载的js不可以再往document里写东西了

