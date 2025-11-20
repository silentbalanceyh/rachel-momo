# Rachel Momo - Maven 统一版本管理

一个用于统一管理 Maven 项目依赖版本的父 POM，适用于所有基于 Java 的项目。

## 特性

- 🎯 集中化版本管理
- 📦 常用依赖版本统一定义
- 🔧 标准化构建插件配置
- 🚀 基于 Spring Boot 3.2.0 和 Spring Cloud 2023.0.0
- ☕ 支持 Java 17+

## 快速开始

### 1. 在项目中使用此父 POM

在你的项目 `pom.xml` 中添加父依赖：

```xml
<parent>
    <groupId>io.github.silentbalanceyh</groupId>
    <artifactId>rachel-momo</artifactId>
    <version>1.0.0-SNAPSHOT</version>
</parent>
```

### 2. 使用管理的依赖

无需指定版本号，直接使用已定义的依赖：

```xml
<dependencies>
    <!-- Spring Boot Web -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>

    <!-- Lombok -->
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
    </dependency>

    <!-- MySQL Driver -->
    <dependency>
        <groupId>com.mysql</groupId>
        <artifactId>mysql-connector-j</artifactId>
    </dependency>

    <!-- MyBatis Plus -->
    <dependency>
        <groupId>com.baomidou</groupId>
        <artifactId>mybatis-plus-boot-starter</artifactId>
    </dependency>
</dependencies>
```

## 已管理的依赖版本

### 框架版本

| 框架 | 版本 |
|------|------|
| Spring Boot | 3.2.0 |
| Spring Cloud | 2023.0.0 |

### 数据库驱动

| 依赖 | 版本 |
|------|------|
| MySQL Connector | 8.0.33 |
| PostgreSQL | 42.7.1 |
| H2 Database | 2.2.224 |

### 持久层框架

| 依赖 | 版本 |
|------|------|
| MyBatis Spring Boot Starter | 3.0.3 |
| MyBatis Plus | 3.5.5 |
| Druid | 1.2.20 |

### 缓存

| 依赖 | 版本 |
|------|------|
| Redisson | 3.25.2 |
| Jedis | 5.1.0 |

### 工具库

| 依赖 | 版本 |
|------|------|
| Lombok | 1.18.30 |
| Hutool | 5.8.24 |
| Guava | 32.1.3-jre |
| Fastjson2 | 2.0.44 |
| Jackson | 2.16.0 |
| Commons Lang3 | 3.14.0 |
| Commons Collections4 | 4.4 |
| Commons IO | 2.15.1 |

### 测试框架

| 依赖 | 版本 |
|------|------|
| JUnit Jupiter | 5.10.1 |
| Mockito | 5.8.0 |
| AssertJ | 3.24.2 |

## 已配置的构建插件

- **maven-compiler-plugin** (3.11.0) - Java 编译器配置
- **maven-surefire-plugin** (3.2.3) - 单元测试执行
- **maven-resources-plugin** (3.3.1) - 资源文件处理
- **maven-jar-plugin** (3.3.0) - JAR 打包
- **maven-source-plugin** (3.3.0) - 源码打包
- **maven-javadoc-plugin** (3.6.3) - JavaDoc 生成
- **maven-deploy-plugin** (3.1.1) - 部署配置
- **spring-boot-maven-plugin** (3.2.0) - Spring Boot 打包

## 项目配置

### 默认配置

```properties
# 编码
project.build.sourceEncoding=UTF-8
project.reporting.outputEncoding=UTF-8

# Java 版本
maven.compiler.source=17
maven.compiler.target=17
java.version=17
```

## 示例项目结构

```
my-project/
├── pom.xml (继承 rachel-momo)
├── src/
│   ├── main/
│   │   ├── java/
│   │   └── resources/
│   └── test/
│       ├── java/
│       └── resources/
```

### 完整示例 pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>io.github.silentbalanceyh</groupId>
        <artifactId>rachel-momo</artifactId>
        <version>1.0.0-SNAPSHOT</version>
    </parent>

    <groupId>com.example</groupId>
    <artifactId>my-application</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <packaging>jar</packaging>

    <name>My Application</name>
    <description>示例应用程序</description>

    <dependencies>
        <!-- Spring Boot Web -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <!-- Spring Boot Data JPA -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>

        <!-- MySQL -->
        <dependency>
            <groupId>com.mysql</groupId>
            <artifactId>mysql-connector-j</artifactId>
            <scope>runtime</scope>
        </dependency>

        <!-- Lombok -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <scope>provided</scope>
        </dependency>

        <!-- Hutool -->
        <dependency>
            <groupId>cn.hutool</groupId>
            <artifactId>hutool-all</artifactId>
        </dependency>

        <!-- Test -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

## 优势

1. **版本一致性**: 所有子项目使用相同的依赖版本，避免版本冲突
2. **简化维护**: 只需在父 POM 中更新版本，所有子项目自动继承
3. **标准化**: 统一的构建配置和插件设置
4. **快速开发**: 新项目可以快速继承标准配置
5. **易于升级**: 集中式版本管理使得升级更加容易和安全

## 本地安装

如果需要在本地使用此父 POM，可以执行：

```bash
mvn clean install
```

## 许可证

MIT License

## 作者

Silent Balance - [@silentbalanceyh](https://github.com/silentbalanceyh)

## 贡献

欢迎提交 Issue 和 Pull Request！
