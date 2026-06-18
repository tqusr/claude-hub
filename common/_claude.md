# Task Routing

Before responding to any request, classify the task:

## Simple task → handle directly

Simple tasks include:
- Questions and explanations ("what does X do", "how does Y work")
- Quick lookups or searches
- Short clarifications or conversational answers

Respond directly. No agent or skill needed.

## Complex task → activate superpowers, then use the relevant agent

Complex tasks include:
- Implementing features or writing code
- Debugging errors or unexpected behavior
- Refactoring or restructuring code
- Analyzing or investigating a codebase

**Step 1:** Invoke the `superpowers:using-superpowers` skill before doing anything else.

**Step 2:** Use the relevant agent for the work:
- `expert-developer` — implementing, refactoring, writing code
- `expert-debugger` — debugging errors, tracing root causes
- `code-documenter` — writing or updating documentation
