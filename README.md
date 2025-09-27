# rachel-momo

> For Rachel Momo

## 介绍

### 基本介绍

Rachel Momo（统一版本管理，适用于所有项目）

- R2MO = R² Meta-Orchestrated <https://gitee.com/silentbalanceyh/r2mo-rapid>
- ZERO = Zero Ecotope / <https://gitee.com/zero-ws/zero-ecotope>

纯软件版本管理模型，可直接通过 dependencyManagement 管理所有依赖库的核心版本实现版本的统一管理，直接通过 import
而避免繁琐的依赖库的处理。

### 标记

- 🦠 / 混合版本
- 🟡 / 存在第二主版本，如 Core 和 Client 客户端

## 子项目

### Rachel-Momo::Student

> id = rachel-momo.student

文档管理平台，对接 <https://gitee.com/zero-ws/r2mo-matrix>，文档以地图模式的文档为主

- 文档地图：<https://kumu.io/LangYu1017/r2mo#r2mo-dash>

### 最新版的使用

直接在您的 Maven 中追加如下：

```xml

<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>io.zerows</groupId>
            <artifactId>rachel-momo-stack</artifactId>
            <version>1.0.0</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

追加之后，大部分的插件和依赖都可以直接使用而不需要设置版本信息，当然，您也可以通过设置版本号来覆盖默认的版本。

### 参考链接

- Zero后端：<https://www.zerows.io/>
- Zero前端：<https://www.vertxui.cn/>
- Zero云端：<https://www.vertx-cloud.cn/>
- Zero工具箱：<https://www.vertxai.cn/>
- 白皮书（旧版）：<https://www.vertx-cloud.cn/document/doc-web/index-standalone.html>
- Zero教程：<https://lang-yu.gitbook.io/zero/>
- Vertx基础：<https://lang-yu.gitbook.io/vert.x/>
- CDA（AI笔记）：<https://lang-yu.gitbook.io/mi-ai/>