# AspectJ Governance

> Load this file when the task is about AspectJ dependency versions, weaving/tooling alignment, or deciding whether an AOP concern is a runtime/framework issue or a BOM-governance issue.

## 1. Scope

`rachel-momo` does not own Spring/Zero AOP behavior.
It owns the dependency and plugin-governance surface for AspectJ-related tooling.

## 2. Verified Anchors

Confirmed repository anchors:

- root `pom.xml`
  - module `rachel-momo-aspectj`
  - `aspectj.version`
  - `aspectj-jcabi.version`
  - `mavenex.plugin.aspectj`
  - `aspectj-maven-plugin`
- `rachel-momo-aspectj/pom.xml`
- `rachel-momo-stack/pom.xml`

## 3. Ownership Rule

Use Momo when the question is about:

- AspectJ version alignment
- whether `aspectjrt`, `aspectjweaver`, `aspectjtools` are governed centrally
- plugin version governance for `aspectj-maven-plugin`
- BOM exposure of AspectJ libraries to downstream stacks

Do not use Momo when the question is about:

- where an aspect should be implemented
- Spring-side aspect advice logic
- Zero-side before/after pipeline semantics

Those belong in `r2mo-rapid` or `zero-ecotope`.

## 4. Practical Rule

If the change touches:

- version property
- BOM import/export
- build plugin governance

then start in `rachel-momo`.

If the change touches:

- `@Aspect`
- advice logic
- hook ordering
- runtime filter/handler behavior

then start in the framework repository, not here.

## 5. Source and Resource Path

Read in this order:

```text
aspectj-governance.md
-> root pom.xml for version and plugin properties
-> rachel-momo-aspectj/pom.xml for managed artifact exposure
-> rachel-momo-stack/pom.xml for downstream BOM import surface
-> framework repo only after governance ownership is clear
```

Primary proof targets:

- `aspectj.version`
- `aspectj-jcabi.version`
- `mavenex.plugin.aspectj`
- `aspectj-maven-plugin`
- managed `aspectjrt` / `aspectjweaver` / `aspectjtools` exposure

## 6. Pairwise Handling

Preferred pairs:

- `rachel-momo` alone for AspectJ dependency and plugin governance
- `rachel-momo` + `r2mo-rapid` when the unresolved point is whether Spring-side AOP runtime depends on managed AspectJ versions
- `rachel-momo` + `zero-ecotope` when the unresolved point is whether Zero-side hook tooling depends on centrally governed AspectJ artifacts

Do not open both framework repos unless the first pair still cannot prove ownership.

## 7. Direct Deep Retrieval Rule

Direct `code-review-graph` lookup is optional and secondary here.

Use it only when:

- one downstream framework seam is already known,
- the unresolved point is which module structurally consumes AspectJ-governed artifacts,
- BOM and POM inspection remain the primary evidence.
