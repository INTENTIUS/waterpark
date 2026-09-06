#!/usr/bin/env python3
"""Every relative link in the markdown sources points at a file that exists."""
import os, re, sys
bad = []
# Directories holding markdown nobody here wrote. A downloaded provider ships
# a README with relative links into its own repository, and that README is not
# this repo's to fix. .tflint.d is a dot directory this repo does own, so the
# list is named rather than a dot-prefix rule.
skip_dirs = {'.git', '.terraform', 'node_modules', 'public', 'resources'}
for dp, dirs, fs in os.walk('.'):
    dirs[:] = [d for d in dirs if d not in skip_dirs]
    if any(part in skip_dirs for part in dp.split(os.sep)):
        continue
    for f in fs:
        if not f.endswith('.md'):
            continue
        p = os.path.join(dp, f)
        for m in re.finditer(r'\]\(([^)#\s]+)(#[^)]*)?\)', open(p).read()):
            t = m.group(1)
            if t.startswith(('http', 'mailto')):
                continue
            q = os.path.normpath(os.path.join(dp, t))
            if not (os.path.exists(q) or os.path.exists(q + '.md')):
                bad.append((p, t))
print(f'{len(bad)} broken markdown links')
for b in bad:
    print(' ', *b)
sys.exit(1 if bad else 0)
