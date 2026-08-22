#!/usr/bin/env python3
"""Every relative link in the markdown sources points at a file that exists."""
import os, re, sys
bad = []
for dp, _, fs in os.walk('.'):
    if '/.git' in dp or dp.startswith('./public'):
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
