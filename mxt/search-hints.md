# Search Hints

This repository is best searched by **POM role** and **version property name**, not by business-code vocabulary.

## Most Valuable Search Entry Points

### 1. Find the consumer entry points

Search for:

- `artifactId>rachel-momo-stack<`
- `artifactId>rachel-momo-0216<`
- `artifactId>rachel-momo-2025-stack<`

Use this to:

- confirm what a consumer should import or inherit
- confirm the aggregation boundary of `stack`

### 2. Find which module governs a technical domain

For Jackson:

- `jackson.version`
- `artifactId>rachel-momo-jackson<`

For databases:

- `database-`
- `artifactId>rachel-momo-database<`
- `artifactId>rachel-momo-database-driver<`

For Spring:

- `spring-boot.version`
- `spring-cloud.version`
- `artifactId>rachel-momo-spring<`

### 3. Find experimental overlay points

Search for:

- `2025-`
- `spring-2025-`
- `artifactId>rachel-momo-2025-spring<`
- `artifactId>rachel-momo-2025-alibaba-cloud<`

Use this to:

- quickly identify where experimental versions apply
- determine whether an override is implemented by `import` or by a direct declaration

## Recommended Search Paths

### Scenario A: I want to know where a dependency version comes from

1. Search the root `pom.xml` for the property name
2. Search the corresponding domain module to see whether it references that property
3. If needed, check whether `stack` imports that domain module

### Scenario B: I want to know which entry point a consumer project should use

1. Check the import / parent examples in `README.md`
2. Read `rachel-momo-stack/pom.xml`
3. Read `rachel-momo-0216/pom.xml`
4. For pilot upgrades, also read `rachel-momo-2025-stack/pom.xml`

### Scenario C: I want to determine where a change should land

- changing a version value: root `pom.xml`
- changing a library BOM or dependency set: `rachel-momo-<domain>/pom.xml`
- changing the unified exposure scope: `rachel-momo-stack/pom.xml`
- changing the parent inheritance entry: `rachel-momo-0216/pom.xml`


### Scenario D: I need a structured POM relationship map

1. Run `mxt/scripts/pom-map.py --repo /Users/lang/zero-cloud/app-zero/rachel-momo --format markdown` for a human-readable summary.
2. Run `mxt/scripts/pom-map.py --repo /Users/lang/zero-cloud/app-zero/rachel-momo --format json` if another agent or MCP pipeline needs structured data.
3. Use the output to confirm module count, key baselines, entry imports, managed-dependency counts, and property references before editing POM files.


### Scenario E: I am in a consumer repository and need to know whether Momo applies

1. Run `/Users/lang/zero-cloud/app-zero/rachel-momo/mxt/scripts/consumer-detect.py --repo <consumer-root> --format markdown`.
2. If the mode is `direct-momo-*`, read `consumer-agent-rules.md`, `mcp-agent-rules.md`, and `pom-analysis.md`.
3. If the mode is `zero-transitive-momo`, use Momo for dependency governance and Zero for runtime behavior.
4. If the mode is `r2mo-transitive-momo`, use Momo for dependency governance and R2MO for runtime behavior.

## Recommended Agent Tooling for Maven Analysis

When suitable, agents should use Maven-oriented analysis commands or equivalent MCP extraction patterns for:

- effective POM inspection
- dependency tree inspection
- convergence checking
- plugin management verification
- property diffing between stable and experimental lines

Practical targets to extract or run are:

- `help:effective-pom`
- `dependency:tree`
- `help:effective-settings` when repository behavior matters
- root `pom.xml` property diffs versus child BOM mappings
- direct comparison of `rachel-momo-stack` and `rachel-momo-2025-stack`
- `mxt/scripts/pom-map.py --format markdown|json` for repository-local POM relationship extraction
- `mxt/scripts/consumer-detect.py --repo <consumer-root> --format markdown|json` for consumer-side activation detection

If shell execution is expensive or unavailable, agents should approximate the same analysis by reading:

- the root `pom.xml`
- `rachel-momo-stack/pom.xml`
- `rachel-momo-0216/pom.xml`
- `rachel-momo-2025-stack/pom.xml`
- the relevant domain BOMs for the target ecosystem

## MCP-friendly Extraction Hints

For MCP pipelines that need fast structured extraction, prefer these anchors:

- **Entry model**: `rachel-momo-stack`, `rachel-momo-0216`, `rachel-momo-2025-stack`
- **Version authority**: root `pom.xml` `<properties>`
- **Aggregation scope**: `rachel-momo-stack/pom.xml`
- **Experimental override scope**: `rachel-momo-2025-stack/pom.xml`, `rachel-momo-2025-spring/pom.xml`, `rachel-momo-2025-alibaba-cloud/pom.xml`
- **Build inheritance scope**: `rachel-momo-0216/pom.xml` and root `pluginManagement`

## Key Keyword Reference

### Entry points

- `rachel-momo-stack`
- `rachel-momo-0216`
- `rachel-momo-2025-stack`
- `dependencyManagement`
- `<scope>import</scope>`
- `<parent>`

### Spring / Cloud

- `spring-boot.version`
- `spring-cloud.version`
- `spring-cloud-alibaba.version`
- `spring-2025-boot.version`
- `spring-2025-cloud.version`
- `spring-2025-cloud-alibaba.version`
- `spring-cloud-starter-bootstrap`

### Runtime

- `vertx.version`
- `vertx-legacy.version`
- `netty.version`
- `server-tomcat.version`
- `server-jetty.version`

### Data layer

- `database-hikari.version`
- `database-liquibase.version`
- `database-jooq.version`
- `mybatis-plus.version`
- `hibernate.version`

### Plugin management

- `pluginManagement`
- `maven.plugin.`
- `mavenex.plugin.`
- `flatten-maven-plugin`
- `central-publishing-maven-plugin`

## Search Anti-patterns

### Do not search business-code directories

This repository has almost no business source code. Searching `src/main/java`, `service`, or `controller` is generally meaningless.

### Do not confuse module names with version property names

For example:

- `rachel-momo-spring` is a module name
- `spring-boot.version` and `spring-cloud.version` are the actual version properties

### Do not stop at the root POM

The root POM tells you the version number, but it does not always tell you who consumes that version. You also need to check the corresponding domain module and `stack`.
