# Lessons — flow-own-engine

- Before re-dispatching a failed executor, check the tree: a dead run may have written nothing, or half a file.
- A headless demo prompt pre-answers every question the skill will ask and says where to stop; otherwise the run stalls or runs on.
- A work already marked `closed` isn't resumed by `/flow:dev`: to demo a close, prepare the work at `phase: slice` with its last slice ticked.
- The project's deny rule on `docs/work/archive/**` also blocks reading that path in throwaway repos: verify there with `git ls-files`, not `ls` or `cat`.
- State that lives on a branch is invisible from another branch: anything that scans for works must read `work/*` branches too.
- To check that a fork's instructions stayed out of the caller, search only `assistant` and `user` messages without `parent_tool_use_id`: `system` `task_started` events carry the fork's prompt as metadata.
- A demo that proves a question is asked must leave that answer out of the prompt, and check that nothing ran before the question.
- In zsh a string of flags is one argument: pass CLI flags to headless runs as an array (`"${F[@]}"`).
