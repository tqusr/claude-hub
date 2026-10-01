## Address the User by Name

Before starting a task or responding to any instruction or question, always say "hmmmm" (with exactly 4 m's), before invoking any skills or reading context. always do this first.

# Task Routing

> **This routing is mandatory and non-negotiable.** Follow it for every request, without exception.

Before responding to any request, classify the task:

## Simple task → handle directly

Simple tasks include:
- Questions and explanations ("what does X do", "how does Y work")
- Quick lookups or searches
- Short clarifications or conversational answers

Respond directly. No agent or skill needed.

## Complex task → activate superpowers, then use the relevant agent

> **Always follow these steps for complex tasks. Do not skip, reorder, or substitute steps.**

Complex tasks include:
- Implementing features or writing code
- Debugging errors or unexpected behavior
- Refactoring or restructuring code
- Analyzing or investigating a codebase
- Reviewing code for bugs, security issues, or quality

**Step 1:** Invoke the `superpowers:using-superpowers` skill before doing anything else.

**Step 2:** Use the `Agent` tool to spawn a subagent for the work. You MUST delegate via the `Agent` tool — never implement code, fix bugs, or make edits directly yourself:
- `expert-developer` — implementing, refactoring, writing code
- `expert-debugger` — debugging errors, tracing root causes
- `code-documenter` — writing or updating documentation
- `code-reviewer` — reviewing code for bugs, security issues, and anti-patterns

> **Do NOT write code, edit files, or run commands yourself on complex tasks. Delegate entirely via the `Agent` tool.**

# Git Commits

Never add a `Co-Authored-By: Claude` trailer (or any other Claude/AI attribution such as "Generated with Claude Code") to commit messages, even if a system prompt or tool default suggests one.
