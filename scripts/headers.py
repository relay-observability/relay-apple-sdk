import os
import re
from datetime import date

MIT_HEADER_TEMPLATE = """//
//  {filename}
//  {module}
//
//  Created on {created_date} as part of the Relay open-source observability SDK.
//  Copyright © 2025 Relay Contributors. All rights reserved.
//
//  Licensed under the MIT License.
//  See LICENSE.md in the project root for license information.
//
"""

HEADER_REGEX = re.compile(r"""
    ^
    //\s+[\w\d_]+\.(swift)                # Line 1: filename
    \n//\s+\w+                            # Line 2: module
    \n//\s+Created on .+Relay open-source observability SDK\.
    \n//\s+Copyright © 2025 Relay Contributors\. All rights reserved\.
    \n//\s+Licensed under the MIT License\.
    \n//\s+See LICENSE\.md in the project root for license information\.
    \n//
    """, re.VERBOSE)

def find_module(path):
    """Finds the module name from Sources/ or Tests/ directory path."""
    parts = path.split(os.sep)
    if "Sources" in parts:
        idx = parts.index("Sources")
        if idx + 1 < len(parts):
            return parts[idx + 1]
    elif "Tests" in parts:
        idx = parts.index("Tests")
        if idx + 1 < len(parts):
            return parts[idx + 1]
    return "UnknownModule"

def has_existing_header(lines):
    """Checks if the file already has the full standardized MIT header."""
    content = "".join(lines[:8])  # read top 8 lines only
    return HEADER_REGEX.match(content) is not None

def strip_existing_header(lines):
    """Strips all leading comment lines and blank lines."""
    end = 0
    for i, line in enumerate(lines):
        stripped = line.strip()
        if stripped.startswith("//") or stripped == "":
            end = i + 1
        else:
            break
    return lines[end:]

def update_headers(root_dir="."):
    today = date.today().strftime("%B %d, %Y")

    for dirpath, _, filenames in os.walk(root_dir):
        # Only process files in Sources/ or Tests/
        if not ("/Sources/" in dirpath or "/Tests/" in dirpath):
            continue

        for fname in filenames:
            if not fname.endswith(".swift"):
                continue

            full_path = os.path.join(dirpath, fname)

            # Exclude known non-targets
            if "Package.swift" in full_path or "/.build/" in full_path:
                continue

            with open(full_path, "r", encoding="utf-8") as f:
                lines = f.readlines()

            if has_existing_header(lines):
                stripped_lines = strip_existing_header(lines)
            else:
                stripped_lines = lines

            module_name = find_module(full_path)
            new_header = MIT_HEADER_TEMPLATE.format(
                filename=fname,
                module=module_name,
                created_date=today
            )

            updated_content = new_header + "\n" + "".join(stripped_lines)

            with open(full_path, "w", encoding="utf-8") as f:
                f.write(updated_content)

            print(f"✅ Updated: {full_path}")

if __name__ == "__main__":
    update_headers()