# Fable 5.2 run log (13 Nov 2026, America/New_York)

- Claude Code 2.1.302, logged in via claude.ai (Max, srikanthbellary01@gmail.com). No ANTHROPIC_API_KEY.
- Model: `--model claude-fable-5-2` (CLI prints `[claude-code:unrecognized_model]` because it is not in this CLI build's local list, but the API served it; modelUsage in both result JSONs = claude-fable-5-2 as main model, plus claude-haiku-5-5 which Claude Code uses internally for WebFetch/sub-agent summarising). Alias `fable` resolves to claude-fable-5-1, so it was not used. `--fallback-model claude-opus-5-5` was set but never triggered (no opus in modelUsage).
- Run 1 (designs): `claude -p --model claude-fable-5-2 --permission-mode acceptEdits --allowedTools "Read Write Edit Glob Grep WebFetch WebSearch Bash(google-chrome:*) Bash(python3:*) Bash(ls:*) Bash(mkdir:*) Bash(pdftotext:*) Bash(cp:*) Bash(cat:*)" --add-dir /workspace/srikanth/duo --output-format json "$(cat prompt-designs.md)"` → run-designs.json (54 turns, ~19.5 min, 10:06–10:26).
- Run 2 (assessment): same model/permissions minus chrome/python/cp → prompt-assessment.md → run-assessment.json (27 turns, 10:06–10:23).
- Both prompts include the full 16-point brief (with civilization-wording point 16), business case v5, and the three story PDFs/text.

## v2 design pass (Srikanth feedback, 13 Nov 2026)
- `claude -p --model claude-fable-5-2` (NO fallback model), acceptEdits, tools: Read Write Edit Glob Grep WebFetch WebSearch + Bash(google-chrome/python3/ls/mkdir/pdftotext/cp/cat/curl/unzip/fc-list/base64/mv), prompt `prompt-designs-v2.md` (feedback verbatim). Output `designs-v2/`, result `run-designs-v2.json`.
- Ran ~10:35–11:34 AM ET, 136 turns, ~51 min. modelUsage: claude-fable-5-2 only (174,795 output tokens). v1 `designs/` untouched.

## Build runs (13 Nov 2026, branch feat/global-english-v2)
- Command for each: `claude -p --model claude-fable-5-2 --permission-mode acceptEdits --allowedTools "<Read/Write/Edit/Glob/Grep/WebFetch/WebSearch + read-only git + ls/mkdir/cat/python3/cp/wc/file/find (+rm/mv/swift in phase 2)>" --add-dir /workspace/srikanth/duo --output-format json "$(cat <prompt>)"`, run from the repo root. No fallback model.
- Phase 1 docs (`prompt-build-phase1-docs.md`): 4:08–4:22 PM ET, 59 turns; modelUsage claude-fable-5-2 only.
- Phase 1b content plan + landmarks (`prompt-build-phase1b-content.md`): 4:22–5:20 PM ET, 75 turns; modelUsage claude-fable-5-2 only. Summary: `run-phase1b-content-summary.txt`.
- Phase 2 M1 code (`prompt-build-phase2-m1.md`): 5:20–6:25 PM ET; modelUsage claude-fable-5-2 only. Summary: `run-phase2-m1-summary.txt`.
