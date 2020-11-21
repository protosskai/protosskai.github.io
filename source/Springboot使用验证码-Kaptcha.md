---
title: Springboot使用验证码--Kaptcha
date: 2020-11-10 20:15:03
categories:
- Springboot
tags:
- 验证码
- Springboot
---

# Springboot使用验证码--Kaptcha

### 引入Kaptcha依赖

```xml
		<dependency>
			<groupId>com.github.penggle</groupId>
			<artifactId>kaptcha</artifactId>
			<version>2.3.2</version>
		</dependency>
```



### 创建一个Kaptcha配置类

利用java配置的方式，创建一个配置类，利用**@Bean**注解返回一个对象。

```java
@Configuration
public class KaptchaConfig {

    @Bean
    public Producer kaptchaProducer() {
        Properties properties = new Properties();
        //图片的宽度
        properties.setProperty("kaptcha.image.width", "100");
        //图片的高度
        properties.setProperty("kaptcha.image.height", "40");
        //设置字体大小
        properties.setProperty("kaptcha.textproducer.font.size", "32");
        //设置字体颜色
        properties.setProperty("kaptcha.textproducer.font.color", "0,0,0");
        //设置验证码的字符集
        properties.setProperty("kaptcha.textproducer.char.string", "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYAZ");
        //设置验证码长度
        properties.setProperty("kaptcha.textproducer.char.length", "4");
        //给验证码选择一个干扰类，用于生成一些线，点等等特效用于防破解
        properties.setProperty("kaptcha.noise.impl", "com.google.code.kaptcha.impl.NoNoise");

        DefaultKaptcha kaptcha = new DefaultKaptcha();
        Config config = new Config(properties);
        kaptcha.setConfig(config);
        return kaptcha;
    }

}
```



### 在Controller里面创建一个方法，用于给浏览器返回验证码图片

```java
@Autowired
private Producer kaptchaProducer;

@RequestMapping(path = "/kaptcha", method = RequestMethod.GET)
    public void getKaptcha(HttpServletResponse response, HttpSession session) {
        // 生成验证码
        String text = kaptchaProducer.createText();
        BufferedImage image = kaptchaProducer.createImage(text);

        // 将验证码存入session
        session.setAttribute("kaptcha", text);

        // 将图片输出给浏览器
        response.setContentType("image/png");
        try {
            OutputStream os = response.getOutputStream();
            ImageIO.write(image, "png", os);
        } catch (IOException e) {
            logger.error("响应验证码失败:" + e.getMessage());
        }
    }
```

首先，我们需要生成一段验证码，然后把验证码字符串存入session，用于之后的验证。然后，利用response对象，向浏览器返回图片。分为两步：

1. 设置response类型为image类型

   ` response.setContentType("image/png");`

2. 获取response的输出流，利用ImageIO类向输出流写入图片数据。

   ```java
   try {
               OutputStream os = response.getOutputStream();
               ImageIO.write(image, "png", os);
           } catch (IOException e) {
               logger.error("响应验证码失败:" + e.getMessage());
           }
   ```



### 将模板中验证码图片的路径修改为对应Controller的路径

直接看代码：

```html
<div class="col-sm-4">
<img th:src="@{/kaptcha}" id="kaptcha" style="width:100px;height:40px;" class="mr-2"/>
<a href="javascript:refresh_kaptcha();" class="font-size-12 align-bottom">刷新验证码</a>
</div>
```

其中，**th:src="@{/kaptcha}"**就是我们前面控制器写的路径。现在，我们访问页面应该就能拿到验证码图片了，并且验证码对应的字符串我们也存到了session里面，下面就是进行验证了。在实现验证之前，我先实现一下刷新验证码的功能。



### 实现刷新验证码的功能

直接看代码：

```javascript
var CONTEXT_PATH = "/community";

function refresh_kaptcha() {
    	//每次加一个随机数是为了防止请求路径相同，浏览器直接返回缓存，造成图片不刷新
		var path = CONTEXT_PATH + "/kaptcha?p=" + Math.random();
		$("#kaptcha").attr("src", path);
	}
```



### 验证

直接在登录的controller方法中从session中获取验证码字符串，在跟从浏览器提交的验证码对比就行了。