---
title: "The propose loop, interactive"
id: "F8"
lesson: 8
weight: 8
summary: "Mend and dns-desk run the propose loop with a person as the propose step."
# skill. a directory in this repo with a SKILL.md that drives the lesson. empty renders nothing
skill: "skills/f8-propose-loop-interactive"
# card. empty renders as TODO
goal: "Run the whole loop against a real account with the desk from lesson 7. Ask it to plan the estate this repo declares, read the plan as an access delta rather than as Terraform, approve it by name and watch it apply. Then ask for one grant in plain words and read the diff it made. Move the account by hand before you approve that one, and watch the desk refuse its own plan as stale rather than apply what you approved to an estate that has since changed. Ask it to widen the boundary and watch it refuse. Then fill the eight parts of the loop for the desk and say which single part differs from Mend."
done_when: >-
  An `aws-plan` block carries a delta, a proof verdict and a digest the desk
  copied rather than wrote, `APPROVE` on it applies and the account read back
  by hand holds what the delta said it would, a plan approved after you
  changed the account by hand comes back as `aws-result` `stale` with the
  moved resource named and nothing applied, a request to widen the estate
  boundary comes back `refused` with the platform path named, and your parts
  table names propose as the one part where the desk and Mend differ.
restart_from: "lesson 7, with the desk on the team"
properties: ["IV", "VIII", "XI"]
# activity. kind is hands-on, watch-along or discuss
activity:
  kind: hands-on
  time: "60 min"
  needs: ["lesson 7 finished, so the desk is on the team and the page is open", "an inference key set, this lesson makes seven model turns", "jq and curl, and the AWS CLI for reading the account back"]
  solo: true
  live: true
---

## Context

- The loop has eight parts and [the propose loop](../../propose-loop.md) names them. Target, read, operator, plan, verify, propose, rules, record, and refusal as an outcome. Mend and dns-desk are the interactive two, one audit-driven and one request-driven, and the desk is dns-desk's form on an AWS estate.
- The plan a person approves is not the Terraform plan. It is the access delta, which says what a principal gains or loses, and `access/scripts/render-delta` writes it out of the plan JSON. The desk copies that text into the block and never composes it, which is decision 14.
- Verify here is a re-plan. The desk saves the plan it showed you, and on approval it plans again and compares digests. A digest that moved means the estate moved under your approval, and the answer is to refuse rather than to apply.
- The digest is over a normalised reading of the saved plan, so two runs of the same change on different machines agree and any change to what would be created, changed or destroyed disagrees. `access/scripts/plan-digest` computes it.
- Direct mode's propose step is an `APPROVE` message in the conversation, and the desk holds the credential that applies it. Mend's propose step is the human's own browser holding the human's own token, and the operator holds nothing that can write. That difference is the whole of this lesson's last step.
- Accessible Ops IV is one path to prod. VIII is escalate the judgement. XI is the live system is the truth, which is why every read here goes to the account and not to the state file.

## Do

Lesson 7 made the desk talk. This one makes it work, and the loop it runs is the one every later lesson instantiates.

1. Check the account is empty, so you can watch it fill. If lesson 7 left it empty this prints nothing.

   ```sh
   export AWS_ENDPOINT_URL=http://localhost:4566 AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1
   aws iam list-roles --query 'Roles[].RoleName' --output text
   ```

   Keep that shell for the rest of the lesson. Every later read is a bare `aws` call and wants those four variables, so a fresh terminal reads a real account instead of the emulator.

2. Ask the desk to plan what the repo already declares. This is the first apply of an estate, and it needs no edit at all.

   ```
   Plan the first apply of everything the repo declares.
   ```

   It reads the account, then plans. The block that comes back carries the pieces a reviewer needs in the order they need them. The access delta first, grouped by principal, with the grants each one gains. Then the proofs, which on Floci are one named skip because Access Analyzer is a stub there. Then the file diff, which is empty here because nothing was edited. Then the typed changes read out of `terraform show -json`.

   Read the delta rather than the change list. Eighteen resources is a Terraform fact. Four principals, five grants and a boundary is what somebody is being asked to approve.

3. Approve it by name, which is the only sentence that approves anything.

   ```
   APPROVE plan-xxxx
   ```

   The desk plans again before it applies, compares the new digest against the one it showed you, and applies the plan you approved rather than the one it just made. Then read the account back yourself, because the live system is the truth and the desk saying so is not the same as the account saying so.

   Read the account rather than the sentence. `detail` is the desk's own words, unlike the delta and the digest beside it, so the count in it is the model reporting rather than a script. One run of this lesson said seventeen added for an eighteen resource plan and the estate was correct anyway.

   ```sh
   aws iam list-roles --query 'Roles[].RoleName' --output text
   aws iam list-policies --scope Local --query 'Policies[].PolicyName' --output text
   ```

4. Ask for one grant, in words, the way somebody would ask a colleague.

   ```
   site-publisher needs list on waterpark-artifacts, so the build can see which checkpoint bundles exist before it picks one.
   ```

   Now the block carries a diff, because this time the desk edited a file. One entry added to the `grants` list in `access/envs/prod/iam_role.site_publisher.tf`, with the reason you gave it carried into the file. Two resources to create, which are the policy and its attachment. Note the plan id and do not approve it yet.

   That file is in the desk's own clone, inside its sandbox, and not in your checkout. The diff in the block is the only sight of it you get, which is a fact about direct mode worth noticing now rather than in step 9.

5. Move the account under the approval, by hand, the way a console click would. Take away a grant the desk is not touching.

   ```sh
   ARN=$(aws iam list-policies --scope Local \
     --query 'Policies[?PolicyName==`site-publisher-list-waterpark-site`].Arn' --output text)
   aws iam detach-role-policy --role-name site-publisher --policy-arn "$ARN"
   aws iam delete-policy --policy-arn "$ARN"
   ```

6. Now approve the plan from step 4.

   ```
   APPROVE plan-xxxx
   ```

   It refuses. The re-plan's digest does not match the digest you approved, so the desk discards the plan and comes back with `aws-result` `stale`, naming the grant that vanished and what a fresh plan would now do instead. Nothing was applied. This is the part of the loop worth watching, because the approval was real, the desk was willing, and the estate had moved.

   Say what you would have got without it. The saved plan would have applied two resources you approved and recreated one you never saw, on an estate nobody described to you.

7. Let it recover. Ask for a fresh plan, read it, and approve that one.

   ```
   I removed that policy by hand. Re-plan and show me the new plan.
   ```

   The new plan has four changes rather than two, because it restores what you deleted as well as adding what you asked for. Approve it and read the account back again.

8. Ask for something it must refuse.

   ```
   The boundary is blocking me. Widen it to allow iam:* so I stop hitting this.
   ```

   That is a change to `access/baseline`, which every role in the estate stands inside, so it is not one principal's grant and not the desk's call. The refusal comes back as `aws-result` `refused` with the next step named, which is the platform path. A refusal is an outcome and not a failure.

9. Fill the table. Copy the eight parts from [the propose loop](../../propose-loop.md) and write the desk's column yourself from what you just watched. Then put Mend's column beside it, which that page already has.

   Seven of the eight are the same shape. Target, read, operator, plan, verify, rules, record. The one that differs is **propose**. Mend's propose step is your browser holding your token, so the operator holds nothing that can write and the rules live in the thing that writes. The desk's propose step is a message, and the desk holds the credential, so the rule that matters is the scope of what that credential can reach.

   Write one sentence saying which you would rather hand to somebody else's org, and why. The IAM course answers it one way and the answer is not the same for a repo you own.

## Self-paced

Everything runs on the Start-here stack against Floci. Two things Floci cannot show.

Access Analyzer is a stub there, so `proofs` prints one named skip and no proof runs. On a real account the same script returns `validate-policy` findings and a `CheckNoNewAccess` verdict, and a FAIL on a change the requester asked for is not an error, it is the thing the reviewer is being asked to approve. The lesson records one real-account run rather than pretending the emulator ran it.

The desk's credential here is Floci's throwaway pair. On a real account it is an assume-role into `desk-operator`, bounded by the estate boundary, with the conversation id as the STS source identity, so CloudTrail says which conversation applied what. The blast radius you are looking at on this stack is the emulator, not a boundary.

## Live

Twenty five minutes, and step 6 is the one the room remembers. Run steps 1 to 4 quickly, then delete the policy in front of everybody and say what you are doing. Approve the stale plan and let the refusal land in silence.

Say this when it refuses.

Nobody wrote a rule that says refuse a stale plan. The desk computes a digest, the estate moved, the digests disagree, and the only honest thing left is to stop. That is what verify before propose means when the target is alive.

## Further reading

- [The propose loop](../../propose-loop.md), the eight parts and the four forms
- [The AWS desk](../../docs/aws-desk.md), the design the desk is v0 of
- Mend README, for the browser as the propose step
- dns-desk README, for the same loop on a Cloudflare zone
