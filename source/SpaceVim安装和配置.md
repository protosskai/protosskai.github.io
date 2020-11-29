---
title: SpaceVim安装和配置
date: 2020-11-12 14:41:19
categories:
- vim
tags:
- SpaceVim
- vim
---

# SpaceVim的安装和配置

## 为什么选择Vim

因为经常有在linux下面编写代码的需求。这里之所以选择vim而不是专用的IDE是因为时常会以ssh的形式连接到服务器去编写代码，所以图形界面并不都是支持的，所以抽空学习了一下vim。简单的熟悉了一下vim的基本使用方法之后，发现vim配置起来十分的繁琐，而我又不想牵扯太多的精力在vim的配置上面，所以就使用了这个比较方便的Spacevim项目，这个项目里面配置了许多常用的设置，并且安装了一些插件，可以做到开箱即用，因此选择了他，另外，华丽的界面和便捷的操作也是很重要的加分项。下面就是安装完毕后的样子。

[![Bxb26g.md.png](https://s3.ax1x.com/2020/11/12/Bxb26g.md.png)](https://imgchr.com/i/Bxb26g)

## SpaceVim的安装

Spacevim的官网：https://spacevim.org/cn/

安装步骤：

Spacevim的安装步骤很简单，按照官网的指引去做就可以了。

首先，在Linux平台下面，下载官方的安装脚本并运行：

```bash
curl -sLf https://spacevim.org/cn/install.sh | bash
```

输入以上命令之后，就会自动安装Spacevim这个项目。安装完毕之后，第一次打开vim的时候就回去自动安装各种插件，并配置好环境。

如果想要卸载的话，运行一下的命令：

```bash
curl -sLf https://spacevim.org/cn/install.sh | bash -s -- -h
```

上述命令会显示各种操作，找到卸载的操作并且输入命令即可。



## 字体的安装

SpaceVim会使用图标字体，因此如果当前系统下没有图标字体的话，那么打开vim的时候就会出现一部分文字的乱码，解决方法就是安装对应的图标字体，安装方法如下：

这里以nerd-font为例，演示Linux下字体的安装

nerd-font的git仓库链接：https://github.com/ryanoasis/nerd-fonts/releases/tag/v2.1.0

进入上述链接，找到你想要使用的一款字体，这里以**DejaVuSansMono**字体为例。

[![Bxbg1S.png](https://s3.ax1x.com/2020/11/12/Bxbg1S.png)](https://imgchr.com/i/Bxbg1S)

下载完毕后，进入下载文件夹执行以下命令

```bash
sudo unzip DejaVuSansMono.zip -d /usr/share/fonts/DejaVuSansMono
```

然后

```bash
cd /usr/share/fonts/DejaVuSansMono
sudo mkfontscale # 生成核心字体信息
sudo mkfontdir # 生成字体文件夹
sudo fc-cache -fv # 刷新系统字体缓存
```

按照以上步骤操作后，图标字体就被安装到系统中了，下一步就是要给终端设置刚刚安装好的字体。具体方法根据你是用的终端来设置。

## 常用的操作

### 快捷键

Spacevim的leader键为反斜杠\，SPC键为空格。在普通模式下，按下空格后，等待一个间隔，就会出现提示菜单来提示后续的快捷键，当我们忘记某个快捷键时可以利用此方式来查看。

[![BxqK9f.png](https://s3.ax1x.com/2020/11/12/BxqK9f.png)](https://imgchr.com/i/BxqK9f)

### 常用快捷键

使用文档：https://spacevim.org/cn/documentation/

#### 窗口管理

常用的窗口管理快捷键有一个统一的前缀，默认的前缀 `[Window]` 是按键 `s`，可以在配置文件中通过修改 SpaceVim 选项 `window_leader` 的值来设为其它按键：

```
[options]
    windows_leader = "s"
```

Ctrl加方向键可以切换窗口

q  关闭当前窗口

`[Window]` v 水平分屏

`[Window]` g 垂直分屏

`[Window]` t  新建标签页 

F3 打开文件管理器

#### 滚动操作

Ctrl e  向下滚动

Ctrl y 向上滚动

Ctrl f 向下翻页

Ctrl b 向上翻页

#### 复制粘贴

<leader> 为反斜杠\

<leader> y 复制文本至系统剪切板

<Leader> p 粘贴系统剪切板文字至当前位置之后

<Leader> P 粘贴系统剪切板文字至当前位置之前

