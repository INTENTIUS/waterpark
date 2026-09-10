# Shared by the read-side scripts of lesson 11. Sourced, never run.
#
# Every read goes to the account (decision 42). On the solo path that is
# Floci with the throwaway test pair, and LIVE=true drops the endpoint
# override so the same script reads a real account with whatever credential
# the shell holds.

endpoint="${FLOCI_ENDPOINT:-http://localhost:4566}"
live="${LIVE:-false}"

awsq() {
	if [ "$live" = true ]; then
		aws "$@"
	else
		AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-test}" \
			AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-test}" \
			AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}" \
			aws --endpoint-url "$endpoint" "$@"
	fi
}

require_account() {
	if [ "$live" != true ] && [ "$(curl -s -o /dev/null -m 3 -w '%{http_code}' "$endpoint/" 2>/dev/null)" = "000" ]; then
		echo "$1: nothing is answering on $endpoint, so there is no live account to read." >&2
		echo "    docker run -d --name wp-access-floci -p 4566:4566 \\" >&2
		echo "      -e FLOCI_SERVICES_IAM_ENFORCEMENT_ENABLED=true \\" >&2
		echo "      ghcr.io/lex00/floci:iam-boundary" >&2
		exit 1
	fi
}

now_epoch="$(date -u +%s)"
now_iso="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

to_epoch() {
	local ts="${1%%.*}"
	ts="${ts%Z}"
	ts="${ts%+00:00}"
	if date -u -j -f '%Y-%m-%dT%H:%M:%S' "$ts" +%s 2>/dev/null; then return; fi
	date -u -d "$ts" +%s 2>/dev/null
}

# One JSON object per role the account holds, with its tags folded in and
# its attached policies each carrying their tags and their document.
#
#   { name, arn, boundary, trust: {kind, subjects}, tags: {...},
#     policies: [ { name, arn, tags: {...}, document } ] }
roles_json() {
	local names name
	names="$(awsq iam list-roles --query 'Roles[].RoleName' --output text | tr '\t' '\n')"
	for name in $names; do
		[ -n "$name" ] || continue
		local role tags attached
		role="$(awsq iam get-role --role-name "$name" --query 'Role' 2>/dev/null)" || continue
		tags="$(awsq iam list-role-tags --role-name "$name" --query 'Tags' 2>/dev/null || echo '[]')"
		attached="$(awsq iam list-attached-role-policies --role-name "$name" --query 'AttachedPolicies[].PolicyArn' --output text 2>/dev/null | tr '\t' '\n')"
		local policies="[]" parn
		for parn in $attached; do
			[ -n "$parn" ] || continue
			local ptags ver doc pname
			pname="${parn##*/}"
			ptags="$(awsq iam list-policy-tags --policy-arn "$parn" --query 'Tags' 2>/dev/null || echo '[]')"
			ver="$(awsq iam get-policy --policy-arn "$parn" --query 'Policy.DefaultVersionId' --output text 2>/dev/null)"
			doc="$(awsq iam get-policy-version --policy-arn "$parn" --version-id "${ver:-v1}" --query 'PolicyVersion.Document' 2>/dev/null || echo null)"
			policies="$(jq -c --arg n "$pname" --arg a "$parn" --argjson t "$ptags" --argjson d "$doc" \
				'. + [{name: $n, arn: $a, tags: ($t | map({(.Key): .Value}) | add // {}), document: $d}]' <<<"$policies")"
		done
		jq -c --argjson r "$role" --argjson t "$tags" --argjson p "$policies" -n '
      ($t | map({(.Key): .Value}) | add // {}) as $tags
      | ($r.AssumeRolePolicyDocument.Statement // [] | if type == "array" then . else [.] end) as $st
      | {
          name: $r.RoleName,
          arn: $r.Arn,
          boundary: ($r.PermissionsBoundary.PermissionsBoundaryArn // null),
          trust: {
            kind: (if ($st[0].Principal.Federated // null) != null then "federated" elif ($st[0].Principal.Service // null) != null then "service" else "other" end),
            subjects: ([ $st[] | .Condition // {} | to_entries[] | .value | to_entries[] | select(.key | endswith(":sub")) | .value | if type == "array" then .[] else . end ]
                       + [ $st[] | .Principal.Service // empty | if type == "array" then .[] else . end ])
          },
          tags: $tags,
          policies: $p
        }'
	done
}

# The access level and the resource a grant policy carries, from its name,
# which the persona module writes as <principal>-<access>-<resource>. A
# policy whose name does not start with the principal's was not written by
# the module, so it is reported as what it is, a policy attached from
# somewhere else, rather than parsed into a level it does not have.
grant_parts() {
	jq -c --arg role "$1" '
    .name as $n
    | if ($n | startswith($role + "-")) then
        (($n | ltrimstr($role + "-")) | split("-")) as $p
        | {access: $p[0], resource: ($p[1:] | join("-")), foreign: false}
      else
        {access: "attached", resource: $n, foreign: true}
      end' <<<"$2"
}
