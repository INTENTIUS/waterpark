// The protocol the desk and this page share.
//
// The desk emits fenced blocks in its replies. This file is the page's half
// of that agreement and desk/PROMPT.md is the desk's half. Change one, change
// both, and desk/bin/check-protocol fails the build if the block names here
// and the block names in the prompt stop matching.
//
// A block is a fenced code block whose info string is the block name and
// whose body is one JSON object.

export const BLOCKS = {
  "aws-state": "what the account holds, read from the account",
  "aws-plan": "one change, its access delta, its proofs and its digest",
  "aws-result": "what happened to a plan",
};

export const BLOCK_NAMES = Object.keys(BLOCKS);

// The opening fence is not anchored to a line start on purpose. A reply
// arrives as a stream of text parts, and the newline that separated the prose
// from the fence is not always still there once they are joined, so an
// anchored parser sees a plan as prose and shows nothing. The desk cannot
// control where those parts split, so the page takes the fence where it finds
// it.
const FENCE = /```([A-Za-z0-9_-]+)[ \t]*\n([\s\S]*?)\n[ \t]*```/g;

// A fence that opened on a block name and never closed. A turn that ends
// mid-block leaves one, and it has happened, so the page says so rather than
// showing prose with a plan quietly missing from underneath it.
const UNCLOSED = /```([A-Za-z0-9_-]+)[ \t]*\n((?:(?!```)[\s\S])*)$/;

// Every protocol block in one piece of text, in the order it appears.
// A block whose body is not JSON comes back with `error` set rather than
// being dropped, because a desk that emits malformed JSON is a thing the
// person watching needs to see.
export function parseBlocks(text) {
  const found = [];
  if (!text) return found;
  FENCE.lastIndex = 0;
  let match;
  let end = 0;
  while ((match = FENCE.exec(text)) !== null) {
    end = FENCE.lastIndex;
    const [, name, body] = match;
    if (!BLOCK_NAMES.includes(name)) continue;
    try {
      found.push({ name, data: JSON.parse(body), raw: body });
    } catch (error) {
      found.push({ name, data: null, raw: body, error: String(error.message || error) });
    }
  }

  const dangling = UNCLOSED.exec(text.slice(end));
  if (dangling && BLOCK_NAMES.includes(dangling[1])) {
    found.push({
      name: dangling[1],
      data: null,
      raw: dangling[2],
      error: "the block never closed, so the turn ended in the middle of it",
    });
  }
  return found;
}

// The prose around the blocks, which is what the desk said in words. A fenced
// block that is not a protocol block stays, because a desk quoting a command
// it ran is saying something.
export function stripBlocks(text) {
  if (!text) return "";
  const closed = text.replace(FENCE, (whole, name) =>
    BLOCK_NAMES.includes(name) ? "" : whole,
  );
  const dangling = UNCLOSED.exec(closed);
  const rest =
    dangling && BLOCK_NAMES.includes(dangling[1])
      ? closed.slice(0, dangling.index)
      : closed;
  return rest.replace(/\n{3,}/g, "\n\n").trim();
}

// The only sentence that approves a plan. The desk is told to accept this
// and nothing else, so the button and a person typing produce the same words.
export function approval(planId) {
  return `APPROVE ${planId}`;
}

export const STATUSES = ["applied", "stale", "refused", "failed"];
