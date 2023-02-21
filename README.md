# DVC Monorepo Designs for Multiple Pipelines

- monorepo_1
  - put all the stages in the same file regardless of pipeline boundaries
- monorepo_2
  - have a top level pipeline of all sub pipelines
- monorepo_3
  - monorepo_2, but the top level is defined with a [dvc foreach](https://dvc.org/doc/user-guide/project-structure/dvcyaml-files#foreach-stages)
- monorepo_4
  - monorepo_2, but the top level is dynamic (doesn't need to be updated for every new project)

## Common Repo Structure

1. Each monorepo has 4 sub projects each with one more stage than the last (project_1 has one stage, project_2 has two, and so on).
1. Each stage has a dedicated python script that generates an "artifact" that is used by the next stage if one exists.

## Notes

all of the above approaches work, but have various pros/cons

- monorepo_1 -- all in the same file
  - things get messy quickly as projects and stages scale
- monorepo_2 -- top level pipeline of pipelines
  - probably the most flexible approach, which allows the expression of any inter-pipeline deps/outs
- monorepo_3 -- [dvc foreach](https://dvc.org/doc/user-guide/project-structure/dvcyaml-files#foreach-stages)
  - a simplified version of monorepo_2
  - doesn't support inter-pipeline deps/outs as effectively (as best I can tell), but could be hacked together if you can parameterize outs/deps by the keys/values in the foreach
- monorepo_4 -- dynamic pipeline discovery script
  - no support for inter-pipeline deps/outs, but top-level never needs to change
