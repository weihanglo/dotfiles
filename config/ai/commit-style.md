# Commit structure

## Atomic commits (C-ATOMIC)

Each commit is minimal, yet complete.
It fulfills a single purpose.
It stands enough on its own to build, pass tests, pass formatters, etc.

Symptoms of a non-atomic commit:
- "and" is in the commit description: likely fulfilling two purposes and should be split
- contains dead code: not complete, making it harder to review the appropriateness without the caller
- common operations during a `git bisect` would fail (or mangle the commit like formatters)
- being followed by commits that address CI failures or review feedback

Commits within a PR serve as guideposts for explaining your change to the reviewer and future readers.
By focusing on atomic commits,
the reader is given a cohesive picture of what that commit is intended to do for properly evaluating all of the pieces.

Commits are the unit for root causing a problem with `git bisect`.
With atomic commits, the user running `git bisect` is likely to get a more precise result.

Exceptions:
- Keeping commit that "fixes" the main behavior-changing commit when it is purely additive and intentionally created as a separate commit more to break down the problem into smaller pieces for the reviewer to follow
- *Sometimes* there are pedantic lints that will naturally be resolved by later commits within a PR and resolving them immediately can make it harder for the reviewer to follow the changes
- If a commit is too large to easily understand, a well abstracted unused API may be a good place to split it to help guide the user through your changes

## Reproduce the problem (C-TEST)

Start the PR with one or more commits that introduce any additional tests needed for the PR,
with the tests reproducing the existing behavior.
Any feature or fix commits will then update the tests as behavior changes.

This applies the concept of "a picture is worth a thousand words" to your PR.
As future commits change the behavior,
this gets visualized in the diff of the test results,
clarifying the intent of your PR better than most PR descriptions to both the reviewer and any community members looking to better understand the intent of change.

This also helps you in making sure you are testing the right behavior.
If you make a change and the tests remain unchanged then either the wrong thing is being tested or you haven't actually changed behavior.

Depending on the type of change, the initial tests can take many shapes, including
- the fix commit just updates the expected output
- the feature commit adds an additional API call and updates the expected output
- the test commit uses an older API and the feature commit switches it to the new API call and updates the expected output

In determining how to structure the test commits,
the focus should be on ensuring the diff of the tests accentuates the key changes and minimizes noise.

## Split out refactors (C-SPLIT)

Split refactor steps out of commits with behavior changes.

A commit may seem atomic because it has only one side effect but
the reviewer can still be flooded with a sea of green and red lines and
have to reverse engineer the changes to identify how the pieces fit together,
what changed behavior, etc.

Identifying and splitting out refactors can provide guideposts
to help the reviewer step through the change in smaller, faster to understand pieces.

The ideal case would be to break it down into individual refactor steps
(e.g. "rename a variable" or "extract a method").
It can even be helpful to split out the adding or removing of a scope.
For example, say a group of logic is going to be gated by an `if` condition,
you can have a refactor commit that moves that logic into an indented block
and then have the commit that adds the needed `if` before it.
How far to split up commits is subjective,
based on the complexity of the problem and
the familiarity of your reviewer with that section of code.

For refactors that only make sense in the context of a feature or fix,
carefully crafting small refactor commits can be throwaway work if the PR is not accepted.

<a id="c-intent"></a>

## Be clear in a commit's intent (C-INTENT)

The commit summary should clearly state the intent of the commit,
particularly the visibility of the impact.
This is where conventions like [Conventional Commit](https://www.conventionalcommits.org/) help
which specify a consistent and upfront way to describe the impact
(e.g. `feat`, `fix`, `refactor`)
and the scope of that impact.

This helps the reviewer know what to look for or not look for,
making it faster to scan for the commit and find ways that the commit didn't match the intent
(e.g. a refactor changing an error message).

## Isolate controversy (C-ISOLATE)

Isolate changes that are likely to generate a lot of discussion to PRs with the fewest commits possible.
If refactors make sense independent of the controversial part of the PR,
split them out into a separate PR.

The most controversial part of a PR draws the most attention,
causing other parts of the PR to be neglected,
serializing the review feedback cycles.

By splitting a PR up into smaller chunks,
any other work dependent on those earlier PRs is now unblocked.

If a change needs to be reverted,
you've made it clear what the minimally invasive set of commits is for reverting.

Commits should not be split out into a dependency PR if there is an assumption that the now dependent PR will be merged in the future.

<!-- adapted from https://github.com/epage/epage.github.io/blob/40588fa54a370f1682e8224a3e974a662b77dc42/blog/dev/pr-style.md?plain=1#L203-L366 -->
