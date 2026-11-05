#!/usr/bin/env python3
"""Compile/run isolated Swift regression checks and enforce MVC dependencies."""
from pathlib import Path
import argparse
import shutil
import os
import re
import subprocess
import tempfile

parser = argparse.ArgumentParser()
parser.add_argument("--ui-issue")
parser.add_argument("--ui-issues", nargs="+")
parser.add_argument("--live-diagnostics", action="store_true")
args = parser.parse_args()
issues = args.ui_issues or ([args.ui_issue] if args.ui_issue else [])
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

def run_checks(executable, environment):
    result = subprocess.run([executable], cwd=ROOT, env=environment,
                            text=True, capture_output=True)
    print(result.stdout, end="", flush=True)
    print(result.stderr, end="", flush=True)
    result.check_returncode()
    if "Error: Could not find dependencies in package.json" in result.stdout + result.stderr:
        raise SystemExit("Valid fixture manifest produced a false missing-dependencies error")


# Exclude the application entry point; this runner never starts the app lifecycle.
sources = sorted(str(source) for source in APP.rglob("*.swift") if source.name != "AppDelegate.swift")
with tempfile.TemporaryDirectory(prefix="rngui-mvc-tests-") as directory:
    app = Path(directory) / "Verification.app"
    if issues:
        built = Path("/tmp/ReactNativeGUITools-DerivedData/Build/Products/Debug/ReactNativeGUITools.app")
        shutil.copytree(built, app)
        executable = str(app / "Contents/MacOS/ReactNativeGUITools")
    else:
        executable = str(Path(directory) / "MVCRegressionTests")
    subprocess.run([
        "xcrun", "swiftc", "-swift-version", "5", "-parse-as-library", "-whole-module-optimization",
        "-module-name", "ReactNativeGUITools",
        *sources, *map(str, sorted((ROOT / "Tests").glob("*.swift"))), "-o", executable,
    ], cwd=ROOT, check=True)
    environment = {**os.environ, "CFFIXED_USER_HOME": str(Path(directory) / "model-home")}
    run_checks(executable, environment)
    if args.live_diagnostics:
        environment["RNGUI_LIVE_DIAGNOSTICS_HOME"] = str(Path.home())
    for index, issue in enumerate(issues):
        print(f"Running UI scenario #{issue}", flush=True)
        environment["CFFIXED_USER_HOME"] = str(Path(directory) / f"ui-home-{index}-{issue}")
        environment.update(RNGUI_UI_ISSUE=issue,
                           RNGUI_UI_SCREENSHOT=str(ROOT / f"docs/verification/issue-{issue}.png"))
        run_checks(executable, environment)
