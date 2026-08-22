#!/usr/bin/env python3
"""Every internal href in ./public resolves to a rendered file."""
import os, re, sys
root = 'public'
bad = []
for dp, _, fs in os.walk(root):
    for f in fs:
        if not f.endswith('.html'):
            continue
        html = open(os.path.join(dp, f)).read()
        for m in re.finditer(r'href="(/[^"#?]*)', html):
            t = m.group(1)
            p = os.path.join(root, t.lstrip('/'))
            if not (os.path.isfile(p) or os.path.isfile(os.path.join(p, 'index.html'))):
                bad.append((os.path.relpath(os.path.join(dp, f), root), t))
print(f'{len(bad)} broken internal links')
for b in bad:
    print(' ', *b)
sys.exit(1 if bad else 0)
