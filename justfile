# water park — local site tasks. `just` lists them.

set shell := ["bash", "-euo", "pipefail", "-c"]

port := "1313"

default:
    @just --list

# Serve the site locally with live reload: http://localhost:1313
serve:
    hugo server --port {{port}} --buildDrafts --disableFastRender --navigateToChanged

# Serve on all interfaces, for a phone or another machine on the LAN
serve-lan:
    hugo server --port {{port}} --bind 0.0.0.0 --baseURL "http://$(ipconfig getifaddr en0 2>/dev/null || hostname -I | awk '{print $1}'):{{port}}/" --buildDrafts --disableFastRender

# Build to ./public as CI does (gc, minify); any Hugo warning fails the build
build:
    hugo --gc --minify --panicOnWarning

# Build, then verify every internal link in the rendered site resolves
check: build
    python3 scripts/check_site_links.py

# Verify every relative link in the markdown sources points at a real file
check-md:
    python3 scripts/check_md_links.py

# Everything CI would care about
ci: check check-md

# Print the syllabus from front matter
syllabus:
    @for c in foundations iam; do \
      echo "== $c"; \
      for f in content/weeks/$c/*.md; do \
        case "$f" in */_index.md) continue;; esac; \
        n=$(sed -n 's/^number: "\(.*\)"/\1/p' "$f"); \
        t=$(sed -n 's/^title: "\(.*\)"/\1/p' "$f"); \
        w=$(sed -n 's/^weight: \(.*\)/\1/p' "$f"); \
        printf '%s\t%s\t%s\n' "$w" "$n" "$t"; \
      done | sort -n | cut -f2-; \
    done

# New shift page from the template: just new two 16 I16 "Title of the shift"
new week shift id title:
    scripts/new_lesson.sh {{week}} {{shift}} {{id}} "{{title}}"

# List every TODO marker and empty card field across the content
todos:
    @grep -rn --include='*.md' -e '{{{{< todo' -e '^today: ""' -e '^done_when: ""' -e 'provider: todo' content | sed 's|^content/||' || true
    @echo; echo "$(grep -rho --include='*.md' '{{{{< todo' content | wc -l | tr -d ' ') todo markers"

# Remove build output
clean:
    rm -rf public resources .hugo_build.lock
