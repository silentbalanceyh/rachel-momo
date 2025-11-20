# Sample Application

这是一个示例应用程序，展示如何使用 rachel-momo 父 POM。

## 运行应用

```bash
mvn spring-boot:run
```

## 访问应用

应用启动后，可以访问以下端点：

- http://localhost:8080/api/hello - 测试端点
- http://localhost:8080/api/health - 健康检查
- http://localhost:8080/h2-console - H2 数据库控制台

## 构建应用

```bash
mvn clean package
```

## 特点

此示例应用展示了：

1. **依赖版本管理**: 所有依赖都从父 POM 继承版本，无需显式指定
2. **Lombok 使用**: Entity 类使用 @Data 注解
3. **Hutool 使用**: Controller 中使用 Hutool 的 IdUtil 生成 UUID
4. **Spring Boot 集成**: 使用 Spring Boot Starter 快速构建应用
5. **JPA 支持**: 使用 Spring Data JPA 和 H2 数据库

## 项目结构

```
sample-application/
├── pom.xml
└── src/
    └── main/
        ├── java/
        │   └── com/
        │       └── example/
        │           └── demo/
        │               ├── DemoApplication.java
        │               ├── controller/
        │               │   └── DemoController.java
        │               └── entity/
        │                   └── User.java
        └── resources/
            └── application.properties
```
