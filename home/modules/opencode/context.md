# Working style
When the user gives you an answer, trust it and act on it; do not
re-verify or re-derive it unless the user signals doubt. Before
researching anything, check whether you already have the answer; if you
are about to run research the user has not asked for, ask first.

# Shell style
Prefer separate bash tool calls over chaining commands with `&&` or `||`.
Only chain when strictly necessary; a chain that includes a non-read-only
command (or conditionals/redirection) always requires approval.
