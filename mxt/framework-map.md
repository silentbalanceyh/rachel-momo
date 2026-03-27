# Framework Map

## One-Sentence Structure

The structure of `rachel-momo` is: **the root POM provides version properties and plugin management, child modules split BOMs by technical domain, `stack` aggregates them into one import entry, `0216` provides the parent entry, and `2025-*` acts as the experimental overlay layer.**

## Layered Map

```text
rachel-momo (root)
├── properties / pluginManagement / publish config
├── domain BOMs
│   ├── foundational capabilities
│   │   ├── rachel-momo-jackson
│   │   ├── rachel-momo-logging
│   │   ├── rachel-momo-jvmr
│   │   ├── rachel-momo-jsr
│   │   ├── rachel-momo-util
│   │   └── rachel-momo-vendor
│   ├── data & persistence
│   │   ├── rachel-momo-database
│   │   ├── rachel-momo-database-driver
│   │   ├── rachel-momo-jooq
│   │   ├── rachel-momo-mybatisplus
│   │   ├── rachel-momo-hibernate
│   │   └── rachel-momo-flyway
│   ├── cloud & middleware
│   │   ├── rachel-momo-spring
│   │   ├── rachel-momo-alibaba-cloud
│   │   ├── rachel-momo-dubbo
│   │   ├── rachel-momo-nacos
│   │   ├── rachel-momo-sentinel
│   │   ├── rachel-momo-seata
│   │   ├── rachel-momo-mq
│   │   └── rachel-momo-cluster
│   ├── runtime / networking
│   │   ├── rachel-momo-vertx
│   │   ├── rachel-momo-netty
│   │   ├── rachel-momo-tomcat
│   │   ├── rachel-momo-jetty
│   │   ├── rachel-momo-httpcore5
│   │   └── rachel-momo-reactive
│   ├── security & protocols
│   │   ├── rachel-momo-secure
│   │   ├── rachel-momo-grpc
│   │   └── rachel-momo-swagger
│   ├── platform / ecosystem extensions
│   │   ├── rachel-momo-aws
│   │   ├── rachel-momo-aliyun
│   │   ├── rachel-momo-google
│   │   ├── rachel-momo-wxjava
│   │   ├── rachel-momo-camunda
│   │   ├── rachel-momo-selenium
│   │   ├── rachel-momo-micrometer
│   │   └── ...
│   └── experimental / compatibility
│       ├── rachel-momo-redxxx
│       ├── rachel-momo-scala
│       ├── rachel-momo-apache-felix
│       └── rachel-momo-osgi
├── aggregate
│   ├── rachel-momo-stack
│   └── rachel-momo-0216
└── experimental overlays
    ├── rachel-momo-2025-spring
    ├── rachel-momo-2025-alibaba-cloud
    └── rachel-momo-2025-stack
```

## Responsibilities of the Key Modules

### Root `rachel-momo`

Responsibilities:

- maintain all version properties
- maintain Maven `pluginManagement`
- maintain publishing-related plugin behavior such as flatten / gpg / source / javadoc
- act as the parent for all child BOMs

Do not treat it as a direct consumer-facing import entry. The real consumer entry points are `stack` and `0216`.

### `rachel-momo-stack`

Responsibilities:

- aggregate all technical-domain BOMs
- provide the unified `dependencyManagement` import entry
- serve consumers that only need aligned dependency versions

It does **not** directly provide plugin inheritance. That is a natural boundary of `dependencyManagement import`.

### `rachel-momo-0216`

Responsibilities:

- provide the parent inheritance entry
- import `rachel-momo-stack` internally
- let consumers inherit both dependency versions and the root plugin-management baseline

So this is a **parent wrapper around the import entry**, not a separate technology stack.

### `rachel-momo-spring`

Responsibilities:

- import `spring-boot-dependencies`
- import `spring-cloud-dependencies`
- add `spring-cloud-starter-bootstrap`, `springdoc`, and `spring-boot-admin`

This means it is not a pure pass-through BOM. It is a **combination of upstream BOMs plus a small set of directly managed components**.

### `rachel-momo-vertx`

Responsibilities:

- import `vertx-stack-depchain`
- keep `vertx-legacy.version` for a few artifacts that still require the old line
- manage `vertx-swagger-router` separately

This demonstrates an important pattern: **the main line and the legacy-compatible line can coexist, but the split must be explicit inside the module**.

### `rachel-momo-2025-*`

Responsibilities:

- import the old stable BOM first
- then override selected upstream BOMs with milestone / RC versions

This is an overlay layer, not a rewrite layer. The design preserves most existing domain versions and only shifts the Spring / Alibaba Cloud main chain.

## Module Naming Pattern

- `rachel-momo-<domain>`: BOM split by technical domain
- `rachel-momo-stack`: final unified import entry
- `rachel-momo-0216`: parent inheritance entry
- `rachel-momo-2025-<domain>`: experimental overlay modules

## Maintenance Implications

1. When adding a new technical domain, create an independent `rachel-momo-xxx` module first, then decide whether it belongs in `stack`.
2. If the change is only a main-chain upgrade, do not rewrite the `stack` structure directly. Prefer the overlay pattern first.
3. If the change affects plugin versions, update the root `pom.xml`, not `stack`.
4. If the change affects dependency versions only, prefer changing the relevant domain module or the root properties.
