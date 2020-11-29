# [再次学习Ruby](/2019/10/learn_ruby.md)

以前在soloLearn上面学过一次ruby，虽然后面mixin等学得一知半解，而且也没metaprogramming, unittest等高级内容的介绍

如今由于工作需要再次学习rails(以前看软件那些事的视频曾经学过一次)

现在回头来看还是高見龍的「為你自己學 Ruby on Rails」讲的最好

打算就先按高見龍的教程过一遍，等我熟悉rails后再把默认的模板引擎换成vuejs

## ruby元编程API

### define_method

个人感觉不如Rust普通宏定义方法来的灵活

### send API

send能将入参字符串当作运算符给eval了

例如：1.send ">", 2 # false

### constantize(rails扩展API)

能对`Color::Red`这样的常量进行eval

---

.reverse! 逆序并改变值 感叹号表示這個方法會有「副作用」  
字符串常用方法.include?、.empty?、.gsub(replace)

实现列表追加，可以用<< OR + OR  逻辑或|

### [reduce]ruby从1加到100

(1..100).to_a.each ==  [*1..100].each

> puts [*1..100].reduce(:+) # 星号跟python中一样能把一个list拆开


### ruby.随机数

> puts [*1..100].shuffle.first(5)
> puts [*1..100].sample(5)

### 【精准计算】ruby.BigDecimal

### ruby.puts

我們很常用的 puts 方法，它其實就是 Object 這個類別的 private 方法之一（更正確的說，是 Kernel 模組 mixin 到 Object 類別裡的方法）

puts/p/print/.to_s/.inspect: p跟puts一样会换行，区别是会完整打印列表等结构，而且有返回值  
puts相当于.to_s, p相当于.to_s

Ruby有提供另一種字串的表現方式，分別是 %Q 跟 %q，各代表雙/單引號  
> puts %Q(你好，#{name}) # 跟雙引號一樣，可以使用字串安插  

## ruby变量与流程控制

### ruby method and OOP

> [!NOTE]
> Rbuy執行方法，可以省略小括號

定义完方法fun后ruby会内部产生一个Symbol  :fun  
可以通过send(:fun)调用函数

ruby方法中的最后一个表达式会自动返回，可以省略return

ruby函数最后一个参数如果是hash，则可以省略大括号  
  省略前|<%= link_to('刪除', user, {method: :delete, data: { confirm: 'sure?' }, class:'btn'}) %>  
  省略后| <%= link_to '刪除', user, method: :delete, data: { confirm: 'sure?' }, class:'btn' %>  
  就看第一个出现英文+冒号的说明这是hash第一个键，就这样识别把

### Ruby 並沒有「屬性」（property/attribute）的設計

某天下午我还与上司争论ROR中，为什么不用类变量/静态变量而是用def实现变量，原来ruby的类就不能有变量

ruby的class method的前缀是self.

### ruby.variable

种类:local/global/instance/class variabl  
举例:$gloabl=100,@@class=nil,@instance=nil  
在irb直接操作类变量会有warning: class variable access from toplevel  

常量以大写字母开头，內容是可以修改的，

### hash and symbol

ruby的键通常都用不可变immutable字符串Symbols表示，如:age  
【注意】ruby 要用profile[:name]取hash的值而不能用profile["name"]  
因為 Symbol 不可變（immutable）的特性，以及它的查找、比較的速度比字串還快，它很適合用來當 Hash 的 Key。  

```ruby
hash1.each do |key, value|
  puts "#{key}:#{value}"
end
#same as
hash1.each { |key, value|
  puts "#{key}:#{value}"
}
```

## ruby匿名函数

> arr.select(&:odd?) == arr.select{|each| each.reverse}

### ruby.block-yield

```ruby
#自己实现.select方法/过滤器
  def pick(list)
    result = []
    list.each do |i|
      result << i if yield(i)            # 如果 yield 的回傳值是 true 的話...
    end
    result
  end
```

p([*1..10].map) do |i| i * 2 end
因為優先順序較低，所以變成先跟 p 結合了，造成後面附掛的 Block 就不會被處理了。
一：do..end优先度较低，二:如果block有多行优先使用do..end

可以通过Proc类使block object化

[TODO:]Refactor as docsify-tabs

```ruby
def say_hello1
  yield if block_given?
end

def say_hello2 &p #block  &p:block p:proc
  p.call
end

def say_hello3 p
  p.call
end

say_hello1 do
  puts 'hello1'
end
say_hello2 {puts 'hello2'}
p = lambda {puts 'hello3'}
puts p
say_hello3 p
p1 = proc {puts 'hello3'}
puts p1
say_hello3 p1
p2 = Proc.new {puts 'hello3'}
puts p2
say_hello3 p2
p3 = -> {puts 'hello3'}
puts p3
say_hello3 p3
```
