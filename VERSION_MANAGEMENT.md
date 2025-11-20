# 版本管理说明 (Version Management Guide)

## 概述 (Overview)

本项目提供了一个统一的 Maven 父 POM，用于管理所有 Java 项目的依赖版本。通过集中管理依赖版本，可以：

1. **避免版本冲突** - 确保所有子项目使用一致的依赖版本
2. **简化维护** - 只需在一处更新版本，所有项目自动继承
3. **提高开发效率** - 新项目无需重复配置依赖版本
4. **标准化构建** - 统一的插件配置确保构建一致性

## 项目结构 (Project Structure)

```
rachel-momo/
├── pom.xml                          # 父 POM，定义所有版本
├── .gitignore                       # Git 忽略配置
├── README.md                        # 项目介绍
├── USAGE.md                         # 详细使用文档
├── VERSION_MANAGEMENT.md            # 本文档
└── examples/                        # 示例项目
    └── sample-application/          # Spring Boot 示例应用
        ├── pom.xml                  # 继承父 POM
        ├── README.md                # 示例说明
        └── src/                     # 源代码
```

## 核心功能 (Core Features)

### 1. 依赖版本管理

父 POM 通过 `<dependencyManagement>` 节点管理以下类型的依赖：

#### 核心框架
- Spring Boot 3.2.0
- Spring Cloud 2023.0.0

#### 数据库
- MySQL 8.0.33
- PostgreSQL 42.7.1
- H2 2.2.224

#### 持久层
- MyBatis Spring Boot 3.0.3
- MyBatis Plus 3.5.5
- Druid 1.2.20

#### 缓存
- Redisson 3.25.2
- Jedis 5.1.0

#### 工具库
- Lombok 1.18.30
- Hutool 5.8.24
- Guava 32.1.3-jre
- Fastjson2 2.0.44
- Apache Commons (Lang3, Collections4, IO)

#### 测试框架
- JUnit Jupiter 5.10.1
- Mockito 5.8.0
- AssertJ 3.24.2

### 2. 插件版本管理

通过 `<pluginManagement>` 节点管理构建插件：

- maven-compiler-plugin 3.11.0
- maven-surefire-plugin 3.2.3
- maven-resources-plugin 3.3.1
- maven-jar-plugin 3.3.0
- maven-source-plugin 3.3.0
- maven-javadoc-plugin 3.6.3
- spring-boot-maven-plugin 3.2.0

### 3. 默认配置

```xml
<properties>
    <!-- 编码设置 -->
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
    
    <!-- Java 版本 -->
    <maven.compiler.source>17</maven.compiler.source>
    <maven.compiler.target>17</maven.compiler.target>
    <java.version>17</java.version>
</properties>
```

## 使用方法 (Usage)

### 步骤 1: 安装父 POM

```bash
git clone https://github.com/silentbalanceyh/rachel-momo.git
cd rachel-momo
mvn clean install
```

### 步骤 2: 在项目中继承

在你的项目 `pom.xml` 中添加：

```xml
<parent>
    <groupId>io.github.silentbalanceyh</groupId>
    <artifactId>rachel-momo</artifactId>
    <version>1.0.0-SNAPSHOT</version>
</parent>
```

### 步骤 3: 使用管理的依赖

无需指定版本号：

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
        <!-- 版本由父 POM 管理，无需指定 -->
    </dependency>
    
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <!-- 版本由父 POM 管理，无需指定 -->
    </dependency>
</dependencies>
```

## 版本更新策略 (Version Update Strategy)

### 定期更新
建议每季度审查并更新一次依赖版本，确保使用稳定的最新版本。

### 安全更新
发现安全漏洞时应立即更新受影响的依赖版本。

### 兼容性测试
更新版本前应：
1. 检查更新日志 (CHANGELOG)
2. 运行所有测试
3. 在测试环境验证
4. 逐步推广到生产环境

### 版本锁定
对于关键依赖，可以在子项目中覆盖版本：

```xml
<dependencies>
    <dependency>
        <groupId>com.mysql</groupId>
        <artifactId>mysql-connector-j</artifactId>
        <version>8.0.32</version> <!-- 覆盖父 POM 的版本 -->
    </dependency>
</dependencies>
```

## 最佳实践 (Best Practices)

### 1. 依赖管理
- ✅ 优先使用父 POM 中已定义的依赖
- ✅ 新增通用依赖时，应添加到父 POM
- ✅ 项目特定依赖可以在子项目中定义
- ❌ 避免在子项目中随意覆盖版本

### 2. 版本号规范
- 使用语义化版本 (Semantic Versioning)
- 主版本号：不兼容的 API 变更
- 次版本号：向下兼容的功能新增
- 修订号：向下兼容的问题修正

### 3. BOM 导入
对于大型框架，优先使用 BOM (Bill of Materials)：

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-dependencies</artifactId>
    <version>${spring-boot.version}</version>
    <type>pom</type>
    <scope>import</scope>
</dependency>
```

### 4. 依赖范围
- `compile`: 默认范围，编译和运行时都需要
- `provided`: 编译时需要，运行时由容器提供 (如 Lombok)
- `runtime`: 运行时需要 (如数据库驱动)
- `test`: 仅测试时需要

## 常见问题 (FAQ)

### Q1: 如何查看项目实际使用的依赖版本？

```bash
mvn dependency:tree
```

### Q2: 如何查找依赖冲突？

```bash
mvn dependency:tree -Dverbose
```

### Q3: 如何排除传递依赖？

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
    <exclusions>
        <exclusion>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-tomcat</artifactId>
        </exclusion>
    </exclusions>
</dependency>
```

### Q4: 父 POM 更新后，子项目如何同步？

```bash
# 在子项目目录执行
mvn clean install -U
```

`-U` 参数会强制更新快照版本。

### Q5: 如何添加父 POM 中没有的依赖？

直接在子项目的 `pom.xml` 中添加，并指定版本：

```xml
<dependency>
    <groupId>com.example</groupId>
    <artifactId>custom-lib</artifactId>
    <version>1.0.0</version>
</dependency>
```

## 示例项目 (Example Project)

`examples/sample-application` 目录包含一个完整的示例应用，展示了：

- ✅ 如何继承父 POM
- ✅ 如何使用管理的依赖（无需指定版本）
- ✅ Spring Boot 应用配置
- ✅ 使用 Lombok 和 Hutool 工具库
- ✅ REST API 开发
- ✅ 应用打包和运行

运行示例：

```bash
cd examples/sample-application
mvn clean package
java -jar target/sample-application-1.0.0-SNAPSHOT.jar
```

访问：
- http://localhost:8080/api/hello
- http://localhost:8080/api/health

## 贡献指南 (Contributing)

欢迎提交问题和贡献代码！

### 添加新依赖
1. Fork 本项目
2. 在 `pom.xml` 的 `<dependencyManagement>` 中添加依赖
3. 更新 `USAGE.md` 文档
4. 提交 Pull Request

### 更新版本
1. 在 `pom.xml` 中更新版本号
2. 在测试环境验证
3. 更新文档说明兼容性变更
4. 提交 Pull Request

## 许可证 (License)

MIT License - 详见 [LICENSE](LICENSE) 文件

## 联系方式 (Contact)

- 作者: Silent Balance
- GitHub: [@silentbalanceyh](https://github.com/silentbalanceyh)
- 项目地址: https://github.com/silentbalanceyh/rachel-momo
