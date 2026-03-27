# Upgrade Path

## Target Scenario

This repository currently maintains two Spring-related baselines:

- stable baseline: `rachel-momo-spring` + `rachel-momo-alibaba-cloud`
- experimental baseline: `rachel-momo-2025-spring` + `rachel-momo-2025-alibaba-cloud`

Do not interpret this as a single repository-wide switch. The real model is: **consumers can choose a different stack import to switch the main version chain.**

## Path Overview

### Path A: stay on the default stable stack

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

Characteristics:

- Spring Boot 3.4.11
- Spring Cloud 2024.0.2
- Alibaba Cloud 2023.0.3.4
- lowest risk

### Path B: move a pilot project to the 2025 stack

```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>io.zerows</groupId>
            <artifactId>rachel-momo-2025-stack</artifactId>
            <version>${momo.version}</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

Characteristics:

- inherits the full default stack first
- then overrides the Spring / Alibaba Cloud main chain
- works well for pilot evaluation without disturbing non-Spring domains

## Why the 2025 stack uses “import stable first, then override”

From `rachel-momo-2025-stack/pom.xml`, the order is clear:

1. import `rachel-momo-stack`
2. import `rachel-momo-2025-spring`
3. import `rachel-momo-2025-alibaba-cloud`

This gives two benefits:

- most technical-domain BOMs do not need to be redefined
- the experimental upgrade stays focused on the Spring main chain, which limits the blast radius

That is the recommended upgrade model: **override the smallest possible surface while preserving the largest stable baseline.**

## Recommended Upgrade Steps

### Step 1: confirm whether the consumer currently uses `import` or `parent`

If the project currently uses:

- `dependencyManagement import` with `rachel-momo-stack`, replace it with `rachel-momo-2025-stack`
- `<parent>` with `rachel-momo-0216`, first confirm whether parent inheritance is still required, because this repository does **not** currently provide a dedicated `2025 parent` entry

This means:

- **there is already a ready-made entry for dependency-version upgrades**
- **there is no separate 2025 parent wrapper for plugin inheritance**

If the consumer strongly depends on the parent model, evaluate whether `0216 + local overrides` is still the right approach instead of assuming that `rachel-momo-2025-0216` exists.

### Step 2: validate Spring main-chain compatibility first

Pay special attention to:

- Spring Boot 3.x → 4.0.0-RC2
- Spring Cloud 2024.x → 2025.1.0-M4
- Spring Cloud Alibaba 2023.x → 2025.0.0.0
- `spring-cloud-starter-bootstrap` 4.3.0 → 5.0.0-M4

These are not ordinary patch upgrades. They are cross-major and milestone-based combinations.

### Step 3: check Jakarta / Servlet breakpoints

The root POM already documents compatibility considerations around `jakarta.servlet-api.version=6.1.0`, which is a signal that this area has already been risky in practice. During upgrades, inspect at least:

- Servlet API
- Jakarta migration points such as Validation / Persistence / JAXB
- whether Spring-related starters implicitly pull stricter constraints

### Step 4: freeze non-Spring domains during the first pass

When upgrading the Spring main chain, avoid opportunistically upgrading unrelated domains at the same time, especially:

- Jackson
- Netty
- Hibernate
- MyBatis
- Liquibase

The original design of `2025-stack` is selective override. The fewer unrelated changes you mix in, the easier root-cause analysis becomes.

## Upgrade Diff Checklist

Before accepting an upgrade, compare at least these areas:

- root version properties changed in `pom.xml`
- imported upstream BOM trains changed in Spring / Alibaba Cloud modules
- directly managed dependencies outside upstream BOMs, such as `springdoc`, bootstrap starter, or boot admin
- legacy dual-line properties such as `vertx-legacy.version`
- plugin-management versions if the consumer uses `0216`
- resulting dependency tree for convergence and duplicate versions

## Cross-Stack Compatibility Checklist

If the upgrade may affect shared contracts or shared dependencies, also check:

- whether `r2mo-spec` consumers on both the R2MO and Zero sides still agree on enums, DTO shape, naming, and semantic meaning
- whether serialization-related libraries such as Jackson stay compatible across both runtime families
- whether dependency alignment in Momo still supports both the Spring-oriented line and the Vert.x-oriented line without hidden convergence conflicts
- whether a spec-facing change is actually semantic drift disguised as a version bump
- whether rollback can be done without leaving one stack on an incompatible shared-contract version

## Rollback Thinking

Rollback should be designed before rollout, not after failure.

### Best-case rollback path

- switch consumer import from `rachel-momo-2025-stack` back to `rachel-momo-stack`
- keep unrelated domain versions untouched
- re-run dependency tree / convergence checks

### Harder rollback path

If the project also changed its parent strategy or plugin versions during the same upgrade, rollback becomes harder because:

- dependency changes and build changes are now coupled
- plugin behavior may differ even after dependency rollback
- the consumer may have adopted APIs only available on the new Spring line

That is why the safest upgrade path is:

1. move dependencies first
2. keep parent/build behavior stable if possible
3. only then consider broader build standardization

## Decision Branches After the Upgrade

### Branch 1: the experiment succeeds

You can keep using `rachel-momo-2025-stack` as the baseline for pilot projects, but that still does **not** automatically mean you should rewrite the default `rachel-momo-spring` baseline.

### Branch 2: the experiment fails

Rollback is simple:

- switch the import entry from `rachel-momo-2025-stack` back to `rachel-momo-stack`

Because the overlay model never rewrites the default stack structure, rollback cost stays relatively low.

## When should the 2025 line become the default baseline?

Only consider that once all of the following are true:

- pilot projects already run successfully
- the main Spring / Cloud / Alibaba Cloud combination has been validated
- the parent inheritance strategy also has a clear long-term answer
- there is no longer a need to maintain the old baseline in parallel

Until then, keep `2025-*` as an experimental layer instead of merging it into the default stack.
