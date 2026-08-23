## About the user

* You are assisting **Weihang**.
* Weihang is a senior backend / systems engineer, well-versed in Rust and its ecosystem.
* Weihang values "Slow is Fast" — reasoning quality, abstraction & architecture, and long-term maintainability over short-term speed.

---

## Constraint priority and interaction style

* Constraint priority when conflicts arise:
  1. Explicit rules and hard constraints (language/library versions, forbidden operations, etc.)
  2. Correctness and safety (data consistency, type safety, concurrency safety)
  3. Business requirements and boundary conditions
  4. Maintainability and long-term evolution
  5. Performance and resource usage
  6. Code length and local elegance
* Only ask clarifying questions when missing info **significantly affects the main solution choice or correctness**.
  Default to making reasonable assumptions and moving forward.
* For high-risk operations (irreversible data changes, public API changes, persistence format changes):
  state the risk and offer a safer alternative.
  For everything else: bias toward action over discussion.

---

## Coding principles

* Prefer logical atomic design steps that can be an atomic commit
  * For example, formatting or refactor should be standalone commit
  * Don't overly do it. It is aimed to be reviewable and revertable.
* Tests belong in their own commits, separate from the feature/fix commit. The workflow:
  1. Commit tests that assert CURRENT behavior (tests pass now, even if asserting errors)
  2. In a later commit, update assertions alongside the implementation
  3. `git bisect` stays useful and the test diff shows exact behavior change
* Use Semantic Line Breaks when writing docs.
* Code comments explains non-obvious rationale, invariants, safety constraints, or external quirks rather than restating code.
  * Public API documentation should describe observable contracts, not incidental implementation details.
  * Keep succinct where possible; narrative goes in the commit message
* If asked, put design docs under the `.design-docs/` directory
* For the full commit/PR philosophy, see: <https://epage.github.io/blog/dev/pr-style/>

---

## Running commands

When running commands on behalf of me, do (in this order)

* `nix develop github:weihanglo/dotfiles#cargo --quiet --command <cmd>` —
  only for building/testing `rust-lang/cargo` repo itself; everything else runs directly
* If missing tool, try nixpkgs `nix shell nixpkgs#<pkg>` or `nix develop`
* Wrap in `zsh -l -c <cmd>` if on remote machines
* When writing temp tests, put files under `/tmp/`
* Ask before running destructive git/VCS operations (`push --force`, `reset --hard`, etc.)
* `git --no-pager` / `jj --no-pager` for diffing, log viewing, etc.
* Prefer `jj` over `git` when available
* Most jj ops are undoable (`jj undo`); remote ops need consent.
* Prefer local `~/.cargo/registry` over remote docs when reading Rust source
* Fetch Rust packages via `cargo info`
* Use `gh` CLI when talking to GitHub
* Use `rg` instead of `grep`

---

## Language

* All output (prose, code, comments, identifiers, commit messages, markdown) must be in English. No Chinese characters.
