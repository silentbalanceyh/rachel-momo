# MCP Agent Rules

This file defines the MCP-facing reading rules for AI agents that connect to the `mxt-momo` server. It is based on repository inspection plus a `code-review-graph` run against `/Users/lang/zero-cloud/app-zero/rachel-momo`.

## Activation Scope

Use these rules when an MCP task mentions any of the following:

- `mxt-momo`, `rachel-momo`, `momo`, `rachel-momo-stack`, `rachel-momo-0216`, or `rachel-momo-2025-stack`
- dependency version governance, BOM, parent POM, Maven `dependencyManagement`, Maven `pluginManagement`, publishing plugins, or framework version alignment
- cross-stack dependency questions involving Zero (`zero-0216`) or R2MO (`r2mo-0216`) where the answer may depend on shared upstream versions
- Spring / Alibaba Cloud / Vert.x baseline selection or upgrade compatibility in this workspace

Do not activate these rules for ordinary business-code questions unless the task explicitly asks where a dependency version, Maven parent, BOM import, or build plugin baseline comes from.


## Generalized Consumer Mode

Momo rules are not only for agents already inside this repository. They are also for agents working in downstream framework applications. In consumer mode, the agent should detect how the active project reaches Momo and then use Momo as the dependency-governance source.

Detection priority:

1. Direct parent/import of `rachel-momo-0216`, `rachel-momo-stack`, or `rachel-momo-2025-stack`.
2. Framework parent/import of `zero-0216` or `r2mo-0216`.
3. Explicit task wording about framework baseline, dependency alignment, parent POM, BOM import, or plugin management.

If the active project is classified as `zero-transitive-momo`, read Momo first for versions and then Zero for runtime semantics. If it is classified as `r2mo-transitive-momo`, read Momo first for versions and then R2MO for runtime semantics. If it is a direct Momo consumer, stay in Momo unless the task asks about runtime behavior owned by another framework.

## Repository Identity

`rachel-momo` is a Maven POM/BOM governance repository. It is not a business service, not a runtime framework, and not a starter application.

The repository has three public consumer entry concepts:

1. `rachel-momo-stack` — the main `dependencyManagement` import entry.
2. `rachel-momo-0216` — the parent POM entry; imports `rachel-momo-stack` and exposes root `pluginManagement` through parent inheritance.
3. `rachel-momo-2025-stack` — an experimental overlay entry; imports the stable `rachel-momo-stack` first and then overlays Spring / Alibaba Cloud 2025 BOMs.

The root `pom.xml` is the definition center, not the usual consumer entry. It owns module declaration, version properties, plugin management, publishing behavior, and child POM inheritance.

## Code-review-graph Findings

`code-review-graph` was introduced and run locally for this repository:

```bash
code-review-graph register /Users/lang/zero-cloud/app-zero/rachel-momo --alias mxt-momo
code-review-graph build --repo /Users/lang/zero-cloud/app-zero/rachel-momo
code-review-graph status --repo /Users/lang/zero-cloud/app-zero/rachel-momo
```

Observed status:

- Registered alias: `mxt-momo`
- Graph database: `/Users/lang/zero-cloud/app-zero/rachel-momo/.code-review-graph/graph.db`
- Parsed files: 2
- Nodes: 3
- Edges: 5
- Language detected: `bash`
- Parsed files are `mvn-build.sh` and `mvn-version.sh`

Important limitation: the current `code-review-graph` parser indexes code-language files, but it does not natively parse Maven `pom.xml` semantics. Because `rachel-momo` is almost entirely XML POM files, the graph is useful for tooling presence and shell-script review, but it is not sufficient as the primary source for repository understanding. MCP agents must use the graph as a supplemental signal and rely on Maven/POM-oriented extraction for the core logic.

When shell access is available, pair `code-review-graph` with the POM-specific analyzer:

```bash
mxt/scripts/pom-map.py --repo /Users/lang/zero-cloud/app-zero/rachel-momo --format markdown
mxt/scripts/pom-map.py --repo /Users/lang/zero-cloud/app-zero/rachel-momo --format json
```

The analyzer emits the Maven relationship map that `code-review-graph` cannot infer from XML: entry-point imports, managed-dependency counts, property references, and baseline snapshots.

For consumer repositories, run the consumer detector before deciding whether Momo is relevant:

```bash
/Users/lang/zero-cloud/app-zero/rachel-momo/mxt/scripts/consumer-detect.py --repo /path/to/consumer --format markdown
```

If it reports `zero-transitive-momo` or `r2mo-transitive-momo`, treat Momo as the dependency-governance source and the matching framework MCP as the runtime-behavior source.

## Required Reading Order

When answering a `mxt-momo` question, read in this order:

1. `mxt/README.md` for repository positioning and public entry model.
2. `mxt/framework-map.md` for layered module responsibility.
3. `mxt/stack-bom-map.md` for import relationships among `stack`, `0216`, and `2025-stack`.
4. `mxt/version-governance.md` for property authority and version-source rules.
5. `mxt/search-hints.md` for exact search anchors.
6. `mxt/consumer-agent-rules.md` when the active agent is working from a project that consumes Momo directly or through Zero/R2MO.
7. `mxt/pom-analysis.md` for Maven/POM-specific graph gaps, extraction rules, and analyzer-script output contract.
8. `mxt/upgrade-path.md` when the task mentions upgrade, compatibility, Spring 2025, Alibaba Cloud 2025, pilot migration, rollback, or baseline selection.
9. `mxt/agent-collaboration.md` when splitting analysis across agents or deciding who owns structure, version, or upgrade reasoning.
10. `mxt/evolution-rules.md` before modifying any `mxt/` knowledge-pack file.
11. The actual POM files after the matching documentation has identified the likely layer.

Do not start by recursively searching `src/main/java`, `controller`, `service`, `entity`, or business APIs. Those are wrong anchors for this repository.

## Core Repository Analysis

The current repository is a multi-module Maven `pom` project:

- Root artifact: `io.zerows:rachel-momo:${revision}`
- Packaging: `pom`
- Current repository version: `1.0.50`
- Java baseline: `17`
- Module count declared in root `pom.xml`: 55
- Version-like properties in root `pom.xml`: about 181
- Stable Spring baseline: Spring Boot `3.4.11`, Spring Cloud `2024.0.2`, Spring Cloud Alibaba `2023.0.3.4`
- Vert.x baseline: `5.0.8`
- Vert.x legacy compatibility baseline: `4.5.25`
- Experimental Spring 2025 baseline: Spring Boot `4.0.0-RC2`, Spring Cloud `2025.1.0-M4`, Spring Cloud Alibaba `2025.0.0.0`

The module layers are:

```text
root pom.xml
├── root properties and pluginManagement
├── domain BOM modules: rachel-momo-aliyun, -apache, -aws, -cache, -database, -jackson, -logging, ...
├── runtime/framework BOM modules: rachel-momo-spring, rachel-momo-alibaba-cloud, rachel-momo-vertx, -netty, -tomcat, -jetty, ...
├── aggregation entry: rachel-momo-stack
├── parent entry: rachel-momo-0216
└── experimental overlay: rachel-momo-2025-spring, rachel-momo-2025-alibaba-cloud, rachel-momo-2025-stack
```

The observed import model is:

```text
rachel-momo-0216
└── imports rachel-momo-stack

rachel-momo-stack
└── imports about 50 stable domain/runtime BOMs

rachel-momo-2025-stack
├── imports rachel-momo-stack
├── imports rachel-momo-2025-spring
└── imports rachel-momo-2025-alibaba-cloud
```

## Triggered Development Logic

Use the following triggers to locate the correct development logic.

### Dependency version question

Trigger words:

- version, dependency, library, artifact, upgrade, downgrade, drift, alignment
- property names ending in `.version`
- concrete ecosystems such as Jackson, Netty, Vert.x, Spring, Hibernate, JOOQ, MyBatis Plus, Flyway, Nacos, Sentinel, Seata, Dubbo, Micrometer

Reading path:

1. Search root `pom.xml` for the exact version property.
2. Read the matching domain BOM, usually `rachel-momo-<domain>/pom.xml`.
3. Confirm whether `rachel-momo-stack/pom.xml` imports that domain BOM.
4. For experimental Spring/Alibaba questions, compare stable and `2025-*` modules.

Change target:

- Version value changes usually belong in root `pom.xml` properties.
- Dependency membership changes belong in the matching domain BOM.
- Consumer exposure changes belong in `rachel-momo-stack/pom.xml` or `rachel-momo-2025-stack/pom.xml`.

### Consumer entry or parent/BOM question

Trigger words:

- parent, BOM, import, dependencyManagement, pluginManagement, effective POM, which POM should I use

Reading path:

1. `mxt/README.md`
2. `mxt/stack-bom-map.md`
3. `rachel-momo-stack/pom.xml`
4. `rachel-momo-0216/pom.xml`
5. Root `pom.xml` `build/pluginManagement` only if plugin inheritance is part of the question.

Decision rule:

- Use `rachel-momo-stack` if the consumer only needs unified dependency versions and already has its own parent.
- Use `rachel-momo-0216` if the consumer also wants root plugin-management inheritance.
- Use `rachel-momo-2025-stack` only for Spring/Alibaba 2025 pilot overlays.

### Upgrade or compatibility question

Trigger words:

- upgrade, migrate, compatibility, baseline, 2025, RC, milestone, pilot, rollback

Reading path:

1. `mxt/evolution-rules.md`
2. `mxt/upgrade-path.md`
3. Root `pom.xml` properties
4. Stable domain BOM(s)
5. Experimental overlay BOM(s)
6. `rachel-momo-stack/pom.xml` versus `rachel-momo-2025-stack/pom.xml`

Decision rule:

- Prefer the smallest override surface.
- Do not describe `2025-*` as the default production line.
- Treat `2025-stack` as `stable stack + focused override`, not as a replacement for all domain BOMs.

### Build / publishing / plugin question

Trigger words:

- plugin, build, deploy, publish, flatten, source, javadoc, gpg, compiler, surefire, central publishing, Maven release

Reading path:

1. Root `pom.xml` `build/pluginManagement` and publishing config.
2. `rachel-momo-0216/pom.xml` if inheritance is relevant.
3. `mvn-build.sh` and `mvn-version.sh` only when shell automation is relevant.
4. `code-review-graph` graph can help inspect shell-script function references, but not POM inheritance semantics.

Change target:

- Shared plugin version changes belong in root `pom.xml` properties or root `pluginManagement`.
- Parent exposure is through `rachel-momo-0216`.

### Cross-framework Zero/R2MO question

Trigger words:

- Zero, R2MO, `zero-0216`, `r2mo-0216`, `r2mo-spec`, framework dependency, shared contract, environment variable, cross-stack

Reading path:

1. `mxt/README.md` Cross-Stack Governance Relationship.
2. `mxt/version-governance.md` for version authority.
3. Matching domain BOM in `rachel-momo`.
4. Then inspect the consuming framework repository:
   - Zero: `/Users/lang/zero-cloud/app-zero/zero-ecotope`
   - R2MO: `/Users/lang/zero-cloud/app-zero/r2mo-rapid`
   - Shared spec: `/Users/lang/zero-cloud/app-zero/r2mo-rapid/r2mo-spec`

Decision rule:

- Momo owns version alignment and BOM exposure.
- Runtime behavior belongs to Zero or R2MO framework code.
- Shared semantic contracts belong to `r2mo-spec` and may affect both framework lines.

## Framework Handoff Rules

Momo is often the first repository touched by framework-facing questions, but it is rarely the final owner of runtime behavior. Use these handoff rules:

| Requirement wording | Momo responsibility | Next repository when behavior is needed |
|---|---|---|
| "which version", "align dependency", "upgrade BOM" | root property + domain BOM + stack exposure | none unless compatibility must be validated |
| "Zero uses / fails / runtime behavior" | confirm Momo version exposure only | `/Users/lang/zero-cloud/app-zero/zero-ecotope` |
| "R2MO Spring behavior" | confirm Momo version exposure only | `/Users/lang/zero-cloud/app-zero/r2mo-rapid` |
| "shared API/model/marker/metadata contract" | confirm dependency alignment only | `/Users/lang/zero-cloud/app-zero/r2mo-rapid/r2mo-spec` |
| "deployment / ops tooling" | dependency governance if Maven-related | `/Users/lang/zero-cloud/app-zero/rachel-momo` first, then ops scripts/docs as needed |

When handing off, include the Momo exposure path you found, for example:

```text
root spring-boot.version -> rachel-momo-spring -> rachel-momo-stack -> zero-0216/r2mo-0216 consumer
```

This lets the next framework agent understand which baseline is active before it inspects runtime code.

## MCP Extraction Patterns

For MCP-backed analysis, prefer explicit file reads and focused searches:

```text
read mxt/README.md
read mxt/search-hints.md
search root pom.xml for <property.name>
read rachel-momo-<domain>/pom.xml
read rachel-momo-stack/pom.xml
read rachel-momo-0216/pom.xml
read rachel-momo-2025-stack/pom.xml when experimental overlays are relevant
```

Useful grep anchors:

```text
artifactId>rachel-momo-stack<
artifactId>rachel-momo-0216<
artifactId>rachel-momo-2025-stack<
<scope>import</scope>
<dependencyManagement>
<pluginManagement>
.version>
spring-2025-
vertx-legacy.version
```

Recommended shell extraction when local execution is available:

```bash
# confirm graph availability and current coverage
code-review-graph status --repo /Users/lang/zero-cloud/app-zero/rachel-momo

# find property owners
rg '<[^>]+\.version>' /Users/lang/zero-cloud/app-zero/rachel-momo/pom.xml

# find domain BOM references
rg 'artifactId>.*target-artifact|target-property' /Users/lang/zero-cloud/app-zero/rachel-momo/rachel-momo-*/pom.xml

# compare stable and experimental overlays
rg 'spring-boot-dependencies|spring-cloud-dependencies|spring-cloud-alibaba-dependencies' \
  /Users/lang/zero-cloud/app-zero/rachel-momo/rachel-momo-spring/pom.xml \
  /Users/lang/zero-cloud/app-zero/rachel-momo/rachel-momo-2025-spring/pom.xml \
  /Users/lang/zero-cloud/app-zero/rachel-momo/rachel-momo-alibaba-cloud/pom.xml \
  /Users/lang/zero-cloud/app-zero/rachel-momo/rachel-momo-2025-alibaba-cloud/pom.xml
```

## Required Analysis Output Contract

For non-trivial MCP answers, use this compact output structure before recommendations:

```text
Layer inspected: root properties | domain BOM | stack | parent | overlay | pluginManagement
Consumer entry affected: stack | 0216 | 2025-stack | none
Version authority: root property name or upstream BOM name
Exposure path: root property -> domain BOM -> stack/parent/overlay
Runtime follow-up: Zero / R2MO / r2mo-spec required? yes/no
Graph note: code-review-graph useful? yes/no and why
```

If the task crosses into runtime behavior, state clearly that Momo only governs dependency/version exposure and that Zero/R2MO framework repositories must be inspected for execution semantics.

## Editing Guardrails

- Do not edit generated `.flattened-pom.xml` files as source of truth.
- Do not edit `pom.xml.versionsBackup` as source of truth.
- Do not commit `.code-review-graph/graph.db`; it contains local graph metadata and is ignored by its own inner `.gitignore`.
- Do not change root property, domain BOM, and stack aggregation in one step unless the requirement explicitly spans all three layers.
- If a new domain BOM is added, update root `<modules>`, the new domain `pom.xml`, `rachel-momo-stack/pom.xml` if consumers need it, and mxt docs according to `mxt/evolution-rules.md`.
- Preserve inline comments in POM files; many comments encode compatibility rationale and upstream source links.
- Treat root `revision` and consumer entry versioning as release-governance changes, not incidental cleanup.

## Answering Rules for AI Agents

When explaining findings from `mxt-momo`, always state:

1. Which layer was inspected: root properties, domain BOM, stack aggregation, parent inheritance, or experimental overlay.
2. Whether the answer affects consumers through `stack`, `0216`, or `2025-stack`.
3. Whether runtime behavior must be checked in Zero/R2MO framework code instead of Momo.
4. Whether `code-review-graph` was useful for the question or whether Maven/POM inspection was required due to XML coverage limitations.

This prevents the common mistake of treating Momo as application source code and ensures framework-facing requirements can be traced through the correct version-governance layer.
