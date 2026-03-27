# Version Governance

## Governance Core

Version governance in this repository does **not** mean that each module chooses its own versions. Instead, the repository works through three coordinated layers:

1. **the root `pom.xml` `<properties>`** as the single source of version truth
2. **domain BOM modules** that map those properties to concrete dependencies or upstream BOMs
3. **aggregate entries (`stack` / `0216`)** that expose the result to consumers

In other words:

- when you change a version, you usually change the root property first
- when you decide which libraries are governed by that version, you do it in the `rachel-momo-*` child BOMs
- when a consumer imports or inherits the model, it normally uses `stack` or `0216`

## Version Source Patterns

### Pattern A: Direct third-party version properties

Examples:

- `jackson.version=2.21.1`
- `vertx.version=5.0.8`
- `spring-boot.version=3.4.11`

Use this when a single library or a clear library family is being governed.

### Pattern B: Upstream BOM version properties

Examples:

- `spring-cloud.version=2024.0.2`
- `spring-cloud-alibaba.version=2023.0.3.4`
- `spring-2025-cloud.version=2025.1.0-M4`

Use this when the ecosystem is imported through an upstream BOM.

### Pattern C: Dual main-line / compatibility versions

Examples:

- `vertx.version=5.0.8`
- `vertx-legacy.version=4.5.25`

This means the repository explicitly acknowledges that:

- the new main line has already been adopted
- some artifacts still require the old line
- compatibility versions must be named explicitly rather than being mixed in silently

### Pattern D: Experimental override versions

Examples:

- `spring-2025-boot.version=4.0.0-RC2`
- `spring-2025-cloud.version=2025.1.0-M4`
- `spring-2025-cloud-alibaba.version=2025.0.0.0`

These versions only take effect inside `rachel-momo-2025-*`. They do **not** define the default production baseline.

## Semantic Boundary of `import` and `parent`

### `dependencyManagement import`

What it gives you:

- unified dependency versions
- upstream BOM propagation

What it does **not** give you:

- `pluginManagement`
- default build-plugin versions
- the root POM build behavior

That is why the repository README distinguishes the two entry styles:

- use `rachel-momo-stack` for dependency version alignment
- use `rachel-momo-0216` as `parent` when you also want plugin version inheritance

### `parent`

What it gives you:

- unified dependency versions, because `0216` imports `stack`
- plugin version management
- root build constraints

So the value of `0216` is **not** that it adds many extra dependencies. Its real value is that it wraps the import entry as an inheritable parent model.

## 0216 Baseline vs 2025 Overlay Risk Model

### `rachel-momo-0216`

Main risk profile:

- low dependency surprise because it stays on the stable stack
- medium build coupling because consumers inherit root plugin management
- higher migration cost if a project already depends on another corporate parent

Use `0216` when the project values a standardized build more than parent flexibility.

### `rachel-momo-2025-stack`

Main risk profile:

- higher dependency churn because Spring Boot / Cloud / Alibaba Cloud move together
- possible convergence pressure against older Spring ecosystem modules
- no dedicated 2025 parent wrapper, so plugin inheritance and dependency upgrade are no longer a single-step decision

Use `2025-stack` for controlled pilot upgrades, not for silent baseline replacement.

## Currently Confirmed Governance Baselines

### Platform level

- `revision=1.0.50`
- `java.version=17`

### Stable Spring baseline

- `spring-boot.version=3.4.11`
- `spring-cloud.version=2024.0.2`
- `spring-starter-bootstrap=4.3.0`
- `spring-doc.version=2.8.15`
- `spring-cloud-alibaba.version=2023.0.3.4`

### Spring 2025 experimental baseline

- `spring-2025-boot.version=4.0.0-RC2`
- `spring-2025-cloud.version=2025.1.0-M4`
- `spring-2025-starter-bootstrap=5.0.0-M4`
- `spring-2025-cloud-alibaba.version=2025.0.0.0`

### Runtime / networking

- `vertx.version=5.0.8`
- `vertx-legacy.version=4.5.25`
- `netty.version=4.2.10.Final`
- `server-tomcat.version=11.0.18`
- `server-jetty.version=12.0.29`

### Common public dependencies

- `jackson.version=2.21.1`
- `hibernate.version=7.2.1.Final`
- `mybatis-plus.version=3.5.16`
- `database-jooq.version=3.20.11`
- `database-liquibase.version=5.0.1`
- `junit.version=6.1.0-M1`

## Version Drift Hotspots

These areas deserve extra attention because they are more likely to drift or produce convergence warnings:

### Spring chain

- Spring Boot / Spring Cloud / Spring Cloud Alibaba must remain mutually compatible
- `spring-cloud-starter-bootstrap` is separately pinned and can drift from the BOM train
- `springdoc` and `spring-boot-admin` may lag behind major Spring upgrades

### Vert.x / Netty chain

- `vertx.version` and `vertx-legacy.version` intentionally coexist
- Netty consumers may pull versions both through Vert.x and directly through `netty.version`
- native transport and resolver artifacts are especially sensitive to drift

### Jakarta migration boundary

- `jakarta.servlet-api.version`
- validation, persistence, JAXB, activation, and EL APIs
- libraries that still expect older javax-era coordinates

### Data stack

- Hibernate, MyBatis Plus, jOOQ, Liquibase, and database drivers can easily diverge in capability assumptions
- upgrading one data tool may force transitive upgrades in others

## Dependency Convergence Concerns

Agents should watch for these Maven-level concerns during upgrades:

- the same group/artifact appearing through both an upstream BOM and a direct version pin
- legacy lines still referenced by selected modules, especially Vert.x and HTTP clients
- test-scope libraries introducing newer platform APIs than the runtime path
- plugin version convergence when a consumer uses `stack` import but keeps independent plugin versions

## Cross-Stack Governance Boundary

At the workspace level, Momo should be treated as the **shared version-governance layer above multiple framework lines**.

- R2MO is the Spring-oriented runtime/application line.
- Zero is the Vert.x-oriented runtime/application line.
- Momo governs version selection, BOM imports, and upgrade coordination for both kinds of downstream stacks.

This is why a Momo change can have cross-stack consequences even if only one runtime family is being upgraded at the moment.

Environment variables belong to this operating boundary as well. For cross-stack governance, agents should treat environment-variable conventions as part of the framework operating contract, especially in multi-tenant, multi-language, multi-style, and multi-application management systems where configuration shape directly affects runtime compatibility and shared operational semantics.

## `r2mo-spec` as Shared Standard Layer

`r2mo-spec` should be treated as a **cross-stack shared standard layer**:

- it defines shared contracts, enumerations, and semantic conventions
- it is not owned by just one runtime family
- a spec change is a **cross-stack semantic change**, not merely a dependency update

For agents, this means any upgrade that touches versions affecting `r2mo-spec` consumers should trigger cross-stack compatibility review, especially around API contracts, enums, resource semantics, and serialization assumptions.

## Governance Rules

### 1. Decide whether the change is a property change or a mapping change first

- If you are only upgrading one library version, prefer changing the root property.
- If you are changing import relationships, change the child BOM.
- If you are changing consumer-visible exposure, change `stack` or `0216`.

### 2. Do not turn the overlay into the default baseline accidentally

`rachel-momo-2025-stack` works like this:

1. import `rachel-momo-stack`
2. import `rachel-momo-2025-spring`
3. import `rachel-momo-2025-alibaba-cloud`

That means it is an overlay on top of the stable baseline. If you inject 2025 versions directly into the default `spring` module, you break this governance boundary.

### 3. Do not blur the responsibilities of parent POM and BOM

- `stack` exists to be imported
- `0216` exists to be inherited as `parent`

If a change only concerns build plugins, it should not land in `stack`.

### 4. Version comments are governance assets too

The root `pom.xml` preserves many links and compatibility notes next to its version properties, including Spring Boot / Cloud compatibility notes and Jakarta Servlet fallback notes. Those comments explain **why** a version was chosen, so they should be preserved whenever possible.
