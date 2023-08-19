# [线程优先级反转/继承](/2023/07/task_priority_inversion_and_priority.md)

**优先级反转**: 高优先级线程的资源(例如锁)被低优先级线程阻塞，导致高优先级线程像是优先级被降低一样

解决办法: **优先级继承** blocking thread inherits the priority of the highest priority thread that is waiting for it, temporarily increasing the priority

也叫优先级天花板协议?(priority ceiling protocol)
