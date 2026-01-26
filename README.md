# Rachel Momo

[![Maven Central](https://img.shields.io/maven-central/v/io.zerows/rachel-momo.svg?label=Maven%20Central&style=for-the-badge&color=blue)](https://mvnrepository.com/artifact/io.zerows/rachel-momo)

> For [Rachel Momo](https://www.weibo.com/maoxiaotong0216)

![ZERO](docs/images/logo.jpeg)

## 0. 引导

- 教程：<https://www.yuque.com/jiezizhu/r2mo>
- 教程地图：<https://kumu.io/LangYu1017/zero>
- 示例：<https://gitee.com/zero-ws/zero-rachel-momo>

![Rachel-Momo](docs/images/rachel-momo.png)

---

## 介绍

### 基本介绍

Rachel Momo（统一版本管理，适用于所有项目）

- R2MO = R² Meta-Orchestrated / <https://gitee.com/silentbalanceyh/r2mo-rapid>
- ZERO = Zero Ecotope / <https://gitee.com/zero-ws/zero-ecotope>

纯软件版本管理模型，可直接通过 dependencyManagement 管理所有依赖库的核心版本实现版本的统一管理，直接通过 import
而避免繁琐的依赖库的处理。

> 新版为了方便管理，版本统一和 R2MO 一致！

### 标记说明

- 🦠 / 混合版本
- 🟡 / 存在第二主版本，如 Core 和 Client 客户端
- ✅️ / 可用的入口
- 🧩 / 继承用父类
- 🧫 / 实验性版本，一般包含最新依赖

## 使用

直接在您的 Maven 中追加如下：

```xml
<!-- 追加依赖的版本管理 -->
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>io.zerows</groupId>
            <artifactId>rachel-momo-stack</artifactId>
            <version>${momo.version}</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

追加之后，大部分的插件和依赖都可以直接使用而不需要设置版本信息，当然，您也可以通过设置版本号来覆盖默认的版本。

依赖除外，若您想要使用插件并且不带版本号，就只能选择继承：

```xml
<!-- 插件管理（可选） -->
<parent>
    <groupId>io.zerows</groupId>
    <artifactId>rachel-momo-0216</artifactId>
    <version>${momo.version}</version>
</parent>
```