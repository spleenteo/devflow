---
name: brainstorm
description: "Flow's dialogue for an idea not yet defined, used inside Flow's works before the frame (run by Flow's conductors), or by hand with /flow:brainstorm. Finds out what the user wants and why before anything is framed or built."
---

# Flow: brainstorm

Running a `/flow:` skill is the user's explicit choice of process: inside it no other process skill applies (brainstorming, grilling, planning, plan execution, test-driven development or worktree skills, from any plugin or personal). `flow:brainstorm` and `flow:grill` are named by their qualified names.

You build what you believe the user wants, and that belief is thinner than it feels. This skill finds out what they want, and why, before anything is framed or built. When you understand the why, you make the hundred decisions they never mention the way they would have.

## First: what do you know?

Before replying: what do I know about what they want, and why?

- **Everything that matters is in the request** ("make the title bold"): say it is clear and exit, below. Nothing is written.
- **Something non-trivial is missing**: start the dialogue.

## The first message

Two things, in this order, and nothing else:

1. One line: if they'd rather skip the questions, they can say so. If they do, the skill is done: state any significant how-it-gets-made choice (platform, language, medium) in one line, then exit.
2. One open question that gets them describing a real moment or a concrete picture: "What's the moment you wish this existed?"

## The dialogue

- **One open question per message**, one sentence, no list of example answers. Plain words, a little above where they are; match their vocabulary.
- **Open before options.** Their words carry intent your options can't. Offer a short menu only when they're stuck; when they say "just guess", propose something concrete. A guess they can correct often beats a question.
- **How it gets made.** Find out early which choices (platform, language, medium, materials) they want to make, which they hand to you, and what already exists to build on. A choice you make goes in the document as your call, never as theirs.
- **Ground to cover**, as territory, never read out: what kind of thing this is; why now and what success looks like; goals, non-goals, anti-goals; prior art; current state; the details they care about.
- **Recon.** When looking would help (their code, files, the web), offer it and say what you'd look for. They decide.
- **Think wide, privately.** Come up with several ideas, drop the weak ones, show the comparison only when it helps them decide.
- **Play back in chunks.** When one part is clear enough to describe, describe it in 200-300 words, then ask about the next part. Mark what you are guessing as your guess; only what they said goes in as theirs. End each chunk asking what is wrong or missing.
- **No spike.** When a throwaway build would teach more than talk, propose it to the caller or the user; never build it here.

## Visuals

When something they will look at (a layout, a flow, side-by-side options, a diagram) would be clearer seen than read, offer it, once, in a message of its own: "This might be easier if I show you. Want me to draw it?" If they decline, stay in text and don't offer again unless they raise it. If a play-back chunk describes something they'll look at and they haven't seen the offer, hold the chunk and send the offer first. On a yes, write an HTML or SVG file and tell them its path: called, next to the passed path, and the caller commits it with the document; by hand, ask for the path when the first visual is accepted. Never a server, never a published page. Requirements, scope and tradeoffs stay in text.

## Size the work

Once you understand it, say the size in plain words; they can override it. A quick, clear task: the request itself. A small change: described in chat, approved there, nothing written (the passed path is not written for that size). A project: the written description. If it is really several independent projects, say so, agree an order and take them one at a time. If it grows, say so and step up a size.

## The written description

For a project, write a plain document a talented builder in the domain could plan from without going back to the user: intent and the why; goals, non-goals, anti-goals; constraints; the parts of the how they decided, as they decided them; what is left to the builder.

**Where.** The caller passes the path (the conductors pass `<work dir>/brainstorm.md` or `<home>/brainstorm.md`). By hand with no path, ask; never a default folder of your own. Called, the caller commits on the work branch. By hand, write it, don't commit, and say so.

**Builder check.** Tell the user a reviewer will read it first and you may come back once with a few questions. Dispatch `flow:plan-reviewer` (top tier, see Models) with a packet: the document's expanded absolute path; the domain (for example "software engineer", "event planner"); "the document is its own mandate"; "apply only the Builder questions lens; there are no tasks"; and one lens, **Builder questions**: you are a talented builder in that domain, handed this document, unable to talk to its author; report only the questions you would still need answered before planning, where a wrong guess would matter, each with why the answer changes the plan; skip what the document leaves to the builder and anything you could decide yourself; if nothing important is left, say so. Read the ranked findings as ranked questions; ignore each finding's recommended fix, and read `Lenses clean: Builder questions` as nothing important left. Without a subagent tool, run the check yourself as that builder. Don't hand the document over until the check is back. Sort the questions into three piles:

- **Answered already** by the conversation or the project: put the answer in the document.
- **Minor**: a sensible builder could settle it without changing what gets built. Settle it, and mark it in the document as your call.
- **Theirs**: only the user can answer, and the answer changes what gets built.

Bring "theirs" in one message, most important first. Update the document with their answers, then hand it over with a short list of the calls you made. That is the only round of questions the check produces.

## Exit

This skill never builds, plans or hands off to a plan or build skill. It ends when the document is approved, or at once when the user takes the skip offer or the request is clear. Called, it returns to its caller with the document's path, or "clear request", "skipped" or "small change: approved in chat, nothing written". By hand, it names `/flow:dev` or `/flow:project` as the next step. Until the user approves the description (in chat for a small change, the document otherwise), nothing is built, and "sounds good" to an idea isn't approval of a description not yet written: no product code, scaffolding or installs. Reading and exploring are fine.

## Models

Flow's agents are in `${CLAUDE_PLUGIN_ROOT}/agents/` (dispatched as `flow:<name>`). Preference for the top tier: `${user_config.model_top}`. A value that is empty, or begins with `${`, is unset. Which model each dispatch takes and the dispatch contract: the work reference, § Agents (`${CLAUDE_PLUGIN_ROOT}/shared/work.md`).

Credit: the method comes from superpowers' `brainstorming` skill and its builder-check prompt (Jesse Vincent, MIT; see [CREDITS.md](../../CREDITS.md)).
