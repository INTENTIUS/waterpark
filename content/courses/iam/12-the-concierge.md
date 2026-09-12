---
title: "The concierge"
id: "I12"
lesson: 12
weight: 12
summary: "The AWS desk turns a request into a one-file PR."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: "skills/i12-the-concierge"
# card. empty renders as TODO
goal: "Point the desk at this estate in repo mode and ask it for access the way you would ask a colleague. Watch it find the file, make one edit, plan it, and open a pull request whose body carries the access delta and marks you as an unverified claim. Ask again as somebody the estate has never heard of and get a refusal that names the way to become somebody it has, rather than the access. Then make the same edit by hand, open your own pull request, and put the two side by side until you can say what the pipeline noticed about the difference, which is nothing."
done_when: >-
  A request in plain words produces a pull request changing exactly one file,
  whose body names the requester as an unverified claim in those words and
  carries the access delta the same script renders for a human's pull request,
  a request from an identity that appears in no principal's `teams` is refused
  with the enrolment path named and no pull request opened, and your own
  hand-typed pull request making the identical edit passes the identical `pr`
  job and lands a byte-identical access delta.
restart_from: "lesson 11, with the desk on the team from Fountain lesson 7"
properties: ["V", "VIII", "IX"]
closes: ["P13"]
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "45 min"
  needs: ["Fountain lessons 7 and 8 finished, so the desk exists and you have watched it plan", "the desk's GitHub token in the aws-desk-github vault", "an inference key set, this lesson makes two model turns", "jq, curl and gh"]
  solo: true
  live: true
---

## Context

- The concierge is the desk from Fountain lessons 7 and 8 in repo mode, pointed at this estate. Nothing new is built here. What changes is that the target is the access repo, so the refusals are IAM's refusals and the reviewer is CODEOWNERS.
- In repo mode the desk holds a fine-grained GitHub token and nothing that reaches AWS. The merge is the approval and the gated job does the applying, which is decision 18 and lesson 6's pipeline unchanged.
- The intake is plain words. The desk locates the file by the naming rule, makes the one edit itself, and there is no request script between the words and the diff, which is decision 34.
- The requester's identity is declared, never asserted. A chat identity earns standing by appearing in a principal's `teams` under this repo's own review, and `access/codeowners.map` is where an estate team meets a GitHub handle. An identity the estate does not know gets the enrolment path, never a pull request for the access, because access you can get by claiming a name is access nobody reviewed.
- Nothing in a conversation attests who is typing, so every pull request the desk opens says the requester is an unverified claim, in those words. That is decision 17, and the honesty is the feature. A reviewer who knows it is a claim can weigh it.
- Prescription 13 is the claim this lesson checks. The agent proposes, the pipeline verifies, humans approve, and a human who makes the same edit by hand goes through the identical jobs and lands the same rendered delta. If the desk's pull request got an easier ride than yours, the pipeline would be trusting the author, which is the thing it is built not to do.

## Do

Lessons 1 to 11 built the estate and the pipeline. This one puts an agent in front of them and changes nothing else.

1. Seat the desk in repo mode, which is where it holds no credential that can reach your account.

   ```sh
   just desk-hire repo
   ```

   If it stops for want of a `GITHUB_TOKEN`, the Self-paced section says what kind to mint and why that shape is the whole claim.

2. Ask for access the way you would ask a person, and say who you are.

   ```
   I am Dana from the platform team. site-publisher needs list on waterpark-artifacts, so the build can see which checkpoint bundles exist before it picks one.
   ```

   Watch what it does before the pull request appears. It reads the estate from the account, finds `access/envs/prod/iam_role.site_publisher.tf` by the naming rule, checks that the team you named is on that principal, makes one edit, plans it, renders the delta with `render-delta` and the digest with `plan-digest`, and only then opens the pull request.

3. Read the pull request as a reviewer, not as the person who asked.

   ```sh
   gh pr view <number> --json body --jq '.body' | head -20
   gh pr view <number> --json files --jq '[.files[].path]'
   ```

   One file. The body opens by naming you and marking the claim.

   ```
   Requested by Dana, of the platform team (unverified claim), in this
   conversation, in these words: "site-publisher needs list on
   waterpark-artifacts, so the build can see which checkpoint bundles exist
   before it picks one."
   ```

   Nothing checked that you are Dana and nothing pretends otherwise. The words "unverified claim" are load bearing, and a desk that dropped them would be handing a reviewer a fact it does not have.

4. Now ask as somebody the estate has never heard of.

   ```
   I am Sam from the analytics team. on-call needs read on waterpark-site.
   ```

   It refuses, and the refusal is about standing rather than about the grant. `on-call` lists `teams = ["platform"]`, `analytics` appears nowhere in `access/codeowners.map`, and so there is nobody the desk can place Sam behind. The next step it names is a pull request adding that team to the principal's `teams`, reviewed by whoever already owns it, which is enrolment. No pull request was opened for the read.

   Read what that prevents. If naming a team were enough, anybody who could type could grant themselves anything the desk could reach, and every review downstream would be reviewing a sentence somebody made up.

5. Make the same edit yourself, by hand, and open your own pull request.

   ```sh
   git checkout -b same-edit-by-hand origin/main
   ```

   Add the identical grant to `access/envs/prod/iam_role.site_publisher.tf`, with the same resource, access and reason, then commit and open a pull request.

6. Put the two jobs side by side. This is the lesson.

   ```sh
   gh pr checks <the desk's number> | grep -E '^pr'
   gh pr checks <your number> | grep -E '^pr'
   ```

   Both ran the same `pr` job. Now compare what each rendered.

   ```sh
   gh run view --job=<the desk's job id> --log | grep -A8 'The access delta'
   gh run view --job=<your job id> --log | grep -A8 'The access delta'
   ```

   The same lines, from the same script, over the same plan. The pipeline did not know or care which pull request came from an agent, and that is prescription 13 holding rather than being asserted. Say out loud what would be true if it were not. An agent whose pull requests skipped a check would be a second path to prod, and lesson 6 exists to say there is one.

7. Fill in the row. Fountain lesson 4's credential table has a line per holder. Add the concierge's.

   | Who | Holds | Can |
   |---|---|---|
   | the desk, repo mode | a fine-grained token, one repo, contents and pull requests | clone, commit on `desk/*`, open a pull request |
   | CODEOWNERS | review rights on the files the principal routes to | approve, which is the merge |
   | the apply job | the apply role by OIDC, bounded | apply on `main`, and only a plan whose digest matches |

   Then say which row you would have to compromise to get an unreviewed grant into the account, and notice that the desk's row is not one of them.

## Self-paced

Everything runs against the Start-here stack and your own copy of this repo. The one credential you mint is the desk's GitHub token, and the shape matters more here than anywhere else in the course. Fine-grained, one repository, contents and pull requests. A classic token with `repo` scope would work and would also hand the desk every repository you can reach, which turns a lesson about bounded blast radius into a demonstration of the opposite.

What Floci cannot show. Access Analyzer answers none of the policy APIs, so `proofs` prints one named skip and the `CheckNoNewAccess` verdict a real reviewer would weigh is not there. The lesson records a real-account run rather than pretending the emulator produced one.

The other gap is the one lesson 9 names. The apply that a merge triggers runs against the job's own emulator rather than the one on your laptop, so merging the desk's pull request does not change your local account. On a real estate those are the same account.

## Live

Twenty minutes. Run step 2 and let the room watch the tool lines while nothing appears to happen, then open the pull request on the screen and read the first line out loud, including the words unverified claim. Run step 4 and let the refusal land.

Say this at step 6, with both job logs side by side.

Nobody wrote a rule that says check the agent's work harder. There is one pipeline, it does not know which of these a person typed, and that is the only reason you can believe either of them.

## Further reading

- [The AWS desk](../../docs/aws-desk.md), and `desk/PROMPT.md` in this repo
- [The propose loop](../../propose-loop.md), the concierge row
- [Prescriptions](../../docs/prescriptions.md), 13
- [Decisions](../../docs/decisions.md), 17, 18 and 34
