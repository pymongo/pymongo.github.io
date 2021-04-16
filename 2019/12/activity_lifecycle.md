# [Activity Lifecycle](/2019/12/activity_lifecycle.md)

<https://developer.android.com/guide/components/activities/activity-lifecycle>

<i class="fa fa-hashtag"></i>
英文专业名词

★Recent Apps key

就是安卓三大虚拟按键(back, home, recent_app)的最右边那个

几个常见操作Activity的状态变化：

<i class="fa fa-hashtag"></i>
Home(App最小化，回到桌面)

pause->stop

<i class="fa fa-hashtag"></i>
Recent Apps

也是 pause->stop

<i class="fa fa-hashtag"></i>
回到APP

restart->start->resume

<i class="fa fa-hashtag"></i>
在recent apps中划掉/关掉APP

destroy

<i class="fa fa-hashtag"></i>
从Activity1进入Activity2

pause1->create2->start2->resume2->stop2

<i class="fa fa-hashtag"></i>
从Activity2后退到Activity1

pause2->restart1->start1->resume1-stop2-destroy2

注意：Activity的切换或称为父子关系有点像【栈】结果

如果ActivityN退出时是栈的最底层，则会被destroy

## onStart之后的状态下才能用toast

onStart之前的状态可能未初始化完全，所以不能用Toast
