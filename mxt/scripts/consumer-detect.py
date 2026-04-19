#!/usr/bin/env python3
"""Detect how a consumer Maven repository reaches rachel-momo governance.

The script is intended for AI agents working in projects that depend on Momo
indirectly through Zero/R2MO or directly through Momo's stack/parent entries.
It does not resolve remote Maven artifacts; it reports what is visible in the
consumer repository's POM files and marks transitive framework cases for MCP
follow-up.
"""
from __future__ import annotations

import argparse
import json
import re
import xml.etree.ElementTree as ET
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any

NS = {"m": "http://maven.apache.org/POM/4.0.0"}
MOMO_ENTRIES = {"rachel-momo-stack", "rachel-momo-0216", "rachel-momo-2025-stack"}
FRAMEWORK_PARENTS = {"zero-0216", "r2mo-0216"}
PROP_RE = re.compile(r"\$\{([^}]+)\}")


@dataclass
class PomHit:
    file: str
    role: str
    groupId: str
    artifactId: str
    version: str
    scope: str = ""
    type: str = ""
    propertyRefs: list[str] | None = None


def find_poms(repo: Path) -> list[Path]:
    if repo.is_file() and repo.name == "pom.xml":
        return [repo]
    poms = [repo / "pom.xml"] if (repo / "pom.xml").exists() else []
    poms.extend(sorted(p for p in repo.glob("*/pom.xml") if p.parent.name != "target"))
    # Preserve order and uniqueness.
    seen: set[Path] = set()
    result: list[Path] = []
    for pom in poms:
        resolved = pom.resolve()
        if resolved not in seen:
            seen.add(resolved)
            result.append(pom)
    return result


def tx(node: ET.Element | None, path: str, default: str = "") -> str:
    if node is None:
        return default
    return (node.findtext(path, namespaces=NS) or default).strip()


def prop_refs(value: str) -> list[str]:
    return PROP_RE.findall(value or "")


def analyze_pom(pom: Path, repo: Path) -> list[PomHit]:
    root = ET.parse(pom).getroot()
    rel = str(pom.resolve().relative_to(repo.resolve())) if pom.resolve().is_relative_to(repo.resolve()) else str(pom)
    hits: list[PomHit] = []

    parent = root.find("m:parent", NS)
    if parent is not None:
        artifact = tx(parent, "m:artifactId")
        group = tx(parent, "m:groupId")
        version = tx(parent, "m:version")
        if artifact in MOMO_ENTRIES or artifact in FRAMEWORK_PARENTS:
            hits.append(PomHit(rel, "parent", group, artifact, version, propertyRefs=prop_refs(version)))

    for dep in root.findall(".//m:dependency", NS):
        group = tx(dep, "m:groupId")
        artifact = tx(dep, "m:artifactId")
        version = tx(dep, "m:version")
        scope = tx(dep, "m:scope")
        typ = tx(dep, "m:type")
        if artifact in MOMO_ENTRIES or artifact in FRAMEWORK_PARENTS:
            role = "dependencyManagement-import" if scope == "import" or typ == "pom" else "dependency"
            hits.append(PomHit(rel, role, group, artifact, version, scope, typ, prop_refs(version)))

    return hits


def classify(hits: list[PomHit]) -> dict[str, Any]:
    artifact_ids = {h.artifactId for h in hits}
    direct_momo = sorted(artifact_ids & MOMO_ENTRIES)
    framework = sorted(artifact_ids & FRAMEWORK_PARENTS)

    if "rachel-momo-2025-stack" in artifact_ids:
        mode = "direct-momo-experimental-overlay"
    elif "rachel-momo-0216" in artifact_ids:
        mode = "direct-momo-parent"
    elif "rachel-momo-stack" in artifact_ids:
        mode = "direct-momo-stack"
    elif "zero-0216" in artifact_ids:
        mode = "zero-transitive-momo"
    elif "r2mo-0216" in artifact_ids:
        mode = "r2mo-transitive-momo"
    else:
        mode = "not-detected"

    return {
        "mode": mode,
        "directMomoEntries": direct_momo,
        "frameworkParents": framework,
        "requiresMomoMcp": bool(direct_momo or framework),
        "requiresRuntimeFrameworkMcp": bool(framework),
    }


def analyze(repo: Path) -> dict[str, Any]:
    repo = repo.resolve()
    poms = find_poms(repo)
    hits: list[PomHit] = []
    for pom in poms:
        try:
            hits.extend(analyze_pom(pom, repo))
        except ET.ParseError as exc:
            hits.append(PomHit(str(pom), "parse-error", "", f"XML parse error: {exc}", ""))
    return {
        "repo": str(repo),
        "pomCount": len(poms),
        "classification": classify(hits),
        "hits": [asdict(h) for h in hits],
    }


def print_markdown(data: dict[str, Any]) -> None:
    c = data["classification"]
    print("# Momo Consumer Detection\n")
    print(f"- repo: `{data['repo']}`")
    print(f"- pom files inspected: {data['pomCount']}")
    print(f"- mode: `{c['mode']}`")
    print(f"- direct Momo entries: {', '.join(c['directMomoEntries']) or '(none)' }")
    print(f"- framework parents/imports: {', '.join(c['frameworkParents']) or '(none)' }")
    print(f"- requires mxt-momo MCP: `{str(c['requiresMomoMcp']).lower()}`")
    print(f"- requires runtime framework MCP: `{str(c['requiresRuntimeFrameworkMcp']).lower()}`\n")

    print("## Hits\n")
    if not data["hits"]:
        print("No direct Momo / Zero / R2MO parent or import entries detected.")
    else:
        print("| file | role | groupId | artifactId | version | scope | type | properties |")
        print("|---|---|---|---|---|---|---|---|")
        for h in data["hits"]:
            props = ", ".join(h.get("propertyRefs") or [])
            print(
                f"| `{h['file']}` | {h['role']} | `{h['groupId']}` | `{h['artifactId']}` | "
                f"`{h['version']}` | `{h.get('scope') or ''}` | `{h.get('type') or ''}` | `{props}` |"
            )

    print("\n## Agent Next Step\n")
    mode = c["mode"]
    if mode == "not-detected":
        print("Do not assume this repository uses Momo. Continue with local project rules unless other evidence appears.")
    elif mode.startswith("direct-momo"):
        print("Read `mxt-momo` docs first: `mcp-agent-rules.md`, `consumer-agent-rules.md`, and `pom-analysis.md`.")
    elif mode.startswith("zero"):
        print("Read `mxt-momo` for dependency governance, then `mxt-zero` for Vert.x runtime behavior.")
    elif mode.startswith("r2mo"):
        print("Read `mxt-momo` for dependency governance, then `mxt-r2mo` for Spring runtime behavior.")


def main() -> None:
    parser = argparse.ArgumentParser(description="Detect Momo/Zero/R2MO usage in a consumer Maven repository")
    parser.add_argument("--repo", default=".", help="consumer repository root or pom.xml")
    parser.add_argument("--format", choices=("markdown", "json"), default="markdown")
    args = parser.parse_args()
    data = analyze(Path(args.repo))
    if args.format == "json":
        print(json.dumps(data, ensure_ascii=False, indent=2))
    else:
        print_markdown(data)


if __name__ == "__main__":
    main()
