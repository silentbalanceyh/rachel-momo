# Rachel Momo - Maven 统一版本管理

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Maven Central](https://img.shields.io/badge/maven--central-1.0.0--SNAPSHOT-blue)](https://search.maven.org/)

一个用于统一管理 Maven 项目依赖版本的父 POM，适用于所有基于 Java 的项目。

## 📋 特性

- 🎯 **集中化版本管理** - 所有依赖版本在一个地方统一管理
- 📦 **常用依赖预配置** - Spring Boot、MyBatis、Redis 等常用库已配置
- 🔧 **标准化构建** - 统一的构建插件配置
- 🚀 **最新技术栈** - 基于 Spring Boot 3.2.0 和 Java 17
- ☕ **开箱即用** - 无需复杂配置，继承即可使用

## 🚀 快速开始

在你的项目 `pom.xml` 中添加父依赖：

```xml
<parent>
    <groupId>io.github.silentbalanceyh</groupId>
    <artifactId>rachel-momo</artifactId>
    <version>1.0.0-SNAPSHOT</version>
</parent>
```

然后使用已管理的依赖（无需指定版本）：

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
    </dependency>
</dependencies>
```

## 📚 文档

详细使用文档请查看 [USAGE.md](USAGE.md)

## 🔧 已管理的主要依赖

- Spring Boot 3.2.0
- Spring Cloud 2023.0.0
- MyBatis Plus 3.5.5
- MySQL 8.0.33
- Redis (Redisson 3.25.2)
- Lombok 1.18.30
- Hutool 5.8.24
- 更多依赖请查看 [pom.xml](pom.xml)

## 📦 本地安装

```bash
git clone https://github.com/silentbalanceyh/rachel-momo.git
cd rachel-momo
mvn clean install
```

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 👨‍💻 作者

**Silent Balance** - [@silentbalanceyh](https://github.com/silentbalanceyh)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！
