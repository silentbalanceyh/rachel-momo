# Evolution Rules

This document defines how the `rachel-momo/mxt/` knowledge pack should be extended, split, rewritten, and kept in sync as the repository evolves. It applies to both maintainers and AI agents.

## 1. When to add a new md file

Create a new independent `.md` file only when at least one of the following conditions is met:

| Trigger | Description | Suggested filename |
|---|---|---|
| A new independent stack layer is added | e.g. `rachel-momo-2026-*` becomes its own baseline | `upgrade-path-2026.md` or merge into `upgrade-path.md` |
| An important new technical domain appears | e.g. AI inference, wasm, or native image becomes its own BOM module | `domain-<name>.md` |
| The stack structure forks into multiple parallel stacks | e.g. web / reactive / native become three distinct choices | `stack-bom-map-<variant>.md` |
| Multiple parent entry points appear | e.g. `rachel-momo-0216-native` is added | `parent-map.md` |
| Experimental layer documentation grows beyond 1/3 of `upgrade-path.md` | split into `upgrade-path-stable.md` and `upgrade-path-experimental.md` |

**Do not** create a new file for:

- a version bump inside an existing domain BOM
- moving a domain BOM in or out of `stack`
- editing inline version comments or compatibility notes

## 2. When to update an existing md file

| File | Triggers |
|---|---|
| `README.md` | consumer entry added or removed; major-version jump in a key baseline; navigation links change |
| `framework-map.md` | a new domain BOM module is added; a module graduates from experimental to stable; modules are merged or split |
| `version-governance.md` | governance model changes; a significant new dual-mainline is introduced; version selection rationale changes |
| `upgrade-path.md` | a new consumer-facing upgrade path exists; an experimental layer is promoted or deprecated |
| `stack-bom-map.md` | `rachel-momo-stack` import relationships change; an overlay layer is added or removed |
| `agent-collaboration.md` | recommended reading entry points change; agent role boundaries need adjustment due to new modules |
| `mcp-agent-rules.md` | MCP activation conditions, output contract, graph/tooling limitations, or cross-repository routing rules change |
| `consumer-agent-rules.md` | downstream consumer detection, generalized dependency routing, or framework handoff rules change |
| `pom-analysis.md` | Maven/POM extraction method, analyzer-script output, key baseline metrics, or POM failure-mode rules change |
| `search-hints.md` | important property names, artifactIds, stack names, keywords, or analyzer commands are added |

**Do not** update mxt files for:

- POM comment edits
- patch version bumps
- build plugin version adjustments that do not change structure

## 3. Naming rules

### File names

- all lowercase, words separated by `-`
- no spaces, dates, or author names
- reflects the file's responsibility, not a transient state
- a stable semantic suffix such as `-experimental` is allowed only when two long-lived parallel lines coexist

### Content naming

- document titles should use stable, recognizable concepts such as `Framework Map` or `Version Governance`
- body text should use the real artifactId, such as `rachel-momo-stack` and `rachel-momo-0216`
- do not use vague language to replace Maven semantics; write `parent POM`, not "the inheritance bundle"

## 4. Sync rules for README / framework-map / search-hints

These three files are the first documents that agents and maintainers reach. Any structural upgrade must check all three.

### README must be updated when:

- a stack or parent entry is added or removed
- the default baseline and experimental baseline swap roles
- the navigation section gains or loses a file
- a key baseline undergoes a major-version migration

README must always contain:

- repository positioning
- main entry usage (import / parent)
- document navigation, including MCP/POM analysis entry points when present
- current key baselines

### framework-map must be updated when:

- a new domain BOM is added
- a module moves from experimental to stable
- the stack aggregation scope changes

The goal is to let a reader immediately see the root POM / domain BOM / stack / parent / overlay layer hierarchy.

### search-hints must be updated when:

- a new property prefix is added, such as `spring-2026-*`
- a new key artifactId is introduced
- a new parent name or stack variant is introduced
- search now requires cross-file navigation instead of a single file

The goal is to ensure that an agent unfamiliar with the repository can still find the correct POM using keywords alone.

## 5. How agents should validate correct hits after an upgrade

After any upgrade or structural change, run at least these four checks:

### Check 1: entry point hit

Confirm searches for the following still land on valid files:

- `rachel-momo-stack`
- `rachel-momo-0216`
- the current experimental layer, e.g. `rachel-momo-2025-stack`
- any newly added stack or parent names

### Check 2: property hit

Confirm that key version properties are still directly locatable from the root `pom.xml`, for example:

- `spring-boot.version`
- `spring-cloud.version`
- `vertx.version`
- any newly added main-line property, e.g. `spring-2026-boot.version`

### Check 3: navigation hit

Confirm that starting from `README.md` and following links, you can reach:

- framework-map
- version-governance
- upgrade-path
- stack-bom-map
- agent-collaboration
- search-hints
- evolution-rules

### Check 4: semantic hit

Confirm agents will not confuse these distinct roles:

- root `rachel-momo`: version property and plugin management center
- `rachel-momo-stack`: `dependencyManagement import` entry
- `rachel-momo-0216`: parent POM entry
- `rachel-momo-20xx-*`: overlay or experimental layer

If README, framework-map, or stack-bom-map express these roles inconsistently, fix the documents before continuing with extensions.

## 6. Add versus rewrite decision

### Prefer updating existing documents

If a change still falls within an existing file's responsibility, update the file rather than creating a new one.

Examples:

- Spring 2025 is promoted to the stable baseline: update `upgrade-path.md` and `version-governance.md`
- `rachel-momo-foo` domain module is added: update `framework-map.md` and `search-hints.md`

### A new document is required when:

A topic can no longer maintain a single clear responsibility inside an existing file.

Examples:

- upgrade paths have split into stable, migration, and rollback tracks
- the stack map has split into default, native, and reactive topologies

## 7. Maintenance order

After a framework upgrade, apply updates in this order:

1. update root `pom.xml` and affected child BOMs
2. update `version-governance.md`
3. update `stack-bom-map.md`
4. update `framework-map.md`
5. update `upgrade-path.md`
6. update `search-hints.md`
7. update `README.md` navigation and summary last

This order ensures the README links to fully formed content rather than half-finished entries.

## 8. Minimum completion standard

After each evolution, at least the following must be true:

- `README.md` shows the current document navigation including any new files
- `framework-map.md` matches the actual module structure
- `search-hints.md` contains the new entry points and key property names
- agents searching for `stack`, `parent`, or key version properties land on the correct file
- no documents that have become stale are still referenced from the README navigation
