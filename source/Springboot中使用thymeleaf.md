---
title: Springboot中使用thymeleaf
date: 2020-11-10 20:02:36
categories:
- Springboot
tags:
- springboot
- thymeleaf
- javaweb
---

# Springboot中使用thymeleaf

### 使用前的准备

springboot项目的目录结构如下图所示：

![usYFTx.png](https://s2.ax1x.com/2019/10/05/usYFTx.png)

其中，resources文件夹是存放资源文件的目录。其中，static文件夹是静态文件目录，用于存放css，js，img等静态资源文件。templates文件夹用于存放模板文件，也就是我们thymeleaf模板引擎所需要使用的html文件。我们将静态文件放在static文件夹内，把html文件放在templates文件夹内就做好了前期准备。

### thymeleaf的使用流程 

#### 声明模板引擎

首先，新建的html文件中，需要声明一下使用thymeleaf模板引擎，方法如下：

```html
<!doctype html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
```

在html标签后面填下这句即可。

#### 引入静态文件。

thymeleaf内置引入文件的语法，来帮助我们引入静态文件，方法如下：

```html
<link rel="stylesheet" th:href="@{/css/global.css}" />
<script th:src="@{/js/global.js}"></script>
```

在link标签中使用**th:href**。或者在src标签中使用**th:src**来取代原来的href和src。这样的话，thymeleaf就会自动去**/static**文件夹里面去找。

#### thymeleaf的模板语法

首先，我们先来看一段代码，来演示模板语法。在这段代码执行前，我已经通过controller传入了数据，如下：

```java
@RequestMapping(path = "/index", method = RequestMethod.GET)
    public String getIndexPage(Model model, Page page) {
        // 方法调用钱,SpringMVC会自动实例化Model和Page,并将Page注入Model.
        // 所以,在thymeleaf中可以直接访问Page对象中的数据.
        page.setRows(discussPostService.findDiscussPostRows(0));
        page.setPath("/index");

        List<DiscussPost> list = discussPostService.findDiscussPosts(0, page.getOffset(), page.getLimit());
        List<Map<String, Object>> discussPosts = new ArrayList<>();
        if (list != null) {
            for (DiscussPost post : list) {
                Map<String, Object> map = new HashMap<>();
                map.put("post", post);
                User user = userService.findUserById(post.getUserId());
                map.put("user", user);
                discussPosts.add(map);
            }
        }
        model.addAttribute("discussPosts", discussPosts);
        return "/index";
    }
```

这是一段Java代码，我向index模板添加了一个list，list中的每个元素都是一个map。

` model.addAttribute("discussPosts", discussPosts);`

map中存放的是一个**一篇文章**和**这个文章的user**。在了解了传递给模板的数据后，我们来看一下模板的内容。

```html
<li class="media pb-3 pt-3 mb-3 border-bottom" th:each="map:${discussPosts}">
						<a href="site/profile.html">
							<img th:src="${map.user.headerUrl}" class="mr-4 rounded-circle" alt="用户头像" style="width:50px;height:50px;">
						</a>
						<div class="media-body">
							<h6 class="mt-0 mb-3">
								<a href="#" th:utext="${map.post.title}">备战春招，面试刷题跟他复习，一个月全搞定！</a>
								<span class="badge badge-secondary bg-primary" th:if="${map.post.type==1}">置顶</span>
								<span class="badge badge-secondary bg-danger" th:if="${map.post.status==1}">精华</span>
							</h6>
							<div class="text-muted font-size-12">
								<u class="mr-3" th:utext="${map.user.username}">寒江雪</u> 发布于 <b th:text="${#dates.format(map.post.createTime,'yyyy-MM-dd HH:mm:ss')}">2019-04-15 15:32:18</b>
								<ul class="d-inline float-right">
									<li class="d-inline ml-2">赞 11</li>
									<li class="d-inline ml-2">|</li>
									<li class="d-inline ml-2">回帖 7</li>
								</ul>
							</div>
						</div>						
					</li>
```

首先，我们可以看出，这是一个**li列表**。为了能让列表根据传进来的数据进行循环渲染，我在li便签里面添加了一个**th:each**属性，来进行循环渲染。

```html
<li class="media pb-3 pt-3 mb-3 border-bottom" th:each="map:${discussPosts}">
```

在thymeleaf中，用${变量名}从环境中获取controller传递进来的数据。这里我就获取到了**discussPosts变量**，并给这个变量起了个别名**“map”**，用于在循环中使用。有前面的java代码可以知道，**discussPosts**就是一个列表。所以这个列表里面有多少个元素，这个li标签就会被循环渲染多少次。

在模板中，想要用变量来表示资源文件的路径也很简单。语法跟引入静态文件语法类似。就以上面的img标签举例子

```html
<img th:src="${map.user.headerUrl}" class="mr-4 rounded-circle" alt="用户头像" style="width:50px;height:50px;">
```

在这里，我们用**th:src**替换了src属性，这样就可以使用变量来表示地址了。

`${map.user.headerUrl}` 这个访问可以分为两个过程：

1. 因为map是我们在前面定义的discussPosts的一个元素，thymeleaf会自动识别出来我们这个元的的类型是一个**Map**,所以，我们使用**map.user**实际上就等价于**map.get("user")**.返回了一个User对象。
2. 前面返回了一个User对象，这是一个bean，所以我们在使用**user.headUrl**的时候，就相当于调用了user.getHeadUrl()方法，即调用了相应的getter方法，这样就是获取到数据了。



#### 常用标签

在模板中，想要用变量来替换标签的值，可以在标签中使用**th:text**属性。如下：

```html
<a href="#" th:utext="${map.post.title}">备战春招，面试刷题跟他复习，一个月全搞定！</a>
```

这样就会用**${map.post.title}**的值来替换掉“备战春招，面试刷题跟他复习，一个月全搞定！”这段文字了。当然，如果没有文字的话，自然就会直接显示**${map.post.title}**的值了。

如果标签内的文字有转义字符，例如**\&lt;**  代表**<**,如果我们想把转移字符显示出他应该的样子，就不能使用**th:text**,而实使用**th:utext**来代替。

我们还可以利用**th:if**进行条件渲染。**th:if**后面的条件如果为真，就渲染这个标签，否则就不渲染。

```html
<span class="badge badge-secondary bg-primary" th:if="${map.post.type==1}">置顶</span>
```

进行日期格式化输出的时候。可以使用thymeleaf内置的工具函数。

```html
<b th:text="${#dates.format(map.post.createTime,'yyyy-MM-dd HH:mm:ss')}"></b>
```

**#dates**表示调用内置的dates函数。

**th:href**如果想用变量来动态生成路径，可以用` th:href="@{${变量}(参数名=参数值，...)}" `

```html
<a class="page-link" th:href="@{${page.path}(current=1)}">首页</a>
```

为标签使用动态的class：

```html
<li th:class="|page-item ${page.current==1?'disabled':''}|">
```

如果class是由固定的class和动态生成的class拼接成的，需要加两个竖线，如上

**th:acton**标签用于表单提交的路径。这个标签会自动设置相对路径，大概是直接设置好项目路径。

```html
<form class="mt-5" method="post" th:action="@{/login}">
```

其中**th:action="@{/login}"**在浏览器端会被渲染为**action="/community/login"**，其中，**community**是项目的路径。