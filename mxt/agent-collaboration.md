# Agent Collaboration

## Preconditions

The main editing targets in this repository are POM files, not Java source code. Agents should focus on:

- version properties
- BOM import relationships
- parent / stack consumer entry points
- plugin management and publishing build behavior

Do not treat this as a typical business repository and search for `controller`, `service`, or `entity`.

## Recommended Role Split

### 1. Structure agent

Responsible for:

- identifying the relationships between the root POM, `stack`, `0216`, and the `2025` overlay
- maintaining the module map
- answering which entry point a consumer should use

Read first:

- `/Users/lang/zero-cloud/app-zero/rachel-momo/pom.xml`
- `/Users/lang/zero-cloud/app-zero/rachel-momo/rachel-momo-stack/pom.xml`
- `/Users/lang/zero-cloud/app-zero/rachel-momo/rachel-momo-0216/pom.xml`
- `/Users/lang/zero-cloud/app-zero/rachel-momo/rachel-momo-2025-stack/pom.xml`

### 2. Version agent

Responsible for:

- querying root properties
- answering which version a dependency is currently locked to
- distinguishing the stable line from the experimental line

Read first:

- the `<properties>` section of the root `pom.xml`
- the relevant domain `rachel-momo-*.pom`

### 3. Upgrade agent

Responsible for:

- assessing the impact of upgrading an upstream ecosystem such as Spring or Vert.x
- deciding whether the overlay pattern should be used
- identifying dual-mainline compatibility points

Read first:

- `rachel-momo-spring`
- `rachel-momo-2025-spring`
- `rachel-momo-alibaba-cloud`
- `rachel-momo-2025-alibaba-cloud`
- `rachel-momo-vertx`

## Common Collaboration Mistakes

### Mistake 1: treating the root `pom.xml` as the final import entry

Correction:

- the root POM is the definition center
- `stack` is the public dependency entry
- `0216` is the public parent entry

### Mistake 2: assuming 2025 is the default baseline

Correction:

- `2025-*` file names and README markers both indicate it is an experimental layer
- it is applied as an overlay on top of the default stack
- it must not be described as the default production line

### Mistake 3: editing only a domain module without updating `stack`

Correction:

- editing a domain module only establishes that the module exists locally
- if it has not been added to `rachel-momo-stack`, consumers normally cannot reach that BOM

## Editing Principles

### Change only one semantic layer per need

- changing a version value: prefer the root property
- changing an upstream BOM mapping: change the domain module
- changing the exposed consumer entry: change `stack` or `0216`

Avoid changing all three layers at once unless it is clearly required.

### Preserve comment semantics

This repository uses many inline comments to explain why a version was chosen, for example:

- Spring Boot / Cloud compatibility notes
- Jakarta Servlet fallback notes
- version source links

Those comments are critical for future maintenance and should not be removed mechanically.

### Search before guessing

If you need to answer who currently governs a library, search first:

- whether the root property exists
- whether a child BOM declares the corresponding artifact
- whether `stack` imports that child BOM

## Minimum Verification

For documentation or structural changes in this repository, the minimum verification is:

- the target directory exists
- the file name matches the entry document links
- the content correctly distinguishes `stack`, `0216`, and `2025-stack`

For POM changes, additionally verify:

- the change still conforms to Maven `import` or `parent` semantics
- the version was not changed at the wrong layer
