# Lessons

- A Done bound on context growth names the interval it measures: "between the stops" also counts the plan's fixes and the close, which the slice may not touch. (V1)
- Measure a nested-agent change in a throwaway repo with `--permission-mode default`: auto mode hides the approval prompts the test needs. (V1)
- Check every sha an agent reports with `git cat-file -t` before logging it; a report can name commits that don't exist. (V2)
- A fix commit's subject is `Fix review findings on T<n>: <what>`; say so in the fix instruction, executors don't infer it. (V2)
- A reviewer can notify twice with different findings; a task marked complete is reopened when a later report from the same review holds a medium. (V2)
- When a skill section gets its own numbered steps, references to another section's step name that section ("§ Compose step 6"). (V2)
- A finding that quotes a sentence is checked against the file before it goes to an executor; reviewers can cite text that isn't there. (V2)
- Test a transcript-measuring script on a real transcript, not only on the plan's fixture: the fixture had no `cd` and no heredoc body quoting git, and both undercounted. (V3)
- When a write is deferred to a later batch, check every commit that can land before the batch: the final review's fix round needed its own resume rule. (V3)
- An executor's edit script that asserts its matches should run them all before writing any file, or one bad match splits the task across commits. (V3)
