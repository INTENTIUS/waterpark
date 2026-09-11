#!/usr/bin/env python3
"""Hold the pages to the prose rule.

    python3 scripts/check_prose.py [path ...]

Prose in content/ bans em dashes, colons and semicolons. Code says those
things, prose does not, so this strips front matter, fenced blocks, inline
code spans, link targets and bare URLs first, then looks at what is left.

The rule is in project/page-model.md, learned from lesson 1, and the reason
it is a script is item 7 of that checklist. Checked by eye it lasted about
one lesson.
"""

import pathlib
import re
import sys

BANNED = {
    "—": "em dash",
    "–": "en dash",
    ":": "colon",
    ";": "semicolon",
}

FRONT_MATTER = re.compile(r"\A---\n.*?\n---\n", re.S)
FENCE = re.compile(r"^[ \t]*```.*?^[ \t]*```[ \t]*$", re.S | re.M)
INDENTED = re.compile(r"^(?: {4}|\t).*$", re.M)
CODE_SPAN = re.compile(r"`[^`]*`")
SHORTCODE = re.compile(r"\{\{[<%].*?[>%]\}\}", re.S)
LINK = re.compile(r"\[([^\]]*)\]\([^)]*\)")
ANGLE_URL = re.compile(r"<https?://[^>]*>")
BARE_URL = re.compile(r"https?://\S+")
# A clock reads 20:06:44 and that colon is a fact about the time, not prose.
CLOCK = re.compile(r"\d:\d")


def blank(match):
    """Drop a match and keep its newlines, so line numbers stay true."""
    return "\n" * match.group(0).count("\n")


def prose(text):
    """What is left once the parts that may say anything are gone."""
    text = FRONT_MATTER.sub(blank, text)
    text = FENCE.sub(blank, text)
    text = INDENTED.sub(blank, text)
    text = SHORTCODE.sub(blank, text)
    text = CODE_SPAN.sub(blank, text)
    text = ANGLE_URL.sub(blank, text)
    text = LINK.sub(r"\1", text)
    text = BARE_URL.sub(blank, text)
    text = CLOCK.sub("", text)
    return text


def check(path):
    lines = prose(path.read_text()).split("\n")
    problems = []
    for number, line in enumerate(lines, start=1):
        for char, name in BANNED.items():
            if char in line:
                problems.append((number, name, line.strip()[:90]))
    return problems


def main(argv):
    # The rule is about the student path. The design docs under content/docs
    # predate it and say things like "three tiers, never mixed in one job:".
    targets = [pathlib.Path(arg) for arg in argv[1:]] or [pathlib.Path("content/courses")]
    files = []
    for target in targets:
        files.extend(sorted(target.rglob("*.md")) if target.is_dir() else [target])

    total = 0
    for path in files:
        for number, name, line in check(path):
            print(f"{path}:{number} {name}  {line}")
            total += 1

    if total:
        print(f"\n{total} banned character(s) in prose. The rule is in project/page-model.md.")
        return 1
    print(f"prose ok, {len(files)} files")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
