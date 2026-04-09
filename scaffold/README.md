# Scaffold (copy to repo root)

This directory is the **ready-to-copy** skeleton from `recreate-prompt.md`.

## Adoption

1. Copy **everything inside** `scaffold/` to the target repository **root** (not the `scaffold/` folder itself), merging with existing files only when you intend to replace or extend them.
2. After copy, canonical paths are repo-root `REPO.md`, `AGENTS.md`, `SPEC.md`, etc. The copy of `REPO.md` that lived at `scaffold/REPO.md` becomes `./REPO.md`.
3. Edit `AGENTS.md` **Read First** to point at your real product paths.
4. Fill `SPEC.md`, `STATUS.md`, and `PLANS.md` with project truth; keep `INBOX.md` for ephemeral capture only.
5. **Optional upstream review:** if the repo tracks an upstream on a cadence, add `upstream-intake/` and `skills/upstream-intake/` per `REPO.md` (this bundle omits both).

## What is canonical

- **`REPO.md`** — operating model, routing, stable IDs, commit provenance expectations.

## What ships here verbatim

- `REPO.md`, `INBOX.md`, `research/README.md`, `records/decisions/README.md`, `records/agent-worklogs/README.md`, baseline `skills/*` — copy as-is unless the target repo already owns a deliberate variant.

## What is optional outside this folder

- Local git hooks and CI for commit trailers (see root `CONTRIBUTING.md` / `.githooks/` / `.github/workflows/` in repos that enable them).
- `upstream-intake/` and `skills/upstream-intake/` when upstream tracking is not used.
