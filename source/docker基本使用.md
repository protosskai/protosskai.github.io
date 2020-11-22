---
title: docker基本使用
date: 2020-11-21 15:17:49
categories:
- docker
tags:
- docker
---

# docker基本使用

## 基本操作

使用docker的时候必须使用root权限。所以在使用前，最好将使用docker的用户加入到**docker**这个用户组（docker用户组和root的权限一样）

```bash
sudo usermod -aG docker ${USER}
sudo service docker restart
```

### 搜索镜像(docker search)

```bash
docker search 镜像名
```

使用docker search 命令可以在dockers hub中搜索镜像，例如

```bash
docker search ubuntu
```

结果如下：

[![D1tW9I.png](https://s3.ax1x.com/2020/11/21/D1tW9I.png)](https://imgchr.com/i/D1tW9I)

### 下载镜像(docker pull)

```bash
docker pull 镜像名:标签
```

docker pull可以从dockers hub中下载镜像。如果想要下载指定用户上传的镜像，则利用一下语法：

```bash
docker pull 用户名/镜像名:标签
```

### 列出镜像(docker images)

```bash
docker images
```

这个命令可以列出当前主机中的所有镜像。如果在后面指定了名称的话，则只列出名称相同但标签不同的镜像。

```bash
docker images ubuntu
```

[![D1UKyV.png](https://s3.ax1x.com/2020/11/21/D1UKyV.png)](https://imgchr.com/i/D1UKyV)

### 创建容器(docker run)

1. 创建容器后，运行shell

    ```bash
    docker run -i -t --name hello centos /bin/bash
    ```

    - -i -t 两个选项一起使用可以分配一个终端设备然后连接到这个终端。
    - /bin/bash 表示运行容器后直接执行bash

    执行结果：

    [![D1U6fA.png](https://s3.ax1x.com/2020/11/21/D1U6fA.png)](https://imgchr.com/i/D1U6fA)

    可以看到，已经进入了centos的终端。

2. 后台运行镜像

    ```bash
    docker run --name hello-nginx -d -p 80:80 -v /root/data:/data hello:0.1
    ```

    - -d 表示以后台的形式运行这个镜像
    - -p 表示映射端口，主机端口号：容器端口号
    - -v 表示将主机的/root/data目录连接到容器的/data目录

    下面我们在本机浏览器访问127.0.0.1查看结果(hello是我自己打包带一个镜像，具体看后文构建镜像部分)

    [![D1a9h9.png](https://s3.ax1x.com/2020/11/21/D1a9h9.png)](https://imgchr.com/i/D1a9h9)

    可以看到已经成功的启动了nginx服务

    ### 查看当前运行的容器(docker ps)

    ```bash
    docker ps
    ```

    这个命令会列出所有正在运行的容器

    [![D1aV0O.png](https://s3.ax1x.com/2020/11/21/D1aV0O.png)](https://imgchr.com/i/D1aV0O)

    如果输入

    ```bash
docker ps -a
    ```
    
    那么会列出所有的容器，包括停止的

    ### 停止容器

    首先，利用ps命令查看当前运行的镜像

    ```bash
    docker ps
    ```

    [![D1aV0O.png](https://s3.ax1x.com/2020/11/21/D1aV0O.png)](https://imgchr.com/i/D1aV0O)

    然后，我们结束掉hello-nginx这个容器

    ```bash
    docker stop hello-nginx
    ```

    命令执行后，这个容器就被关掉了，然后再次访问127.0.0.1，也无法获得服务了

    ### 启动容器
    
    ```bash
docker start 容器名
    ```
    
    例如：
    
    ```bash
    docker start hello-nginx 
    ```
    
    这样的话刚刚关闭的这个nginx容器就又重新启动了，访问127.0.0.1又可以获得服务了

### 连接到容器(docker attach)

首先，如果我们进入了一个容器的shell，那么我们可以使用exit来退出容器，这样的话容器也会终止。但是我们可以一次输入Ctrl+P , Ctrl+Q，这样的话就可以退出容器但容器还正常运行。

此时，如果我们想重新连接到容器的话，可以输入一下命令：

```bash
docker attach 容器名
```

### 外部执行容器内部命令(docker exec)

如果容器正在运行的话，可以使用exec命令来从外部执行容器的命令，而无需连接到容器的shell

```bash
docker exec hello-nginx ls
```

[![D1dIRs.png](https://s3.ax1x.com/2020/11/21/D1dIRs.png)](https://imgchr.com/i/D1dIRs)



### 删除容器(docker rm)

```bash
docker rm 容器名
```

### 删除镜像(docker rmi)

```bash
docker rmi 镜像名:标签
```

## 镜像操作

### 查看镜像历史

```bash
docker history 镜像名:标签
```

使用history命令可以查看指定镜像的构建历史，对应的每一层镜像是怎么构建出来的。

```bash
docker history hello-nginx:0.1
```

[![D8FuNQ.png](https://s3.ax1x.com/2020/11/22/D8FuNQ.png)](https://imgchr.com/i/D8FuNQ)

### 从容器内复制文件

```bash
docker cp 容器名:容器内路径 主机路径 
```

例如

```bash
docker cp hello:/etc/nginx/nginx.conf ./
```

执行上面的指令后，容器内的nginx.conf将被复制到主机内

### 从容器的修改中创建镜像

```bash
docker commit 选项 容器名 镜像名:标签
```

例如：

首先，先创建一个容器,这里以centos镜像为例

```bash
docker run -it --name centos_test centos /bin/bash
```

然后再容器内创建一个文件

```bash
[root@5e4e3a665f71 /]# touch test.txt
```

然后输入exit退出容器，接着运行下面的命令来从容器的修改中创建镜像

```bash
docker commit -a "zhangkai" -m "test" centos_test centos
```

这样我们就更新了centos镜像了。

### 检查容器中文件的修改

```bash
docker diff 容器名
```

此命令可以对比容器和创建容器的镜像的文件差异。

```bash
docker diff centos_test
```

[![D8EkcR.png](https://s3.ax1x.com/2020/11/22/D8EkcR.png)](https://imgchr.com/i/D8EkcR)

A为添加的文件，C为修改的文件，D为删除的文件

### 查看容器详细信息

```bash
docker inspect 容器名
```

此命令显示容器和镜像的详细信息

```bash
docker inspect centos_test
```

部分结果如下：

[![D8Ea4g.png](https://s3.ax1x.com/2020/11/22/D8Ea4g.png)](https://imgchr.com/i/D8Ea4g)

## 构建镜像

### 基本流程 

通过编写Dockerfile的形式可以构建镜像。下面就以搭建一个nginx服务器为例演示一下。

```dockerfile
FROM ubuntu:18.04
MAINTAINER Foo Bar <foo@bar.com>

RUN apt update
RUN apt install -y nginx
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf
RUN chown -R www-data:www-data /var/lib/nginx

VOLUME ["/data", "/etc/nginx/site-enabled", "/var/log/nginx"]

WORKDIR /etc/nginx
CMD ["nginx"]
EXPOSE 80
EXPOSE 443
```

* FROM:表示该镜像基于那个基础镜像构建。指令格式为：

    ```bash
    FROM 镜像名称:标签
    ```

* MAINTAINER:指定镜像的维护者信息

* RUN：运行shell脚本或者命令。

* CMD：指定容器启动时执行的文件或shell脚本

* WORKDIR：为CMD中设置的可执行文件设置运行目录

* EXPOSE：与主机相连的端口号



在编写完Dockerfile之后，就可以利用该文件来构建镜像。命令格式如下：

```bash
docker build 选项 Dockerfile路径
```

例如：

```bash
docker build --tag hello:0.1 .
```

* --tag指定镜像的名字和标签，若只设置镜像名称，镜像标签就为latest

在创建完毕后，就可以docker run来运行镜像。

### 构建指令

#### Build 上下文的概念

在使用 docker build 命令通过 Dockerfile 创建镜像时，会产生一个 build 上下文(context)。所谓的 build 上下文就是 docker build 命令的 PATH 或 URL 指定的路径中的文件的集合。在镜像 build 过程中可以引用上下文中的任何文件，比如我们要介绍的 COPY 和 ADD 命令，就可以引用上下文中的文件。

默认情况下 docker build -t testx . 命令中的 . 表示 build 上下文为当前目录。当然我们可以指定一个目录作为上下文，比如下面的命令：

```bash
docker build -t testx /home/nick/hc
```

我们指定 /home/nick/hc 目录为 build 上下文，默认情况下 docker 会使用在上下文的根目录下找到的 Dockerfile 文件。

#### FROM指令

FROM指令用于设置基础镜像，Dockerfile总是以已有镜像为基础，所以必须使用FROM命令。即可只使用镜像名称，也可以同时使用名称和标签。只使用名称时，标签自动为latest。镜像名称不可以省略。

```bash
FROM 镜像名称:标签
```

#### MAINTAINER指令

MAINTAINER指令用于设置镜像的创建者信息，格式自由。

```bash
MAINTAINER 创建者信息
```

#### RUN指令

RUN指令用于在FROM中设置的镜像上面运行脚本或者命令。RUN运行结果会生成新的镜像。

RUN指令有两种，一种是利用镜像内的/bin/sh程序执行命令，如果镜像内不存在/bin/sh，则无法使用，这时使用方法如下：

```dockerfile
RUN 命令
# 例如
RUN apt install -y nginx
```

第二种方式是不借助shell，直接执行可执行文件，方法如下：

```dockerfile
RUN ["程序", "参数一", "参数二", "参数N"]
# 例如
RUN ["apt", "install", "-y", "nginx"]
```



每个成功运行的RUN命令都会创建一个镜像，每个RUN的执行结果会被缓存，如果不想使用缓存结果，只需要在docker build命令中加入--no-cache即可

#### CMD指令

CMD指令用于设置容器启动时运行的脚本或者命令，即使用docker run 或者docker start时会执行的命令。在Dockerile文件中CMD命令只能使用一次。CMD的语法和RUN命令一样，就不重复了。

#### ENTRYPOINT指令：

ENTRYPOINT的使用方法和CMD一样，功能也一样，都是用于设置容器启动时运行的脚本或者命令。二者的不同在于：

* 在shell写法下，如果存在ENTRYPOINT 指令，那么CMD命令和docker run后面输入的指令都不会执行，会强制执行ENTRYPOINT后面的指令

* 在exec写法下，如果在ENTRYPOINT前面有CMD，那么CMD数组中的所有元素都会被当做ENTRYPOINT的参数，例如：

    ```dockerfile
    CMD ["hello"]
    ENTRYPOINT ["echo"]
    ```

    以上两句会输出一个"hello"字符串

#### EXPOSE指令

EXPOSE指令用来声明容器暴露出的端口，但并不会直接打开这些端口。他只是为了告诉别人容器中用到了哪些端口。如果想要在宿主机上访问这些端口，还需要通过docker -p 来映射端口。另外，当利用docker -P时，也会将EXPOSE的端口随机映射。

#### ENV指令

ENV指令用于设置环境变量。使用ENV设置的环境变量适用于RUN，CMD，ENTRYPOINT

```dockerfile
ENV 环境变量 值
ENV GOPATH /go # 设置GOPATH变量的值为/go
ENV PATH /go/bin:$PATH #在PATH变量前面加上/go/bin:
```

在ENV设置完变量后，上述三个命令就可以访问了

```dockerfile
ENV GOPATH /go # 设置GOPATH变量的值为/go
RUN echo $GOPATH
```

上面两句会打印出/go这个字符串

#### COPY指令

COPY指令会简单的将文件复制到镜像中。

```dockerfile
COPY 要复制的文件的路径 文件要复制到镜像中的路径
```

* 要复制的文件的路径要以上下文
* 要复制的文件的路径不能设置为网络URL
* 要复制的文件的路径可以为目录。当设置为目录时，会复制目录下所有文件，另外也可以使用通配符复制特定文件
* 文件要复制到镜像中的路径需要是绝对路径
* 添加当前目录时，.dockerignore文件中设置的文件和目录会被忽略

#### ADD指令

ADD指令也用于向镜像中添加文件。下面列举和COPY的不同

```bash
ADD 要复制的文件的路径 文件要复制到镜像中的路径
```

* **要复制的文件的路径**可以为网络路径。

```dockerfile
ADD http://example.com/hello.sh /home/hello.sh
```

* 如果**要复制的文件**为压缩包时，ADD指令会自动解压缩并添加。但是如果从网络中下载一个压缩包时，不会解压缩。

#### VOLUME指令

VOLUME指令可以讲容器中的目录挂载到本机的目录上，这样容器中写入数据时就可以直接存储到宿主机上。

```dockerfile
VOLUME 容器中的路径 #方式一
VOLUME ["容器中的路径",  "宿主机中的路径"] #方式二
```

* 方式一这里的 /data 目录就会在运行时自动挂载为匿名卷，任何向 /data 中写入的信息都不会记录进容器存储层，从而保证了容器存储层的无状态化。当然，运行时可以覆盖这个挂载设置。比如：

    ```bash
    docker run -d -v mydata:/data 镜像名
    ```

    在这行命令中，就使用了 mydata 这个命名卷挂载到了 /data 这个位置，替代了 Dockerfile 中定义的匿名卷的挂载配置。

* 方式二会将容器中的路径挂载到宿主机中的路径。这样向容器中的目录就和宿主机中的目录共享了。

#### USER指令

USER指令用于设置运行命令的用户。用于RUN， CMD， ENTRYPOINT

```dockerfile
USER root
```

USER后面所有的RUN，CMD，ENTRYPOINT都会得到应用。中间可以使用USER命令更换用户

#### WORKDIR指令

WORKDIR指令用于设置RUN，CMD，ENTRYPOINT命令的目录。

```dockerfile
WORKDIR 路径
```

WORKDIR指令对之后的RUN，CMD，ENTRYPOINT都生效，中间可以用WORKDIR命令更换目录。

WORKDIR指令也可以使用相对路径，最初相对的路径为/，之后每次相对的都是之前的路径

```dockerfile
WORKDIR var # 此时路径为/var
WORKDIR www # 此时路径为/var/www
```

#### ONBUILD指令

如果以当前镜像作为基础镜像时，ONBUILD就会在引用次镜像的Dockerfile的FROM指令后执行ONBUILD指令。

```dockerfile
ONBUILD RUN touch hello.txt
```

