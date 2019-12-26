# [jQuery验证checkbox](2019/11_2/checkbox_jquery_validate)

[model数据验证与消息闪现(flash)](2019/11_1/validates)

<i class="fa fa-hashtag"></i>
需求：

将现有的后端验证 重构为 jquery_validate

<i class="fa fa-hashtag"></i>
初始化jQuery validate

初始化方法和datepicker类似，选择器+.validate()

!> 注意，$('form').validate()只会初始化选择器的**第一个from**

因为validate可以设置错误信息的出现位置及文案等，所以每个表单都要单独validate一次

并不像datepicker一样可以批量初始化

<i class="fa fa-hashtag"></i>
验证checkbox至少选中一个

jQuery自带的验证方法没有涉及checkbox的，需要自定义规则

<!-- tabs:start -->

#### ** HTML **

```html
  <!-- 批量删除好友表单 -->
  <form>
    <div class="errors-msg"></div>
    <input type="submit"/>
    <!-- ... -->
    <% @friends.each do |friend| %>
    <tr>
      <td>
        <input type='checkbox' name='checkbox[]' value='<%= friend.id %>'/>
      </td>
      <!-- ... -->
  </form>
```

#### ** JavaScript **

```js
$("#form").validate({
  rules: {
    "checkbox[]": {
      required: true,
      minlength: 1
    }
  },
  errorLabelContainer: ".errors-msg",
  messages: {
    "checkbox[]": "至少要勾选一个订单才能进行批量撤销"
  }
});
```

<!-- tabs:end -->

<i class="fa fa-hashtag"></i>
参考链接：

- [Checkbox Form validation using jQuery Validate plugin](https://codepen.io/paulyabsley/pen/zFkbI)
- [jQuery Validate - 菜鸟教程](https://www.runoob.com/jquery/jquery-plugin-validate.html)
