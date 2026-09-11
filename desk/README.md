# The AWS desk

A static page that talks to a Fountain teammate which holds a clone of this
repo, plans one change at a time against the estate, and applies what you
approve. [The design doc](../content/docs/aws-desk.md) is the long version
and this directory is the v0 of it.

What is here.

```
PROMPT.md      the desk's system prompt, and the source for the manifest
fountain.yaml  the Environment, Vault and Agent, generated from PROMPT.md
protocol.js    the blocks the page reads out of the desk's replies
fountain.js    a Fountain client, fetch and a bearer key, no SDK
app.js         the page
index.html     two panes, Estate and Activity
bin/
  render-manifest   PROMPT.md to fountain.yaml
  check-protocol    hold PROMPT.md and protocol.js to each other
```

The page is mounted into the site at `/desk/`, so `just serve` publishes it
at <http://localhost:1313/desk/> and the deployed site carries it too. The
source stays here, beside the prompt it belongs with, rather than in
`static/`.

## Run it

The class stack, up and registered, with an inference key set.

```sh
just up && just register you@example.com && just runner
fountain apply -f desk/fountain.yaml
```

Then put the desk on the team, which opens its one thread and gives it a
computer. The vault binds to that conversation at creation.

```sh
just desk-hire
```

Open <http://localhost:1313/desk/> with `just serve` running. Sign in with
Fountain, or paste an API key. Ask for access in plain words.

## What it holds, and what it cannot do

| Who | Holds | Can |
|---|---|---|
| the desk | a vault with Floci's throwaway pair, bound to its one conversation | plan and apply on `access/envs/prod` |
| the page | your Fountain session | approve, by message |

Direct mode is honest about what it is. The desk holds a credential that
writes to the account, and the approval is a message rather than a merge. The
scope of that credential is the real control, which on a real account means
an assume-role into `desk-operator` bounded by the estate boundary, with the
conversation id as the STS source identity. Repo mode, where the desk holds
nothing that can reach AWS and the merge is the approval, is the course's
posture and it comes with the IAM lessons.

## The protocol has two halves

`PROMPT.md` tells the desk which blocks to emit. `protocol.js` tells the page
which blocks to read. A block added to one and forgotten in the other is a
page that silently drops what the desk said, so `bin/check-protocol` fails
when they disagree, and `just ci` runs it.

The manifest is generated for the same reason. A system prompt that lives in
a YAML file and in a Markdown file is a system prompt that disagrees with
itself within a week, so `PROMPT.md` is the source and `bin/render-manifest`
writes the YAML.

## Three fields the desk never writes

`changes` comes out of `terraform show -json`, `delta` out of
`access/scripts/render-delta`, and `digest` out of
`access/scripts/plan-digest`. The desk copies them into the block. That is
decision 14, and it is why the page can show a plan without trusting the
model's summary of it.

The digest is the same on any machine. A plan of the same change computed in
the desk's sandbox on Linux and on the author's laptop gives one
`sha256:6778be0e...`, which is what makes an approval bind to a change rather
than to a run.

## What direct mode costs, named

The desk edits the clone on its own computer and applies from there. The
account moves and the repo does not, so until somebody commits that edit the
next plan from a fresh clone proposes to take the grant away. Direct mode
does not close that gap, it only has to be honest about it, and the desk says
so in words every time it applies.

Repo mode closes it by construction, because the edit is a commit before it
is an apply. That is the course's posture and the one part of the loop that
differs between the two, which is lesson 8's question.

## What v0 leaves out

- The drift pane and the `aws-drift` block. That is the watch, and it comes
  with lesson 9.
- Repo mode. The desk opens no pull requests yet.
- The proofs. Access Analyzer is a stub on Floci, so `proofs` prints one
  named skip and the page shows it as a skip. A real account gives the
  verdict, and the lesson records one such run rather than pretending the
  emulator ran it.
