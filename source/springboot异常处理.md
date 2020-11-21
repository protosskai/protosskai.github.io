---
title: springboot异常处理
date: 2020-11-10 20:15:55
categories:
- Springboot
tags:
- 异常处理
- Springboot
---

# springboot异常处理

### 对于http错误状态码的默认处理

对于http状态码，springboot自动配置了一个简易的处理方法。在templates文件夹下面建立一个名为**error**的文件夹，然后在里面放入文件名格式为“状态码.html”的文件，当发生对应的错误时，springboot就会帮助我们自动返回相应的页面。

![u2mKIS.png](https://s2.ax1x.com/2019/10/07/u2mKIS.png)



### 利用@ControllerAdvice注解进行异常处理

当控制器出现异常的时候，@ControllerAdvice注解可以对Controller进行拦截。具体使用方法如下：

我们首先新建一个类**ExceptionAdvice**，并且加上@ControllerAdvice注解。具体实现如下：

```java
	@ControllerAdvice(annotations = Controller.class)
	public class ExceptionAdvice {

    private static final Logger logger = LoggerFactory.getLogger(ExceptionAdvice.class);

    @ExceptionHandler({Exception.class})
    public void handleException(Exception e, HttpServletRequest request, 			            HttpServletResponse response) throws IOException {
        logger.error("服务器发生异常: " + e.getMessage());
        for (StackTraceElement element : e.getStackTrace()) {
            logger.error(element.toString());
        }

        String xRequestedWith = request.getHeader("x-requested-with");
        if ("XMLHttpRequest".equals(xRequestedWith)) {
            response.setContentType("application/plain;charset=utf-8");
            PrintWriter writer = response.getWriter();
            writer.write(CommunityUtil.getJSONString(1, "服务器异常!"));
        } else {
            response.sendRedirect(request.getContextPath() + "/error");
        }
    }

}
```

	首先，**@ControllerAdvice(annotations = Controller.class)**说明只对被Controller注解标记的方法进行拦截。然后我们在**ExceptionAdvice**里面实现了**handleException**方法，方法名可以随便起，但是一定是public void，并且被**@ExceptionHandler**注解修饰。**@ExceptionHandler({Exception.class})**的参数为这个方法拦截的异常类型，这里我们用**Exception.class**表示拦截所有的异常。**ExceptionAdvice**的参数是spring自动为我们传入的，我们一般用这三个参数就够用了。
	
	然后，在**handleException**方法内，我们还需要对请求头进行判断，来确定是正常的get请求还是ajax请求。在这里，我们读取request的**x-requested-with**头，来判断请求类型。根据不同的请求类型来返回不同的行为，如果请求 是Ajax，我们直接获取输出流，对客户端浏览器进行写入json字符串。如果请求是正常请求，则重定向到错误界面。


​	