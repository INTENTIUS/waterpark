# tests/fixtures

One directory per rule, each holding a `fail` and a `pass` case, which is what
prescription 4 asks for. `access/scripts/check` runs `tflint` over each pair
with `--only` set to that one rule, so a fixture proves its own rule and
nothing else.

A fixture is not applied and never reaches an account. It exists so the rule
has a regression test and so a reader can see, in one file, what the rule
objects to and what it wants instead.
