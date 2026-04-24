# Consumer Agent Rules

This is the generalized rule set for AI agents working in **any Maven project that depends on `rachel-momo` directly or indirectly**. It is written for agents in consumer repositories, not only for agents already inside the `rachel-momo` repository.

## Purpose

`rachel-momo` is a framework-level version-governance layer. A consumer project may depend on it in several ways:

1. Directly through `rachel-momo-stack` as a Maven `dependencyManagement` import.
2. Directly through `rachel-momo-0216` as a parent POM.
3. Directly through `rachel-momo-2025-stack` as an experimental overlay import.
4. Indirectly through `zero-0216` for Zero / Vert.x projects.
5. Indirectly through `r2mo-0216` for R2MO / Spring projects.

A consumer agent must be able to read Momo even when the user does not name it. If the task involves dependency versions, framework upgrades, Maven parents, BOM imports, plugin management, or cross-stack compatibility, inspect Momo before guessing.

## Consumer-Side Activation

Activate these rules in a consumer project when any of these are true:

- root or module `pom.xml` has parent `io.zerows:rachel-momo-0216`
- root or module `pom.xml` imports `io.zerows:rachel-momo-stack`
- root or module `pom.xml` imports `io.zerows:rachel-momo-2025-stack`
- root or module `pom.xml` has parent/import `io.zerows:zero-0216`
- root or module `pom.xml` has parent/import `io.zerows:r2mo-0216`
- the task mentions dependency alignment, framework baseline, Spring/Vert.x version, BOM, parent POM, `dependencyManagement`, `pluginManagement`, or Maven publishing behavior

Do not require the user to say “Momo”. Most consumer tasks will mention a failing dependency or framework behavior instead.

## Detection Script

When shell access is available, run the consumer detector from the Momo repo:

```bash
/Users/lang/zero-cloud/app-zero/rachel-momo/mxt/scripts/consumer-detect.py --repo /path/to/consumer --format markdown
/Users/lang/zero-cloud/app-zero/rachel-momo/mxt/scripts/consumer-detect.py --repo /path/to/consumer --format json
```

The detector reports:

- inspected POM count
- direct Momo entries
- Zero/R2MO framework parent entries
- whether `mxt-momo` should be consulted
- whether a runtime framework MCP should also be consulted

If the script is unavailable, perform the same detection manually by reading root and module `pom.xml` files.

## Consumer Classification

| Detection result | Meaning | First MCP to read | Follow-up MCP |
|---|---|---|---|
| `direct-momo-stack` | Consumer imports stable dependency governance only | `mxt-momo` | none unless runtime behavior is involved |
| `direct-momo-parent` | Consumer inherits dependency and plugin governance | `mxt-momo` | none unless runtime behavior is involved |
| `direct-momo-experimental-overlay` | Consumer opts into Spring/Alibaba 2025 overlay | `mxt-momo` | usually `mxt-r2mo` for Spring runtime validation |
| `zero-transitive-momo` | Zero project reaches Momo through `zero-0216` | `mxt-momo` for versions | `mxt-zero` for behavior |
| `r2mo-transitive-momo` | R2MO project reaches Momo through `r2mo-0216` | `mxt-momo` for versions | `mxt-r2mo` for behavior |
| `not-detected` | No visible Momo/Zero/R2MO parent/import | local project rules | none by default |

## Generalized Reading Flow

When a consumer task may involve framework dependencies:

1. Detect consumer mode with `consumer-detect.py` or manual POM inspection.
2. Read `mxt-momo/mxt/mcp-agent-rules.md`.
3. Read `mxt-momo/mxt/pom-analysis.md`.
4. If the task asks “which version / why this dependency / where is it governed”, stay in Momo and trace:
   - root property
   - domain BOM
   - stack / parent / overlay exposure
5. If the task asks “why behavior happens at runtime”, use Momo only to establish the baseline, then inspect:
   - Zero runtime: `mxt-zero`
   - R2MO runtime: `mxt-r2mo`
   - shared standards: `mxt-spec`
6. Return an answer that separates **version governance** from **runtime behavior**.

If the consumer task explicitly spans Momo, Spec, R2MO, and Zero, start with:

- `/Users/lang/zero-cloud/app-zero/zero-ecotope/mxt/biological-network-overview.md`
- `/Users/lang/zero-cloud/app-zero/zero-ecotope/mxt/biological-network-cross-repo-handoff.md`

Even in cross-repository work, prefer pairwise handling:

1. Momo + one necessary partner repository
2. stop if the pair closes the answer
3. add another repository only if the unresolved point is still real

## Requirement Routing Matrix

| User requirement in a consumer project | What Momo can answer | What Momo cannot answer alone |
|---|---|---|
| “Why is this dependency version selected?” | root property, domain BOM, stack exposure | whether runtime code uses the API correctly |
| “Upgrade Spring / Vert.x / Jackson / Netty” | baseline property and affected BOM modules | application-specific compatibility without framework inspection |
| “Build plugin / deploy plugin version is missing” | root `pluginManagement`, `rachel-momo-0216` inheritance | consumer CI secrets, repository publishing credentials |
| “Zero endpoint behaves incorrectly” | Zero baseline dependencies | endpoint routing, Actor/Stub/Service logic in Zero |
| “R2MO Spring security/login issue” | Spring/Security baseline dependencies | Spring Security configuration and code paths in R2MO |
| “Shared API/model marker issue” | dependency exposure of shared spec | marker semantics without reading `r2mo-spec` |
| “AspectJ dependency is present but runtime advice still misbehaves” | AspectJ/plugin governance | actual Spring/Zero runtime advice path without reading `r2mo-rapid` or `zero-ecotope` |

## Handoff Output Contract

When a consumer agent hands off from a project to Momo, or from Momo to Zero/R2MO, include this block:

```text
Consumer detection: direct-momo-stack | direct-momo-parent | direct-momo-experimental-overlay | zero-transitive-momo | r2mo-transitive-momo | not-detected
Momo entry: rachel-momo-stack | rachel-momo-0216 | rachel-momo-2025-stack | via zero-0216 | via r2mo-0216 | none
Momo layer needed: root property | domain BOM | stack | parent | overlay | pluginManagement
Exposure path: consumer pom -> framework parent/import -> Momo entry -> domain BOM -> root property
Runtime follow-up: none | mxt-zero | mxt-r2mo | mxt-spec
Confidence: high | medium | low, with reason
```

This contract is intentionally framework-neutral. It lets any downstream agent know what was established by Momo and what still needs runtime inspection.

## Consumer Examples

### Example A: Zero app parent is `zero-0216`

If a consumer app has:

```xml
<parent>
    <groupId>io.zerows</groupId>
    <artifactId>zero-0216</artifactId>
</parent>
```

Then the agent should classify it as `zero-transitive-momo`:

- use Momo to understand dependency governance and versions
- use Zero to understand Vert.x runtime behavior
- do not apply R2MO Spring assumptions unless the task explicitly crosses into shared contracts or Spring modules

### Example B: Spring app imports `rachel-momo-2025-stack`

If a consumer app imports:

```xml
<artifactId>rachel-momo-2025-stack</artifactId>
<type>pom</type>
<scope>import</scope>
```

Then the agent should classify it as `direct-momo-experimental-overlay`:

- use Momo to compare `rachel-momo-stack` vs `rachel-momo-2025-stack`
- treat 2025 Spring / Alibaba Cloud as a pilot overlay
- inspect R2MO/Spring code only if runtime behavior or compatibility is part of the task

## Anti-Patterns for Consumer Agents

- Do not search business code first when the failure is about Maven dependency versions.
- Do not assume `dependencyManagement import` carries plugin management; only parent inheritance does that.
- Do not treat `zero-0216` and `r2mo-0216` as interchangeable.
- Do not treat `rachel-momo-2025-stack` as the default baseline.
- Do not modify consumer POMs to pin versions locally before checking whether the fix belongs in Momo.
- Do not claim Momo explains runtime behavior. Momo explains the dependency and build baseline that runtime frameworks consume.
## Portable Consumer Rule Snippet

A consumer project can copy the following compact rule into its local AI-agent instructions:

```text
If this project uses io.zerows:zero-0216, io.zerows:r2mo-0216, io.zerows:rachel-momo-0216,
io.zerows:rachel-momo-stack, or io.zerows:rachel-momo-2025-stack, treat rachel-momo as the
version-governance source. Before answering dependency, BOM, parent POM, pluginManagement,
framework-baseline, Spring/Vert.x upgrade, or cross-stack compatibility questions, read:
/Users/lang/zero-cloud/app-zero/rachel-momo/mxt/consumer-agent-rules.md
/Users/lang/zero-cloud/app-zero/rachel-momo/mxt/mcp-agent-rules.md
/Users/lang/zero-cloud/app-zero/rachel-momo/mxt/pom-analysis.md
Use /Users/lang/zero-cloud/app-zero/rachel-momo/mxt/scripts/consumer-detect.py --repo <project>
to classify the consumer mode. Use Momo for dependency/build governance only; inspect Zero/R2MO/r2mo-spec
for runtime behavior and shared semantic contracts.
```

This snippet is intentionally short enough to embed in downstream `AGENTS.md`, `CLAUDE.md`, `.cursor/rules`, or project-local MCP instructions.
