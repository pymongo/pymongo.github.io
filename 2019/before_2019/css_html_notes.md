# [CSS/HTML小知识(如CSS权重)](/uncategorized/css_html_notes.md)

## CSS权重

审查网页元素的css时, 常看到一些CSS属性有删除线

虽然知道这条属性不生效, 但具体原因一直没去研究

其实原因时该条属性被权重更高的同名属性覆盖了

比如 .text 里面的color属性会覆盖掉 p 里面的color属性

- important(CSS选择器权重值)/inline-styling: 1000
- ID: 100
- class: 10
- tag: 1 

[CSS Specificity - MDN](https://developer.mozilla.org/en-US/docs/Web/CSS/Specificity)

---

<i class="fa fa-hashtag"></i>
console.log输出添加颜色

console.log('%c green%c red', 'color:green', 'color:red')

<i class="fa fa-hashtag"></i>
文字间行距

常用 line-height: 100% 与margin/padding调整文字间行距

<i class="fa fa-hashtag"></i>
background-attachment

滚动时背景图固定

<i class="fa fa-hashtag"></i>
vw-vh单位

- 1vw = 1% of viewport width
- 1vh = 1% of viewport height
- 1vmin = 1vw or 1vh, whichever is smaller
- 1vmax = 1vw or 1vh, whichever is larger

[viewport-sized css-trick](https://css-tricks.com/viewport-sized-typography/)

<i class="fa fa-hashtag"></i>
input失焦的onblur事件

[onblur event - W3School](https://www.w3schools.com/jsref/event_onblur.asp)

> The onblur event is similar to the onfocusout event. The main difference is that the onblur event does not bubble

[事件冒泡, 事件委托](https://segmentfault.com/a/1190000000470398)

Event.stopPropagation()停止事件触发往上冒泡传递

<i class="fa fa-hashtag"></i>
折叠功能:details-summary

<details>
<summary>
summary折叠后显示
</summary>
details被折叠内容...
</details>

<i class="fa fa-hashtag"></i>
marquee标签

<marquee behavior="alternate">marquee tag behavior="alternate"(往回弹),默认是scroll</marquee>

**滚动** *效果* 的CSS实现: `animation: scroll 7s linear 0s infinite;`

<i class="fa fa-hashtag"></i>
kbd标签

<kbd>Ctrl</kbd> + <kbd>s</kbd> : Save file // kbd tag

<i class="fa fa-hashtag"></i>
ruby标签显示拼音

<ruby>
 拼音 <rt> pīn yīn </rt>
</ruby>

```html
<ruby>
 拼音 <rt> pīn yīn </rt>
</ruby>
```

<i class="fa fa-hashtag"></i>
名词缩写(虚线下划线效果)

<p>世界卫生组织<abbr title="World Health Organization">WHO</abbr></p>

abbr标签是个 border-bottom: 1px dotted 的样式

abbr常搭配dfn标签一起使用, dfn的样式是斜体

<p><dfn><abbr title="HyperText Markup Language">HTML</abbr></dfn> is the standard markup language for creating web pages.</p>

## datalist

```html
<form action="/action_page.php" method="get">
  <input list="browsers" name="browser">
  <datalist id="browsers">
    <option value="Firefox">
    <option value="Chrome">
  </datalist>
  <input type="submit">
</form>
```

<form action="/action_page.php" method="get">
  <input list="browsers" name="browser">
  <datalist id="browsers">
    <option value="Firefox">
    <option value="Chrome">
  </datalist>
  <input type="submit">
</form>

## 表单的legend标签

<form>
  <fieldset>
    <legend>userInfo</legend>
    UserName: <input type="text"><br>
    PawssWord: <input type="text"><br>
  </fieldset>
</form>

legend标签在fieldset标签内才能生效

```html
<form>
  <fieldset>
    <legend>Personalia:</legend>
    Name: <input type="text"><br>
    Email: <input type="text"><br>
    Date of birth: <input type="text">
  </fieldset>
</form>
```

## CROS 跨域

后端: nginx 或 web 框架加上 cros

前端 ouath 需要弹窗无法做成内嵌，或者通过浏览器插件去请求绕开浏览器安全限制
