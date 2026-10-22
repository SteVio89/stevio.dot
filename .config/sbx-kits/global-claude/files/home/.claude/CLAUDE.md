## Git workflow in the sandbox

You are in a docker sbx sandbox with ready-only clone of the hosts repository.

### One-time setup (safe to repeat)

```bash
git config --global --add safe.directory /run/sandbox/source
git remote get-url host >/dev/null 2>&1 || git remote add host /run/sandbox/source
```

`host` is the human's local repository, mounted read-only. It holds the current `main`.

### Starting a task

1. Run `git fetch host`.
2. Create a new branch from `host/main`:
   `git switch -c <type>/<short-name> host/main`
   Use one of these types: `feat`, `fix`, `refactor`, `chore`, `test`, `docs`.
3. Never base work on the local `main` branch. It is stale and nobody updates it.
4. Never continue on a branch from an earlier task. The human has already merged or discarded it.

### While working

- Commit in small, logical steps with clear messages.
- Commit messages are a single short sentence, e.g. "Add bulk employee edit grid".
- Do not add a `Co-Authored-By: Claude ...` trailer or any other Claude attribution.
- If asked to pick up the latest changes, run `git fetch host && git rebase host/main` on your task branch.
- Run the project's tests and linters before you consider a task done (see Project below).

### Finishing a task

- Commit everything. Uncommitted changes cannot be fetched or reviewed, so the human cannot see them.
- Leave the working tree clean (`git status` shows nothing to commit).
- End your reply with:
  - the branch name
  - a short summary of what changed and why
  - test results, and anything you did not verify or are unsure about
- Print the branch name when you are done

### Never

- Never push to any remote, and never run `gh pr create` or similar commands. The human reviews locally and publishes from the host.
- Never modify, reset, or force-update `main` or any `host/*` ref.
- Never rewrite the history of a branch you did not create for the current task.

