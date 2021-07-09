# [linux_desktop_notification](/2021/07/linux_desktop_notification.md)

## notify-send

> notify-send hello

notify-send use some dbus relative C API

## broadcast message

### wall

§ sender:

> wall hello

§ receiver:

```
Broadcast message from w@ww (pts/2) (Thu Jul  8 09:26:32 2021):                
                                                                               
hello
```

### syslog LOG_EMERG

default manjaro system configuration, LOG_EMERG would send broadcast message like wall

§ sender:

> libc::syslog(libc::LOG_EMERG, "hello\0".as_ptr().cast());

§ receiver:

```
Broadcast message from systemd-journald@ww (Thu 2021-07-08 09:28:25 CST):

syslog[87348]: hello
```
