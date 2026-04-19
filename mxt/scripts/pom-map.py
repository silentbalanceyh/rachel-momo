#!/usr/bin/env python3
"""Emit a compact Maven/POM relationship map for the rachel-momo repository.

This script intentionally analyzes Maven XML instead of relying on code-review-graph,
because rachel-momo's primary semantics live in POM files.
"""
from __future__ import annotations

import argparse
import json
import re
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Any

NS = {"m": "http://maven.apache.org/POM/4.0.0"}
PROP_RE = re.compile(r"\$\{([^}]+)\}")


def text(node: ET.Element | None, path: str, default: str = "") -> str:
    if node is None:
        return default
    value = node.findtext(path, namespaces=NS)
    return (value or default).strip()


def parse_pom(path: Path) -> dict[str, Any]:
    root = ET.parse(path).getroot()
    artifact_id = text(root, "m:artifactId") or text(root, "m:parent/m:artifactId")
    packaging = text(root, "m:packaging", "jar")
    imports: list[dict[str, str]] = []
    managed: list[dict[str, str]] = []
    properties_used: set[str] = set()
    groups: set[str] = set()

    for dep in root.findall(".//m:dependency", NS):
        item = {
            "groupId": text(dep, "m:groupId"),
            "artifactId": text(dep, "m:artifactId"),
            "version": text(dep, "m:version"),
            "type": text(dep, "m:type"),
            "scope": text(dep, "m:scope"),
        }
        if item["groupId"]:
            groups.add(item["groupId"])
        for match in PROP_RE.findall(item["version"]):
            properties_used.add(match)
        if item["scope"] == "import" or item["type"] == "pom":
            imports.append(item)
        else:
            managed.append(item)

    return {
        "path": str(path),
        "artifactId": artifact_id,
        "packaging": packaging,
        "imports": imports,
        "managedDependencies": managed,
        "propertiesUsed": sorted(properties_used),
        "groupIds": sorted(groups),
    }


def root_properties(root_pom: Path) -> dict[str, str]:
    root = ET.parse(root_pom).getroot()
    props = root.find("m:properties", NS)
    if props is None:
        return {}
    return {child.tag.split("}", 1)[-1]: (child.text or "").strip() for child in props}


def root_modules(root_pom: Path) -> list[str]:
    root = ET.parse(root_pom).getroot()
    return [(m.text or "").strip() for m in root.findall("m:modules/m:module", NS)]


def build_map(repo: Path) -> dict[str, Any]:
    root_pom = repo / "pom.xml"
    modules = root_modules(root_pom)
    props = root_properties(root_pom)
    module_maps = [parse_pom(repo / m / "pom.xml") for m in modules if (repo / m / "pom.xml").exists()]
    by_artifact = {m["artifactId"]: m for m in module_maps}
    imported_by: dict[str, list[str]] = {}
    for module in module_maps:
        for dep in module["imports"]:
            imported_by.setdefault(dep["artifactId"], []).append(module["artifactId"])

    return {
        "repo": str(repo),
        "rootArtifactId": text(ET.parse(root_pom).getroot(), "m:artifactId"),
        "moduleCount": len(modules),
        "propertyCount": len(props),
        "versionPropertyCount": len([k for k in props if "version" in k]),
        "keyBaselines": {k: props.get(k, "") for k in [
            "revision",
            "java.version",
            "spring-boot.version",
            "spring-cloud.version",
            "spring-cloud-alibaba.version",
            "vertx.version",
            "vertx-legacy.version",
            "spring-2025-boot.version",
            "spring-2025-cloud.version",
            "spring-2025-cloud-alibaba.version",
        ]},
        "modules": module_maps,
        "importedBy": {k: sorted(v) for k, v in sorted(imported_by.items())},
        "entryPoints": {k: by_artifact.get(k) for k in [
            "rachel-momo-stack",
            "rachel-momo-0216",
            "rachel-momo-2025-stack",
        ]},
    }


def print_markdown(data: dict[str, Any]) -> None:
    print(f"# rachel-momo POM Map\n")
    print(f"- repo: `{data['repo']}`")
    print(f"- root artifact: `{data['rootArtifactId']}`")
    print(f"- modules: {data['moduleCount']}")
    print(f"- properties: {data['propertyCount']}")
    print(f"- version-like properties: {data['versionPropertyCount']}\n")

    print("## Key Baselines\n")
    for k, v in data["keyBaselines"].items():
        print(f"- `{k}` = `{v}`")

    print("\n## Entry Imports\n")
    for name, module in data["entryPoints"].items():
        if not module:
            print(f"- `{name}`: missing")
            continue
        imports = [d["artifactId"] for d in module["imports"]]
        print(f"- `{name}` imports {len(imports)}: {', '.join(imports) if imports else '(none)'}")

    print("\n## Module Summary\n")
    print("| module | imports | managed deps | properties used |")
    print("|---|---:|---:|---:|")
    for module in data["modules"]:
        print(
            f"| `{module['artifactId']}` | {len(module['imports'])} | "
            f"{len(module['managedDependencies'])} | {len(module['propertiesUsed'])} |"
        )


def main() -> None:
    parser = argparse.ArgumentParser(description="Analyze rachel-momo Maven POM relationships")
    parser.add_argument("--repo", default=".", help="repository root")
    parser.add_argument("--format", choices=("markdown", "json"), default="markdown")
    args = parser.parse_args()

    repo = Path(args.repo).resolve()
    data = build_map(repo)
    if args.format == "json":
        print(json.dumps(data, ensure_ascii=False, indent=2))
    else:
        print_markdown(data)


if __name__ == "__main__":
    main()
