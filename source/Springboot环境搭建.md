---
title: Springboot环境搭建
date: 2020-11-10 20:08:54
categories:
- Springboot
tags:
- Springboot
- javaweb
- 环境搭建
---

# springboot开发环境搭建

## IDEA下springboot环境搭建

1. 首先新建项目，选择**springboot initializr** ,然后下一步，填写一些基本信息后下一步，进入依赖包的选择。这里就根据自己的需要选择需要用到的组件，然后下一步，填写项目名称，完成就好。

2. idea生成项目后，在resource目录下会有一个**application.properties**文件，在此文件里进行springboot的各项配置。例子如下：

   ```properties
   server.port=8082
   spring.thymeleaf.cache=false
   
   #datasource
   spring.datasource.driver-class-name=com.mysql.jdbc.Driver
   spring.datasource.url=jdbc:mysql://localhost:3306/community?characterEncoding=utf-8&useSSL=false&serverTimezone=Hongkong
   spring.datasource.username=root
   #注意修改密码
   spring.datasource.password=123456
   spring.datasource.type=com.zaxxer.hikari.HikariDataSource
   spring.datasource.hikari.maximum-pool-size=15
   spring.datasource.hikari.minimum-idle=5
   spring.datasource.hikari.idle-timeout=30000
   
   #mybatis
   mybatis.mapper-locations=classpath:mapper/*.xml
   mybatis.type-aliases-package=com.kai.entity
   mybatis.configuration.use-generated-keys=true
   mybatis.configuration.map-underscore-to-camel-case=true
   ```
	项目的目录结构如下：
	![urxXwT.png](https://s2.ax1x.com/2019/10/05/urxXwT.png)

3. pom.xml文件的配置

   在新建项目的时候，如果没有引入mybatis，那么在引入mybatis时需要引入两个包，分别为mybatis-spring-boot-starter和mysql-connector-java，配置如下

   ```xml
   <!-- https://mvnrepository.com/artifact/mysql/mysql-connector-java -->
           <dependency>
               <groupId>mysql</groupId>
               <artifactId>mysql-connector-java</artifactId>
               <version>5.1.47</version>
           </dependency>
           <!-- https://mvnrepository.com/artifact/org.mybatis.spring.boot/mybatis-spring-boot-starter -->
           <dependency>
               <groupId>org.mybatis.spring.boot</groupId>
               <artifactId>mybatis-spring-boot-starter</artifactId>
               <version>2.1.0</version>
           </dependency>
   ```



## 错误排除

1. idea找不到或无法加载主类

   解决方案：在.idea文件夹中找到worksspace.xml，修改其中的SRPING_MAIN_CLASS为我们的入口类，可能需要重启idea

   ```xml
   <configuration name="KaiApplication" type="SpringBootApplicationConfigurationType" factoryName="Spring Boot">
         <module name="springboot1" />
         <option name="SPRING_BOOT_MAIN_CLASS" value="com.kai.KaiApplication" />
         <method v="2">
           <option name="Make" enabled="true" />
         </method>
       </configuration>
   ```

2. 对于提示Java版本不对，可以在pom.xml中加入这条：

   ```xml
   <properties>
   		<java.version>12</java.version>
   </properties>
   ```
   






## 注：重要的文档

springboot的配置在官网有详细的文档：[官网文档链接](https://spring.io/projects/spring-boot#learn)