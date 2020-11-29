---
title: Springboot事务管理
date: 2020-11-10 20:13:51
categories:
- Springboot
tags:
- 事务
- Springboot
---

# Springboot事务管理

### 事务的隔离性

- 常见的并发异常
  - 第一类丢失更新，第二类丢失更新
  - 脏读，不可重复读，幻读
- 常见的隔离级别
  - Read Uncommitted：读取未提交的数据 。
  - Read Committed：读取已提交的数据。 
  - Repeatable Read：可重复读。 
  - Serializable：串行化。 



#### 第一类丢失更新

某一个事务的回滚，导致另外一个事务已更新的数据丢失了。 

| 时刻 | 事务1            | 事务2      |
| ---- | ---------------- | ---------- |
| T1   | Read:N=10        |            |
| T2   |                  | Read:N=10  |
| T3   |                  | Write:N=9  |
| T4   |                  | Commit:N=9 |
| T5   | Write:N=11       |            |
| T6   | Rollback: N = 10 |            |

可见，事务2本身正确提交了，没有回滚，但是事务1却触发了回滚，把正确提交的事务2给覆盖了，这就是第一类丢失更新。



#### 第二类丢失更新

某一个事务的提交，导致另外一个事务已更新的数据丢失了。 

| 时刻 | 事务1          | 事务2        |
| ---- | -------------- | ------------ |
| T1   | Read: N = 10   |              |
| T2   |                | Read: N = 10 |
| T3   |                | Write:N=9    |
| T4   |                | Commit:N=9   |
| T5   | Write: N = 11  |              |
| T6   | Commit: N = 11 |              |

事务2也是正确的提交了，事务1也是正确提交了，但是由于二者并发进行，导致事务1的提交覆盖了事务2的提交，这是第二类丢失更新。



#### 脏读

某一个事务，读取了另外一个事务未提交的数据。 

| 时刻 | 事务1            | 事务2        |
| ---- | ---------------- | ------------ |
| T1   | Read: N = 10     |              |
| T2   | Write: N = 11    |              |
| T3   |                  | Read: N = 11 |
| T4   | Rollback: N = 10 |              |

T2时刻，事务1写入了N=11，但是没有提交。在T3时刻，事务2读取了事务1写入的N=11，但是事务1在T4时刻触发了回滚，导致N=10，这是事务2读取到的N的值就不正确了。这就是脏读。



#### 不可重复读

某一个事务，对同一个数据前后读取的结果不一致。 

| 时刻 | 事务1          | 事务2        |
| ---- | -------------- | ------------ |
| T1   | Read: N = 10   |              |
| T2   |                | Read: N = 10 |
| T3   | Write: N = 11  |              |
| T4   | Commit: N = 11 |              |
| T5   |                | Read: N = 11 |

在T2时刻，事务2读取到了N=10,但是随后的T3,T4时刻，事务1将N更新为11，在T5时刻事务2又读取N=11，这时事务2读取到的N的值前后矛盾，这就是不可重复读。



#### 幻读

某一个事务，对同一个表前后查询到的行数不一致。 

| 时刻 | 事务1                  | 事务2                     |
| ---- | ---------------------- | ------------------------- |
| T1   |                        | Select: id < 10 (1,2,3)   |
| T2   | Insert: id = 4         |                           |
| T3   | Commit: id = (1,2,3,4) |                           |
| T4   |                        | Select: id < 10 (1,2,3,4) |

T1时刻事务2读取到了3行数据，而事务1在T2,T3时刻更新id为4行，在T4时刻事务2读取到id为4行。读取到的行数前后矛盾，这就是幻读。



### 事务的隔离级别

| 隔离级别         | 第一类丢失更新 | 脏读 | 第二类丢失更新 | 不可重复读 | 幻读 |
| ---------------- | -------------- | ---- | -------------- | ---------- | ---- |
| Read Uncommitted | Y              | Y    | Y              | Y          | Y    |
| Read Committed   | N              | N    | Y              | Y          | Y    |
| Repeatable Read  | N              | N    | N              | N          | Y    |
| Serializable     | N              | N    | N              | N          | N    |



#### 事务隔离实现机制

- 悲观锁（数据库） 

  - 共享锁（S锁） 

    事务A对某数据加了共享锁后，其他事务只能对该数据加共享锁，但不能加排他锁。 

  - 排他锁（X锁） 

    事务A对某数据加了排他锁后，其他事务对该数据既不能加共享锁，也不能加排他锁。 

- 乐观锁（自定义） 

  - 版本号、时间戳等 

    在更新数据前，检查版本号是否发生变化。若变化则取消本次更新，否则就更新数据（版本号+1）。 



### 事务的传播行为

事务的传播行为指的是：我有一个A方法，并且为A方法配置了一个隔离级别。然后我在A方法里面调用了B方法。但是我在B方法上也配置了隔离级别。那么，B方法该怎么选择策略进行回滚那？这就是传播行为。

| 传播行为类型 | 说明                                                         |
| ------------ | ------------------------------------------------------------ |
| REQUIRED     | 支持当前事务(外部事务),如果不存在则创建新事务.（就是以A方法的事务为准） |
| REQUIRES_NEW | 创建一个新事务,并且暂停当前事务(外部事务).就是以B方法自己的事务隔离级别为准 |
| NESTED       | 如果当前存在事务(外部事务),则嵌套在该事务中执行(独立的提交和回滚),否则就会REQUIRED一样. |



### Spring事务管理

- 声明式事务 
  - 通过XML配置，声明某方法的事务特征。 
  - 通过注解，声明某方法的事务特征。 
- 编程式事务 
  - 通过 TransactionTemplate 管理事务， 并通过它执行数据库的操作。 



#### Spring事务管理代码演示



##### 通过注解声明方法的事务

```java
	// REQUIRED: 支持当前事务(外部事务),如果不存在则创建新事务.
    // REQUIRES_NEW: 创建一个新事务,并且暂停当前事务(外部事务).
    // NESTED: 如果当前存在事务(外部事务),则嵌套在该事务中执行(独立的提交和回滚),否则就会REQUIRED一		样.
    @Transactional(isolation = Isolation.READ_COMMITTED, propagation = 			             Propagation.REQUIRED)
    public Object save1() {
        // 新增用户
        User user = new User();
        user.setUsername("alpha");
        user.setSalt(CommunityUtil.generateUUID().substring(0, 5));
        user.setPassword(CommunityUtil.md5("123" + user.getSalt()));
        user.setEmail("alpha@qq.com");
        user.setHeaderUrl("http://image.nowcoder.com/head/99t.png");
        user.setCreateTime(new Date());
        userMapper.insertUser(user);

        // 新增帖子
        DiscussPost post = new DiscussPost();
        post.setUserId(user.getId());
        post.setTitle("Hello");
        post.setContent("新人报道!");
        post.setCreateTime(new Date());
        discussPostMapper.insertDiscussPost(post);

        Integer.valueOf("abc");

        return "ok";
    }
```

通过**@Transactional**注解来指定事务的隔离级别和事务的传播行为。



##### 通过编程用TransactionTemplate 来管理事务

```java
	@Autowired
    private TransactionTemplate transactionTemplate;

public Object save2() {
        		transactionTemplate.setIsolationLevel(TransactionDefinition.ISOLATION_READ_COMMITTED);
       transactionTemplate.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRED);

        return transactionTemplate.execute(new TransactionCallback<Object>() {
            @Override
            public Object doInTransaction(TransactionStatus status) {
                // 新增用户
                User user = new User();
                user.setUsername("beta");
                user.setSalt(CommunityUtil.generateUUID().substring(0, 5));
                user.setPassword(CommunityUtil.md5("123" + user.getSalt()));
                user.setEmail("beta@qq.com");
                user.setHeaderUrl("http://image.nowcoder.com/head/999t.png");
                user.setCreateTime(new Date());
                userMapper.insertUser(user);

                // 新增帖子
                DiscussPost post = new DiscussPost();
                post.setUserId(user.getId());
                post.setTitle("你好");
                post.setContent("我是新人!");
                post.setCreateTime(new Date());
                discussPostMapper.insertDiscussPost(post);

                Integer.valueOf("abc");

                return "ok";
            }
        });
    }
```