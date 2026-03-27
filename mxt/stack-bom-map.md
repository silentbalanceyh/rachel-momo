# Stack / BOM Map

## Consumer Entry Quick Reference

| Entry | Usage | What it provides | When to use |
|---|---|---|---|
| `rachel-momo-stack` | `dependencyManagement import` | aggregates all domain BOMs | only need unified dependency versions |
| `rachel-momo-0216` | `<parent>` | inherits `stack` + root plugin management | need both dependency versions and plugin version inheritance |
| `rachel-momo-2025-stack` | `dependencyManagement import` | overrides Spring / Alibaba Cloud 2025 on top of the default stack | Spring 2025 pilot projects |

## Import Relationship Graph

```text
rachel-momo-0216
└── import rachel-momo-stack

rachel-momo-stack
├── import rachel-momo-aliyun
├── import rachel-momo-apache
├── import rachel-momo-apache-felix
├── import rachel-momo-aspectj
├── import rachel-momo-aws
├── import rachel-momo-cache
├── import rachel-momo-camunda
├── import rachel-momo-cluster
├── import rachel-momo-database
├── import rachel-momo-database-driver
├── import rachel-momo-dubbo
├── import rachel-momo-eclipse
├── import rachel-momo-elasticsearch
├── import rachel-momo-flyway
├── import rachel-momo-google
├── import rachel-momo-grpc
├── import rachel-momo-hibernate
├── import rachel-momo-httpcore5
├── import rachel-momo-jackson
├── import rachel-momo-jklingsporn
├── import rachel-momo-jooq
├── import rachel-momo-jsr
├── import rachel-momo-junit
├── import rachel-momo-jvmr
├── import rachel-momo-logging
├── import rachel-momo-mapstruct
├── import rachel-momo-micrometer
├── import rachel-momo-mq
├── import rachel-momo-mybatisplus
├── import rachel-momo-nacos
├── import rachel-momo-netty
├── import rachel-momo-osgi
├── import rachel-momo-poi
├── import rachel-momo-reactive
├── import rachel-momo-redxxx
├── import rachel-momo-scala
├── import rachel-momo-seata
├── import rachel-momo-secure
├── import rachel-momo-selenium
├── import rachel-momo-sentinel
├── import rachel-momo-swagger
├── import rachel-momo-template
├── import rachel-momo-tomcat
├── import rachel-momo-util
├── import rachel-momo-vendor
├── import rachel-momo-vertx
├── import rachel-momo-wxjava
├── import rachel-momo-spring
├── import rachel-momo-alibaba-cloud
└── import rachel-momo-jetty

rachel-momo-2025-stack
├── import rachel-momo-stack
├── import rachel-momo-2025-spring
└── import rachel-momo-2025-alibaba-cloud
```

## Key Semantics

### `stack` is the public entry, not the root POM itself

Many maintainers see the root `pom.xml` and assume consumers reference the root artifact directly. That is not the case:

- root `rachel-momo`: owns properties, plugins, and modules
- `rachel-momo-stack`: the public unified dependency entry

### `0216` is a parent wrapper layer

`rachel-momo-0216` maintains almost no domain versions on its own. Its only critical action is:

- import `rachel-momo-stack`

So its purpose is to convert the BOM import entry into an inheritable parent model.

### `2025-stack` is an overlay, not a fork

`rachel-momo-2025-stack` does not re-list all domain BOMs. It:

- inherits the full mapping from the default stack
- then locally overrides Spring / Alibaba Cloud

This means it is an incremental layer.

## Cloud-related BOM Relationships

### Stable line

```text
rachel-momo-spring
├── import spring-boot-dependencies:${spring-boot.version}
├── import spring-cloud-dependencies:${spring-cloud.version}
├── direct spring-cloud-starter-bootstrap:${spring-starter-bootstrap}
├── direct springdoc-openapi-starter-webmvc-ui:${spring-doc.version}
└── direct spring-boot-admin-starter-server:${spring-boot-admin.version}

rachel-momo-alibaba-cloud
└── import spring-cloud-alibaba-dependencies:${spring-cloud-alibaba.version}
```

### 2025 experimental line

```text
rachel-momo-2025-spring
├── import rachel-momo-spring
├── override spring-boot-dependencies:${spring-2025-boot.version}
├── override spring-cloud-dependencies:${spring-2025-cloud.version}
└── override spring-cloud-starter-bootstrap:${spring-2025-starter-bootstrap}

rachel-momo-2025-alibaba-cloud
├── import rachel-momo-alibaba-cloud
└── override spring-cloud-alibaba-dependencies:${spring-2025-cloud-alibaba.version}
```

## Decision Guide

### Minimal build change, only need unified dependency versions

Use: `rachel-momo-stack`

### Need to omit plugin versions too

Use: `rachel-momo-0216`

### Spring 2025 pilot, without forking all domains

Use: `rachel-momo-2025-stack`

## Maintenance Reminders

1. After adding a new domain BOM, it must be explicitly added to `rachel-momo-stack` for consumers to receive it.
2. New experimental overlay modules do not necessarily need to enter the default `stack`.
3. Whether `0216` needs to change depends on whether new parent inheritance semantics were added, not simply on whether a new domain module was added.
