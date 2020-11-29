---
title: Springboot开发文件上传功能
date: 2020-11-10 20:11:50
categories:
- Springboot
tags:
- javaweb
- Springboot
---

# Springboot开发文件上传功能

### 服务端准备

首先，需要在配置文件中配置上传路径，然后声明一个变量**contextPath**，并将文件路径属性注入，然后创建一个Controller：**uploadHeader**，这里我们以头像上传功能举例子来说明。

```java
	@Value("${community.path.upload}")
    private String uploadPath;

    @Value("${community.path.domain}")
    private String domain;

    @Value("${server.servlet.context-path}")
    private String contextPath;

	@RequestMapping(path = "/upload", method = RequestMethod.POST)
    public String uploadHeader(MultipartFile headerImage, Model model) {
        if (headerImage == null) {
            model.addAttribute("error", "您还没有选择图片!");
            return "/site/setting";
        }

        String fileName = headerImage.getOriginalFilename();
        String suffix = fileName.substring(fileName.lastIndexOf("."));
        if (StringUtils.isBlank(suffix)) {
            model.addAttribute("error", "文件的格式不正确!");
            return "/site/setting";
        }

        // 生成随机文件名
        fileName = CommunityUtil.generateUUID() + suffix;
        // 确定文件存放的路径
        File dest = new File(uploadPath + "/" + fileName);
        try {
            // 存储文件
            headerImage.transferTo(dest);
        } catch (IOException e) {
            logger.error("上传文件失败: " + e.getMessage());
            throw new RuntimeException("上传文件失败,服务器发生异常!", e);
        }
        // 更新当前用户的头像的路径(web访问路径)
        // http://localhost:8080/community/user/header/xxx.png
        User user = hostHolder.getUser();
        String headerUrl = domain + contextPath + "/user/header/" + fileName;
        userService.updateHeader(user.getId(), headerUrl);

        return "redirect:/index";
    }
```

SpringMVC为我们提供了一个文件上传类，**MultipartFile**，如果是多个文件，就用数组来表示。首先，我利用文件后缀来判断文件格式是否正确，然后 给文件重新分配一个新的随机的名字。然后调用· ` ` `headerImage.transferTo(dest);`来进行文件上传。



### 前端页面准备

前端需要定义一个表单，并且请求方法一定为POST，并且具备**enctype="multipart/form-data"**这个属性。

```xml
<form class="mt-5" method="post" enctype="multipart/form-data" th:action="@{/user/upload}">
					<div class="form-group row mt-4">
						<label for="head-image" class="col-sm-2 col-form-label text-right">选择头像:</label>
						<div class="col-sm-10">
							<div class="custom-file">
								<input type="file" th:class="|custom-file-input ${error!=null?'is-invalid':''}|"
									   id="head-image" name="headerImage" lang="es" required="">
								<label class="custom-file-label" for="head-image" data-browse="文件">选择一张图片</label>
								<div class="invalid-feedback" th:text="${error}">
									该账号不存在!
								</div>
							</div>
						</div>
					</div>
					<div class="form-group row mt-4">
						<div class="col-sm-2"></div>
						<div class="col-sm-10 text-center">
							<button type="submit" class="btn btn-info text-white form-control">立即上传</button>
						</div>
					</div>
				</form>
```