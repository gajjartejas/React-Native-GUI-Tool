#!/usr/bin/env python3
"""Compile/run isolated Swift regression checks and enforce MVC dependencies."""
from pathlib import Path
import re
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
APP = ROOT / "ReactNativeGUITools"

for source in (APP / "View").rglob("*.swift"):
    forbidden = r"\b(?:ProjectInfoManager|MainSettingsManager|FileManager|NSWorkspace|URLSession)\s*\.|\bProcess\s*\("
    if re.search(forbidden, source.read_text()):
        raise SystemExit(f"View owns model/infrastructure behavior: {source.relative_to(ROOT)}")
for source in (APP / "Modal").rglob("*.swift"):
    if re.search(r"^import (?:AppKit|Cocoa|SwiftUI)\b", source.read_text(), re.MULTILINE):
        raise SystemExit(f"Model imports UI framework: {source.relative_to(ROOT)}")
print("PASS: View/Model dependency boundaries", flush=True)

# Exclude the application entry point; this runner never starts the app lifecycle.
sources = sorted(str(source) for source in APP.rglob("*.swift") if source.name != "AppDelegate.swift")
with tempfile.TemporaryDirectory(prefix="rngui-mvc-tests-") as directory:
    executable = str(Path(directory) / "MVCRegressionTests")
    subprocess.run([
        "xcrun", "swiftc", "-swift-version", "5", "-parse-as-library", "-whole-module-optimization",
        *sources, str(ROOT / "Tests/MVCRegressionTests.swift"), "-o", executable,
    ], cwd=ROOT, check=True)
    subprocess.run([executable], cwd=ROOT, check=True)
