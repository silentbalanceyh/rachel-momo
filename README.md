# Rachel Momo

[![Maven Central](https://img.shields.io/maven-central/v/io.zerows/rachel-momo.svg?label=Maven%20Central&style=for-the-badge&color=blue)](https://mvnrepository.com/artifact/io.zerows/rachel-momo)

> For Rachel Momo

## 介绍

### 基本介绍

Rachel Momo（统一版本管理，适用于所有项目）

- R2MO = R² Meta-Orchestrated / <https://gitee.com/silentbalanceyh/r2mo-rapid>
- ZERO = Zero Ecotope / <https://gitee.com/zero-ws/zero-ecotope>

纯软件版本管理模型，可直接通过 dependencyManagement 管理所有依赖库的核心版本实现版本的统一管理，直接通过 import
而避免繁琐的依赖库的处理。

### 标记

- 🦠 / 混合版本
- 🟡 / 存在第二主版本，如 Core 和 Client 客户端

### 最新版的使用

直接在您的 Maven 中追加如下：

```xml

<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>io.zerows</groupId>
            <artifactId>rachel-momo-stack</artifactId>
            <version>${rachel-momo.version}</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

追加之后，大部分的插件和依赖都可以直接使用而不需要设置版本信息，当然，您也可以通过设置版本号来覆盖默认的版本。

---

## 特殊文档

### 核心文档

文档管理平台，对接 <https://gitee.com/zero-ws/r2mo-matrix>，文档以地图模式的文档为主

- 文档地图：<https://kumu.io/LangYu1017/r2mo#r2mo-dash>
- 辅导笔记用法：执行 `./content.sh` 运行进入控制台。

基本要求：node = 10.24.1 / gitbook = 2.3.2

### 控制台

```bash
# 一级菜单
请选择菜单
  1）📚 数理化生信
  2）🐧 Linux 命令集
  3）🧪 检查 Node.js 版本
  
输入编号并回车（q 退出）： 1

# ------------------------------------------
# 二级菜单
==> 内容菜单：rachel-momo.docs
  1) 📐  数学笔记
  2) 🔥  物理笔记
  3) 🧪  化学笔记
  4) 🧬  生物笔记
  5) 💻  信息计算笔记
  0) 🔙  返回上一级
  q) ❌  退出程序
```

选择 `1 ~ 5` 进入对应的笔记，并且配合端口号可打开对应的文档

| 端口号  | 说明     |
|------|--------|
| 4001 | 数学笔记   |
| 4002 | 物理笔记   |
| 4003 | 化学笔记   |
| 4004 | 生物笔记   |
| 4005 | 信息计算笔记 |

---

## 参考链接

- Zero后端：<https://www.zerows.io/>
- Zero前端：<https://www.vertxui.cn/>
- Zero云端：<https://www.vertx-cloud.cn/>
- Zero工具箱：<https://www.vertxai.cn/>
- 白皮书（旧版）：<https://www.vertx-cloud.cn/document/doc-web/index-standalone.html>
- Zero教程：<https://lang-yu.gitbook.io/zero/>
- Vertx基础：<https://lang-yu.gitbook.io/vert.x/>
- CDA（AI笔记）：<https://lang-yu.gitbook.io/mi-ai/>