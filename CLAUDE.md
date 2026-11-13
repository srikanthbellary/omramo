# CLAUDE.md — Omramo

Start with **`docs/AGENT_HANDOFF.md`**: product history, the locked v2 design, the owner's standing preferences, hard rules, repo state, build setup and next steps. Then `docs/PRD.md` (open questions in §12), `docs/ARCHITECTURE.md`, `docs/DESIGN.md`, `docs/CONTENT_PLAN.md`, `docs/IMPLEMENTATION_PLAN.md`, `docs/BUILD.md`.

Hard rules (summary — full text in the handoff):
- Never submit to the App Store or Google Play, and never create App Store Connect records, bundle IDs or signing assets. Srikanth submits by hand.
- Never assume; ask. Unknowns go into open questions. No invented business numbers.
- Work on a branch with a PR. Don't force-push or rewrite `main`; don't merge without Srikanth's approval.
- The design is locked (`docs/design/`): real-app look, never a hardcover book.
- No secrets in the repo.
