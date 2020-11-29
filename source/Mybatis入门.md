---
title: Mybatis入门
date: 2020-11-10 18:19:49
categories: 
- mybatis
tags:
- javaweb
- mybatis
- 配置
---

# Mybatis入门

### 引入mybatis

1. 首先，引入相关的依赖，具体如下

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

2. 然后，在配置文件里配置数据源和mybatis的相关设置

   ```properties
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
   #在配置type-aliases-package后，以后写mapper.xml文件的时候，返回值类型和参数类型就不用写类的全限定#名了，直接写类名就行
   mybatis.type-aliases-package=com.kai.entity
   mybatis.configuration.use-generated-keys=true
   #当开启这个选项时，以驼峰式命名法命名的实体类就会被自动映射到数据库表里面以下划线分隔的字段
   mybatis.configuration.map-underscore-to-camel-case=true
   ```

3. - 首先，在数据库里面新建一张表

   - 然后在entity包里面建立一个对应这个表各个字段的bean。

   - 然后在dao包里面建立一个**接口**，用于对应对这个bean的各个操作的方法

   - 在springboot启动类上添加一个注解，**@MapperScan("com.kai.dao")**，用于扫描mapper

   - 然后在**resource文件夹**下面建立一个mapper文件夹，在mapper文件夹下面建立一个*.xml，这个xml就是这个bean的mapper文件，书写规则如下：

     ```xml
     <?xml version="1.0" encoding="UTF-8" ?>
     <!DOCTYPE mapper
             PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
             "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
     <!-- namespace必须是这个mapper对应的接口的全限定名 -->
     <mapper namespace="com.kai.dao.UserMapper">
         <!-- 定义一个sql语句，在引用的时候直接将这个语句内的内容插入，减少代码冗余 -->
         <sql id="selectField">
             id,username,password,salt,email,type,status,activation_code,header_url,create_time
         </sql>
     
         <sql id="insertField">
             username,password,salt,email,type,status,activation_code,header_url,create_time
         </sql>
     
         <!-- 因为开启了驼峰命名转换，所以type可以直接写类名，否则就得写类的全限定名-->
         <select id="selectById" resultType="User" parameterType="int">
             select <include refid="selectField"></include>
             from user
             where id = #{id}
         </select>
     
         <select id="selectByName" resultType="User" parameterType="int">
             select <include refid="selectField"></include>
             from user
             where username = #{username}
         </select>
     
         <select id="selectByEmail" resultType="User" parameterType="int">
             select <include refid="selectField"></include>
             from user
             where email = #{email}
         </select>
     
         <!-- keyProperty是实体类对应的数据表的主键名称，用于主键回填（自增） -->
         <!-- 注意，value里面填写的时实体类的属性，是驼峰式命名-->
         <insert id="insertUser" parameterType="User" keyProperty="id">
             insert into user (<include refid="insertField"></include>)
             value (#{username},#{password},#{salt},#{email},#{type},#{status},#{activationCode},#{headerUrl},#{createTime})
         </insert>
     
         <update id="updateStatus">
             update user set status = #{status} where id = #{id}
         </update>
     
         <update id="updateHeader">
             update user set header_url = #{headerUrl} where id = #{id}
         </update>
     
         <update id="updatePassword">
             update user set password = #{password} where id = #{id}
         </update>
     </mapper>
     ```

   - 之后在需要使用的时候注入mapper接口，然后使用方法就行了，例子如下：

     ```java
     	@Autowired
         private UserMapper mapper;
         @RequestMapping("/test")
         public String testMybatis(Model model){
             User user = mapper.selectById(101);
             model.addAttribute("name",user.getUsername());
             System.out.println(user);
             return "/demo/view";
         }
     ```

