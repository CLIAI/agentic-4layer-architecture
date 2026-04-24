# Meta-pattern — cross-cutting insights on the 4-layer architecture

This file accumulates insights that do not belong to one specific layer
but concern **the pattern itself** — how the layers compose, where they
blur, which trade-offs show up in practice.

Examples of topics that land here:

* when a hook replaces vs augments a skill,
* `context: fork` semantics and when an agent needs memory,
* eager vs lazy skill loading,
* the L3-thinness principle and why it matters,
* `${CLAUDE_PLUGIN_ROOT}` portability quirks,
* namespacing behaviour across enabled plugins.

Entries here should state:

* what was learned / confirmed,
* the source of truth (code path or doc reference),
* the date of the round or note.

---

<!-- entries appended below this line -->
