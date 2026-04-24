# Rachel Momo / mxt

This directory is an **AI-first knowledge pack** for the `rachel-momo` repository. It is written to help AI agents and maintainers understand the repository quickly and accurately. Its core purpose is to explain that `rachel-momo` is **not** a business framework and **not** a starter bundle. It is a **Maven BOM / parent-driven version governance repository**.

## Repository Positioning

Based on `/Users/lang/zero-cloud/app-zero/rachel-momo/README.md` and the root `pom.xml`, the repository works as follows:

- `rachel-momo-stack` is the main `dependencyManagement import` entry point.
- `rachel-momo-0216` is the parent POM entry point used through `<parent>` inheritance.
- The root `pom.xml` maintains the unified version properties, such as `spring-boot.version`, `vertx.version`, `jackson.version`, `database-*`, and `maven.plugin.*`.
- `rachel-momo-2025-*` is an experimental overlay layer. It does not replace the whole baseline. It imports the stable stack first and then overrides the Spring / Alibaba Cloud chain.

## Cross-Stack Governance Relationship

Within this workspace, Momo should be understood as the **upper version-governance layer** above the runtime-specific framework lines. In practical terms:

- Zero is a Vert.x-first runtime line.
- R2MO is a Spring-first runtime line.
- Momo sits above those runtime lines as the shared **dependency and BOM governance layer**.

This means Momo does not own runtime semantics directly. It owns version alignment, upstream BOM selection, upgrade coordination, and framework-level operating constraints across the framework families that consume it.

Environment variables should also be treated as part of that cross-stack operating contract. In multi-tenant, multi-language, multi-style, and multi-application management systems, environment variables are not just deployment details; they are part of the shared framework contract that determines how both runtime lines are configured, aligned, and operated.

A second important boundary is `r2mo-spec`:

- `r2mo-spec` is the **cross-stack shared standard layer**.
- Changes in `r2mo-spec` should be treated as **cross-stack semantic changes**, not as isolated runtime-local edits.
- If a change affects `r2mo-spec`, agents should evaluate compatibility impact across both R2MO and Zero consumers, even when the immediate code change appears local.

## Usage Patterns

### 1. Use it only for dependency version alignment

Use `rachel-momo-stack`:

```xml
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

Use this when:

- you only want unified dependency versions
- you do not need plugin inheritance
- your project already has its own parent

### 2. Use it for dependency versions and plugin management inheritance

Use `rachel-momo-0216`:

```xml
<parent>
    <groupId>io.zerows</groupId>
    <artifactId>rachel-momo-0216</artifactId>
    <version>${momo.version}</version>
</parent>
```

Use this when:

- you want to omit Maven plugin versions
- you want to inherit the root `pom.xml` `pluginManagement`
- you accept the repository-wide plugin baseline for publish, compiler, surefire, deploy, and related build plugins

## BOM Import vs Parent Inheritance Decision Model

| Decision Factor | Use `rachel-momo-stack` (import) | Use `rachel-momo-0216` (parent) |
|---|---|---|
| Existing parent POM | Already have one | Willing to change or starting fresh |
| Plugin version control | You manage your own plugins | You want inherited plugin versions |
| Build reproducibility | Depends on your build setup | Higher due to inherited `pluginManagement` |
| CI/CD compatibility | Works with any parent | Requires accepting `rachel-momo-0216` as parent |
| Upgrade flexibility | Easier to switch BOM imports | Requires parent version bump |
| Recommended for | Microservices with diverse parents | Standardized org-wide projects |

## Document Navigation

- [framework-map.md](./framework-map.md) — layered module map and responsibility boundaries
- [version-governance.md](./version-governance.md) — version sources, override rules, governance model, and drift hotspots
- [aspectj-governance.md](./aspectj-governance.md) — AspectJ dependency/plugin governance and boundary vs runtime AOP implementation
- [upgrade-path.md](./upgrade-path.md) — upgrade path, diff checklist, and rollback guidance
- [stack-bom-map.md](./stack-bom-map.md) — import relationships across stack, parent, and cloud BOMs
- [agent-collaboration.md](./agent-collaboration.md) — how agents should collaborate safely in this repository
- [mcp-agent-rules.md](./mcp-agent-rules.md) — MCP-specific trigger, reading, and repository-analysis rules for AI agents
- [consumer-agent-rules.md](./consumer-agent-rules.md) — generalized rules and portable downstream snippet for AI agents working in projects that depend on Momo directly or through Zero/R2MO
- [../../zero-ecotope/mxt/biological-network-overview.md](../../zero-ecotope/mxt/biological-network-overview.md) — cross-repository MD-driven routing across governance, semantics, runtime, and delivery
- [../../zero-ecotope/mxt/biological-network-pairwise-matrix.md](../../zero-ecotope/mxt/biological-network-pairwise-matrix.md) — pairwise processing templates across Momo, Spec, R2MO, and Zero
- [pom-analysis.md](./pom-analysis.md) — Maven/POM relationship extraction rules and analyzer-script output contract
- [search-hints.md](./search-hints.md) — fast search hints and Maven analysis tooling for agents
- [evolution-rules.md](./evolution-rules.md) — rules for evolving, extending, and validating this mxt knowledge pack over time

## Currently Confirmed Baselines

Based on the current root `pom.xml`:

- Repository version: `1.0.50`
- Java: `17`
- Spring Boot: `3.4.11`
- Spring Cloud: `2024.0.2`
- Spring Cloud Alibaba: `2023.0.3.4`
- Vert.x: `5.0.8`
- Vert.x legacy: `4.5.25`
- Spring 2025 Boot: `4.0.0-RC2`
- Spring 2025 Cloud: `2025.1.0-M4`
- Spring 2025 Cloud Alibaba: `2025.0.0.0`

## Suggested Reading Order

If you are:

- maintaining versions, start with `version-governance.md`
- deciding which POM to import, start with `stack-bom-map.md` and the decision model above
- connecting through MCP or building agent routing, start with `mcp-agent-rules.md`
- building cross-repository agent routing across Momo/Spec/R2MO/Zero, start with `../../zero-ecotope/mxt/biological-network-overview.md`
- working from a project that depends on Momo/Zero/R2MO, run `mxt/scripts/consumer-detect.py` and read `consumer-agent-rules.md`
- analyzing Maven XML relationships, run `mxt/scripts/pom-map.py` and read `pom-analysis.md`
- trying to understand module boundaries, start with `framework-map.md`
- evaluating an upgrade, start with `upgrade-path.md`

Cross-repository rule:

- Momo should usually pair with one runtime or semantic repository
- do not require all external repositories unless the current pair still leaves governance or runtime proof unresolved

## Quick MCP Extraction Hints

For AI agents using this knowledge pack via MCP:

- **Entry points**: grep for `rachel-momo-stack`, `rachel-momo-0216`, `rachel-momo-2025-stack`
- **Version properties**: grep root `pom.xml` for `.version=` patterns
- **BOM imports**: look for `scope>import</scope>` in `rachel-momo-stack/pom.xml`
- **Overlay detection**: search for `2025-` property prefixes to identify experimental versions
- **Structured POM map**: run `mxt/scripts/pom-map.py --repo /Users/lang/zero-cloud/app-zero/rachel-momo --format markdown`
- **Consumer detection**: run `mxt/scripts/consumer-detect.py --repo /path/to/consumer --format markdown`
