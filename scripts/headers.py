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

def find_module(path):
    """Finds the module name by walking up from the file to `Sources/ModuleName/` or `Tests/ModuleName/`."""
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
    """Checks if the file already has a Relay MIT header."""
    header_marker = "Copyright © 2025 Relay Contributors"
    return any(header_marker in line for line in lines[:10])

def strip_existing_header(lines):
    """Strips existing comment block from top of the file."""
    end = 0
    for i, line in enumerate(lines):
        if not line.strip().startswith("//"):
            end = i
            break
    return lines[end:]

def update_headers(root_dir="."):
    today = date.today().strftime("%B %d, %Y")

    for dirpath, _, filenames in os.walk(root_dir):
        for fname in filenames:
            if not fname.endswith(".swift"):
                continue

            full_path = os.path.join(dirpath, fname)

            with open(full_path, "r", encoding="utf-8") as f:
                lines = f.readlines()

            if has_existing_header(lines):
                # Remove old header
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