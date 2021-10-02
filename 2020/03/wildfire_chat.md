# [野火IM的二次开发心得](/2020/03/wildfire_chat.md)

基于业务需求需要开发一款IM(即时聊天)工具，我一个人独自开发肯定不现实的

微信、Facebook都是百人团队开发数年的产品，还是需要基于某个开源IM进行二次开发

调研了IM的技术原理发现，20多年前制定了PC端的IM通讯协议XMPP，

由于架构性能等诸多问题已经不适用于移动端的IM应用，但是腾讯Fb等大厂又不肯开源自己的IM协议

所以去github上找了几个开源的IM项目

<i class="fa fa-hashtag"></i>
Telegram

移动端开源但后端不开源，Telegram制定了一套IM的后端接口标准

只要你服务器后端实现了标准，就能对接Telegram的App

Telegram的安卓端是C语言写的，编译一直报错，弃用！

<i class="fa fa-hashtag"></i>
telegramd

国人用go语言写的实现了telegram协议的后端项目，因安卓端需要用Telegram，而我又不能成功编译Telegram的安卓端，弃用

<i class="fa fa-hashtag"></i>
tinode

国外一大神独自全栈开发的杰作(一个人写完前后端和移动端)，仿Telegram

用户反馈说不符合国人使用习惯，也没有发语音消息的功能

<i class="fa fa-hashtag"></i>
野火

完全仿微信UI和使用习惯的部分开源IM项目，自带gitbook详细文档

部署方式也是最简单最「傻瓜」的，安卓端只改一行服务器IP就能运行

傻瓜的地方在于提供类似SQLite一样的H2数据库，无需配置数据库

不过文档写的太精简了，好多东西都说不全

后端分两个子系统，一个是IM server、另一个是app server(管用户注册登录和用户数据的)

## IM server的配置

> 需要保证JDK版本是1.8

mvn compile后，编译的输出文件在`distribution/target/`中

修改`distribution/target/config/wildfirechat.conf`

`server.ip`要改成公网IP、同时host**保持**0.0.0.0不变

IM server跑起来后打开浏览器访问 公网IP/api/version 检查是否正常返回json数据

## App server

mvn package后，cd 到target目录，修改`application.properties`配置

改一下log目录的配置项`logs.user_logs_path`

---

## 依然存在的问题

App server跑起来之后App server依然有如下几项报错

```
java.lang.IllegalArgumentException: Invalid character found in method name. HTTP method names must be tokens
	at org.apache.coyote.http11.Http11InputBuffer.parseRequestLine(Http11InputBuffer.java:428) ~[tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.apache.coyote.http11.Http11Processor.service(Http11Processor.java:684) ~[tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.apache.coyote.AbstractProcessorLight.process(AbstractProcessorLight.java:66) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.apache.coyote.AbstractProtocol$ConnectionHandler.process(AbstractProtocol.java:806) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.apache.tomcat.util.net.NioEndpoint$SocketProcessor.doRun(NioEndpoint.java:1498) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.apache.tomcat.util.net.SocketProcessorBase.run(SocketProcessorBase.java:49) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149) [na:1.8.0_242]
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624) [na:1.8.0_242]
	at org.apache.tomcat.util.threads.TaskThread$WrappingRunnable.run(TaskThread.java:61) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at java.lang.Thread.run(Thread.java:748) [na:1.8.0_242]
```

> 登录时会出现会话不存在

```
org.apache.shiro.authc.AuthenticationException: ?????
	at cn.wildfirechat.app.shiro.ScanCodeRealm.doGetAuthenticationInfo(ScanCodeRealm.java:51) ~[classes!/:0.40]
	at org.apache.shiro.realm.AuthenticatingRealm.getAuthenticationInfo(AuthenticatingRealm.java:568) ~[shiro-core-1.3.2.jar!/:1.3.2]
	at org.apache.shiro.authc.pam.ModularRealmAuthenticator.doMultiRealmAuthentication(ModularRealmAuthenticator.java:219) [shiro-core-1.3.2.jar!/:1.3.2]
	at org.apache.shiro.authc.pam.ModularRealmAuthenticator.doAuthenticate(ModularRealmAuthenticator.java:269) [shiro-core-1.3.2.jar!/:1.3.2]
	at org.apache.shiro.authc.AbstractAuthenticator.authenticate(AbstractAuthenticator.java:198) [shiro-core-1.3.2.jar!/:1.3.2]
	at org.apache.shiro.mgt.AuthenticatingSecurityManager.authenticate(AuthenticatingSecurityManager.java:106) [shiro-core-1.3.2.jar!/:1.3.2]
	at org.apache.shiro.mgt.DefaultSecurityManager.login(DefaultSecurityManager.java:270) [shiro-core-1.3.2.jar!/:1.3.2]
	at org.apache.shiro.subject.support.DelegatingSubject.login(DelegatingSubject.java:256) [shiro-core-1.3.2.jar!/:1.3.2]
	at cn.wildfirechat.app.ServiceImpl.login(ServiceImpl.java:101) [classes!/:0.40]
	at cn.wildfirechat.app.Controller.login(Controller.java:27) [classes!/:0.40]
	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method) ~[na:1.8.0_242]
	at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62) ~[na:1.8.0_242]
	at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43) ~[na:1.8.0_242]
	at java.lang.reflect.Method.invoke(Method.java:498) ~[na:1.8.0_242]
	at org.springframework.web.method.support.InvocableHandlerMethod.doInvoke(InvocableHandlerMethod.java:209) [spring-web-5.0.10.RELEASE.jar!/:5.0.10.RELEASE]
	at org.springframework.web.method.support.InvocableHandlerMethod.invokeForRequest(InvocableHandlerMethod.java:136) [spring-web-5.0.10.RELEASE.jar!/:5.0.10.RELEASE]
	at org.springframework.web.servlet.mvc.method.annotation.ServletInvocableHandlerMethod.invokeAndHandle(ServletInvocableHandlerMethod.java:102) [spring-webmvc-5.0.10.RELEASE.jar!/:5.0.10.RELEASE]
	at org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.invokeHandlerMethod(RequestMappingHandlerAdapter.java:891) [spring-webmvc-5.0.10.RELEASE.jar!/:5.0.10.RELEASE]
	at org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.handleInternal(RequestMappingHandlerAdapter.java:797) [spring-webmvc-5.0.10.RELEASE.jar!/:5.0.10.RELEASE]
	at org.springframework.web.servlet.mvc.method.AbstractHandlerMethodAdapter.handle(AbstractHandlerMethodAdapter.java:87) [spring-webmvc-5.0.10.RELEASE.jar!/:5.0.10.RELEASE]
	at org.springframework.web.servlet.DispatcherServlet.doDispatch(DispatcherServlet.java:991) [spring-webmvc-5.0.10.RELEASE.jar!/:5.0.10.RELEASE]
	at org.springframework.web.servlet.DispatcherServlet.doService(DispatcherServlet.java:925) [spring-webmvc-5.0.10.RELEASE.jar!/:5.0.10.RELEASE]
	at org.springframework.web.servlet.FrameworkServlet.processRequest(FrameworkServlet.java:974) [spring-webmvc-5.0.10.RELEASE.jar!/:5.0.10.RELEASE]
	at org.springframework.web.servlet.FrameworkServlet.doPost(FrameworkServlet.java:877) [spring-webmvc-5.0.10.RELEASE.jar!/:5.0.10.RELEASE]
	at javax.servlet.http.HttpServlet.service(HttpServlet.java:661) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.springframework.web.servlet.FrameworkServlet.service(FrameworkServlet.java:851) [spring-webmvc-5.0.10.RELEASE.jar!/:5.0.10.RELEASE]
	at javax.servlet.http.HttpServlet.service(HttpServlet.java:742) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:231) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.apache.tomcat.websocket.server.WsFilter.doFilter(WsFilter.java:52) [tomcat-embed-websocket-8.5.34.jar!/:8.5.34]
	at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:193) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.apache.shiro.web.servlet.ProxiedFilterChain.doFilter(ProxiedFilterChain.java:61) [shiro-web-1.3.2.jar!/:1.3.2]
	at org.apache.shiro.web.servlet.AdviceFilter.executeChain(AdviceFilter.java:108) [shiro-web-1.3.2.jar!/:1.3.2]
	at org.apache.shiro.web.servlet.AdviceFilter.doFilterInternal(AdviceFilter.java:137) [shiro-web-1.3.2.jar!/:1.3.2]
	at org.apache.shiro.web.servlet.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:125) [shiro-web-1.3.2.jar!/:1.3.2]
	at org.apache.shiro.web.servlet.ProxiedFilterChain.doFilter(ProxiedFilterChain.java:66) [shiro-web-1.3.2.jar!/:1.3.2]
	at org.apache.shiro.web.servlet.AbstractShiroFilter.executeChain(AbstractShiroFilter.java:449) [shiro-web-1.3.2.jar!/:1.3.2]
	at org.apache.shiro.web.servlet.AbstractShiroFilter$1.call(AbstractShiroFilter.java:365) [shiro-web-1.3.2.jar!/:1.3.2]
	at org.apache.shiro.subject.support.SubjectCallable.doCall(SubjectCallable.java:90) [shiro-core-1.3.2.jar!/:1.3.2]
	at org.apache.shiro.subject.support.SubjectCallable.call(SubjectCallable.java:83) [shiro-core-1.3.2.jar!/:1.3.2]
	at org.apache.shiro.subject.support.DelegatingSubject.execute(DelegatingSubject.java:383) [shiro-core-1.3.2.jar!/:1.3.2]
	at org.apache.shiro.web.servlet.AbstractShiroFilter.doFilterInternal(AbstractShiroFilter.java:362) [shiro-web-1.3.2.jar!/:1.3.2]
	at org.apache.shiro.web.servlet.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:125) [shiro-web-1.3.2.jar!/:1.3.2]
	at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:193) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.springframework.web.filter.RequestContextFilter.doFilterInternal(RequestContextFilter.java:99) [spring-web-5.0.10.RELEASE.jar!/:5.0.10.RELEASE]
	at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:107) [spring-web-5.0.10.RELEASE.jar!/:5.0.10.RELEASE]
	at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:193) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.springframework.web.filter.HttpPutFormContentFilter.doFilterInternal(HttpPutFormContentFilter.java:109) [spring-web-5.0.10.RELEASE.jar!/:5.0.10.RELEASE]
	at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:107) [spring-web-5.0.10.RELEASE.jar!/:5.0.10.RELEASE]
	at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:193) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.springframework.web.filter.HiddenHttpMethodFilter.doFilterInternal(HiddenHttpMethodFilter.java:93) [spring-web-5.0.10.RELEASE.jar!/:5.0.10.RELEASE]
	at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:107) [spring-web-5.0.10.RELEASE.jar!/:5.0.10.RELEASE]
	at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:193) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.springframework.web.filter.CharacterEncodingFilter.doFilterInternal(CharacterEncodingFilter.java:200) [spring-web-5.0.10.RELEASE.jar!/:5.0.10.RELEASE]
	at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:107) [spring-web-5.0.10.RELEASE.jar!/:5.0.10.RELEASE]
	at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:193) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.apache.catalina.core.StandardWrapperValve.invoke(StandardWrapperValve.java:198) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.apache.catalina.core.StandardContextValve.invoke(StandardContextValve.java:96) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.apache.catalina.authenticator.AuthenticatorBase.invoke(AuthenticatorBase.java:493) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.apache.catalina.core.StandardHostValve.invoke(StandardHostValve.java:140) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.apache.catalina.valves.ErrorReportValve.invoke(ErrorReportValve.java:81) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.apache.catalina.core.StandardEngineValve.invoke(StandardEngineValve.java:87) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.apache.catalina.connector.CoyoteAdapter.service(CoyoteAdapter.java:342) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.apache.coyote.http11.Http11Processor.service(Http11Processor.java:800) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.apache.coyote.AbstractProcessorLight.process(AbstractProcessorLight.java:66) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.apache.coyote.AbstractProtocol$ConnectionHandler.process(AbstractProtocol.java:806) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.apache.tomcat.util.net.NioEndpoint$SocketProcessor.doRun(NioEndpoint.java:1498) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at org.apache.tomcat.util.net.SocketProcessorBase.run(SocketProcessorBase.java:49) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149) [na:1.8.0_242]
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624) [na:1.8.0_242]
	at org.apache.tomcat.util.threads.TaskThread$WrappingRunnable.run(TaskThread.java:61) [tomcat-embed-core-8.5.34.jar!/:8.5.34]
	at java.lang.Thread.run(Thread.java:748) [na:1.8.0_242]
```