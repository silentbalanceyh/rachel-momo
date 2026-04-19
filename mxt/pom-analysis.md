# POM Analysis Rules

This document complements `mcp-agent-rules.md` with Maven/POM-specific analysis guidance. It exists because `rachel-momo` stores its real development logic in XML POM relationships rather than in Java source code.

## Why This File Exists

`code-review-graph` is useful for code-language repositories, but the current `rachel-momo` graph only sees the two shell scripts:

- `mvn-build.sh`
- `mvn-version.sh`

The important repository logic lives in:

- root `pom.xml` properties and plugin management
- child domain BOM `pom.xml` files
- `rachel-momo-stack/pom.xml` aggregation imports
- `rachel-momo-0216/pom.xml` parent entry imports
- `rachel-momo-2025-*/pom.xml` experimental overlay imports

Therefore MCP agents must perform POM analysis explicitly.

## Analyzer Script

Use the local helper script when shell access is available:

```bash
mxt/scripts/pom-map.py --repo /Users/lang/zero-cloud/app-zero/rachel-momo --format markdown
mxt/scripts/pom-map.py --repo /Users/lang/zero-cloud/app-zero/rachel-momo --format json
```

The script extracts:

- root module count
- root property count and version-property count
- key baselines
- entry-point imports
- per-module import count
- per-module managed-dependency count
- per-module property references

It intentionally uses Python `xml.etree.ElementTree` and Maven XML semantics instead of `code-review-graph`.

For consumer projects outside this repository, pair it with:

```bash
mxt/scripts/consumer-detect.py --repo /path/to/consumer --format markdown
```

That detector decides whether the consumer reaches Momo directly, through Zero, or through R2MO before the agent applies this POM map.

## Current POM Map Snapshot

Based on the current repository:

| Metric | Value |
|---|---:|
| Root artifact | `rachel-momo` |
| Module count | 55 |
| Root property count | 225 |
| Version-like property count | 181 |
| `rachel-momo-stack` imports | 50 |
| `rachel-momo-0216` imports | 1 |
| `rachel-momo-2025-stack` imports | 3 |

Key baselines:

| Property | Value |
|---|---|
| `revision` | `1.0.50` |
| `java.version` | `17` |
| `spring-boot.version` | `3.4.11` |
| `spring-cloud.version` | `2024.0.2` |
| `spring-cloud-alibaba.version` | `2023.0.3.4` |
| `vertx.version` | `5.0.8` |
| `vertx-legacy.version` | `4.5.25` |
| `spring-2025-boot.version` | `4.0.0-RC2` |
| `spring-2025-cloud.version` | `2025.1.0-M4` |
| `spring-2025-cloud-alibaba.version` | `2025.0.0.0` |

## Analysis Decision Tree

### 1. Where is a version defined?

Use this path:

1. Search the root `pom.xml` `<properties>` section.
2. If the property exists, treat root `pom.xml` as version authority.
3. Search `rachel-momo-*/pom.xml` for `${property.name}` to identify consumers.
4. Check whether the consuming domain BOM is imported by `rachel-momo-stack` or an overlay stack.

Do not stop after finding a property. A property is only useful to consumers if a child BOM maps it to dependencies and the child BOM is exposed by an entry stack.

### 2. Where is a dependency governed?

Use this path:

1. Search `rachel-momo-*/pom.xml` for the dependency `groupId` or `artifactId`.
2. Identify whether it is a direct managed dependency or part of an upstream imported BOM.
3. Read the matching root property if the version is property-driven.
4. Check import exposure through `rachel-momo-stack`, `rachel-momo-0216`, or `rachel-momo-2025-stack`.

The direct dependency count does not imply runtime use. It means Momo governs version selection.

### 3. Which consumer entry should be changed?

Use this path:

- If only a version number changes: root `pom.xml` property.
- If the dependency set inside a technical domain changes: `rachel-momo-<domain>/pom.xml`.
- If consumers need access to a domain BOM: `rachel-momo-stack/pom.xml` or the relevant overlay stack.
- If plugin inheritance changes: root `pluginManagement`, exposed through `rachel-momo-0216`.

Never modify all layers just because one layer changed. Only touch the layers required by the consumer effect.

### 4. Is this stable or experimental?

Use this path:

- Stable Spring / Alibaba baseline: `rachel-momo-spring`, `rachel-momo-alibaba-cloud`, `rachel-momo-stack`.
- Experimental Spring / Alibaba 2025 baseline: `rachel-momo-2025-spring`, `rachel-momo-2025-alibaba-cloud`, `rachel-momo-2025-stack`.
- `rachel-momo-2025-stack` imports stable `rachel-momo-stack` first, then overlays Spring and Alibaba Cloud.

Do not describe `2025-*` as a repository-wide replacement. It is a focused overlay for pilot consumers.

## High-Signal Modules

When an MCP agent must prioritize inspection, start with these modules:

| Module | Why it matters |
|---|---|
| root `pom.xml` | Defines properties, modules, plugin management, publishing behavior |
| `rachel-momo-stack` | Main dependencyManagement import entry for consumers |
| `rachel-momo-0216` | Parent POM entry for dependency and plugin inheritance |
| `rachel-momo-2025-stack` | Experimental overlay entry |
| `rachel-momo-spring` | Stable Spring Boot / Spring Cloud baseline |
| `rachel-momo-2025-spring` | Experimental Spring 2025 baseline |
| `rachel-momo-alibaba-cloud` | Stable Alibaba Cloud baseline |
| `rachel-momo-2025-alibaba-cloud` | Experimental Alibaba Cloud 2025 baseline |
| `rachel-momo-vertx` | Vert.x baseline used by Zero-facing consumers |
| `rachel-momo-jackson` | Large foundational serialization BOM |
| `rachel-momo-jsr` | Jakarta / JSR compatibility governance |
| `rachel-momo-netty` | Runtime networking baseline, relevant to Vert.x and server modules |

## Common Failure Modes

### Failure: Root property exists, but consumers do not receive it

Cause: no domain BOM maps that property to a dependency, or the domain BOM is not imported by the active stack.

Check:

```bash
rg 'property.name' pom.xml rachel-momo-*/pom.xml
rg 'artifactId>rachel-momo-domain<' rachel-momo-stack/pom.xml rachel-momo-2025-stack/pom.xml
```

### Failure: Experimental versions leak into stable consumers

Cause: editing stable `rachel-momo-spring` or root baseline property when the change should have gone to `spring-2025-*` properties and `2025-*` modules.

Check:

```bash
rg 'spring-2025-|2025-stack|2025-spring|2025-alibaba' pom.xml rachel-momo-2025-*/pom.xml
```

### Failure: Parent inheritance expectations are confused with BOM import

Cause: treating `dependencyManagement import` as if it also carries `pluginManagement`.

Rule:

- `rachel-momo-stack` gives dependency versions.
- `rachel-momo-0216` gives parent inheritance and plugin-management exposure.

### Failure: Generated files are treated as source

Cause: editing `.flattened-pom.xml` or `pom.xml.versionsBackup`.

Rule:

Only source `pom.xml` files should be modified for governance changes.

## Output Contract for MCP Agents

When returning a Momo analysis, include this structure:

```text
Layer inspected: root properties | domain BOM | stack | parent | overlay | pluginManagement
Consumer entry affected: stack | 0216 | 2025-stack | none
Version authority: root property name or upstream BOM name
Exposure path: root property -> domain BOM -> stack/parent/overlay
Runtime follow-up: Zero / R2MO / r2mo-spec required? yes/no
Graph note: code-review-graph useful? yes/no and why
```

This format lets downstream agents decide whether they need to continue into `zero-ecotope`, `r2mo-rapid`, or `r2mo-spec`.
