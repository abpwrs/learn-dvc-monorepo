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

---
---

# The dvc.yaml files

## monorepo_1
### ./dvc.yaml
```yaml
stages:
  # PROJECT 1
  do_p1_s1:
    cmd: pushd project_1 && python do_stage_1.py && popd
    outs:
      - project_1/artifact_of_stage_1.txt
  # PROJECT 2
  do_p2_s1:
    cmd: pushd project_2 && python do_stage_1.py && popd
    outs:
      - project_2/artifact_of_stage_1.txt
  do_p2_s2:
    cmd: pushd project_2 && python do_stage_2.py && popd
    deps:
      - project_2/artifact_of_stage_1.txt
    outs:
      - project_2/artifact_of_stage_2.txt
  # PROJECT 3
  do_p3_s1:
    cmd: pushd project_3 && python do_stage_1.py && popd
    outs:
      - project_3/artifact_of_stage_1.txt
  do_p3_s2:
    cmd: pushd project_3 && python do_stage_2.py && popd
    deps:
      - project_3/artifact_of_stage_1.txt
    outs:
      - project_3/artifact_of_stage_2.txt
  do_p3_s3:
    cmd: pushd project_3 && python do_stage_3.py && popd
    deps:
      - project_3/artifact_of_stage_2.txt
    outs:
      - project_3/artifact_of_stage_3.txt
  # PROJECT 4
  do_p4_s1:
    cmd: pushd project_4 && python do_stage_1.py && popd
    outs:
      - project_4/artifact_of_stage_1.txt
  do_p4_s2:
    cmd: pushd project_4 && python do_stage_2.py && popd
    deps:
      - project_4/artifact_of_stage_1.txt
    outs:
      - project_4/artifact_of_stage_2.txt
  do_p4_s3:
    cmd: pushd project_4 && python do_stage_3.py && popd
    deps:
      - project_4/artifact_of_stage_2.txt
    outs:
      - project_4/artifact_of_stage_3.txt
  do_p4_s4:
    cmd: pushd project_4 && python do_stage_4.py && popd
    deps:
      - project_4/artifact_of_stage_3.txt
    outs:
      - project_4/artifact_of_stage_4.txt

```


---
## monorepo_2
### ./dvc.yaml
```yaml
stages:
  # PROJECT 1
  project_1:
    cmd: pushd project_1 && dvc repro && popd
  # PROJECT 2
  project_2:
    cmd: pushd project_2 && dvc repro && popd
  # PROJECT 3
  project_3:
    cmd: pushd project_3 && dvc repro && popd
  # PROJECT 4
  project_4:
    cmd: pushd project_4 && dvc repro && popd

```

### ./project_1/dvc.yaml
```yaml
stages:
  do_p1_s1:
    cmd: python do_stage_1.py
    outs:
      - artifact_of_stage_1.txt

```

### ./project_2/dvc.yaml
```yaml
stages:
  do_p2_s1:
    cmd: python do_stage_1.py
    outs:
      - artifact_of_stage_1.txt
  do_p2_s2:
    cmd: python do_stage_2.py
    deps:
      - artifact_of_stage_1.txt
    outs:
      - artifact_of_stage_2.txt

```

### ./project_3/dvc.yaml
```yaml
stages:
  do_p3_s1:
    cmd: python do_stage_1.py 
    outs:
      - artifact_of_stage_1.txt
  do_p3_s2:
    cmd: python do_stage_2.py
    deps:
      - artifact_of_stage_1.txt
    outs:
      - artifact_of_stage_2.txt
  do_p3_s3:
    cmd: python do_stage_3.py
    deps:
      - artifact_of_stage_2.txt
    outs:
      - artifact_of_stage_3.txt
```

### ./project_4/dvc.yaml
```yaml
stages:
  do_p4_s1:
    cmd: python do_stage_1.py
    outs:
      - artifact_of_stage_1.txt
  do_p4_s2:
    cmd: python do_stage_2.py
    deps:
      - artifact_of_stage_1.txt
    outs:
      - artifact_of_stage_2.txt
  do_p4_s3:
    cmd: python do_stage_3.py
    deps:
      - artifact_of_stage_2.txt
    outs:
      - artifact_of_stage_3.txt
  do_p4_s4:
    cmd: python do_stage_4.py
    deps:
      - artifact_of_stage_3.txt
    outs:
      - artifact_of_stage_4.txt

```


---
## monorepo_3
### ./dvc.yaml
```yaml
stages:
  projects:
    foreach: # List of project paths
      - project_1
      - project_2
      - project_3
      - project_4
    do:
      cmd: pushd ${item} && dvc repro && popd

```

### ./project_1/dvc.yaml
```yaml
stages:
  do_p1_s1:
    cmd: python do_stage_1.py
    outs:
      - artifact_of_stage_1.txt

```

### ./project_2/dvc.yaml
```yaml
stages:
  do_p2_s1:
    cmd: python do_stage_1.py
    outs:
      - artifact_of_stage_1.txt
  do_p2_s2:
    cmd: python do_stage_2.py
    deps:
      - artifact_of_stage_1.txt
    outs:
      - artifact_of_stage_2.txt

```

### ./project_3/dvc.yaml
```yaml
stages:
  do_p3_s1:
    cmd: python do_stage_1.py 
    outs:
      - artifact_of_stage_1.txt
  do_p3_s2:
    cmd: python do_stage_2.py
    deps:
      - artifact_of_stage_1.txt
    outs:
      - artifact_of_stage_2.txt
  do_p3_s3:
    cmd: python do_stage_3.py
    deps:
      - artifact_of_stage_2.txt
    outs:
      - artifact_of_stage_3.txt
```

### ./project_4/dvc.yaml
```yaml
stages:
  do_p4_s1:
    cmd: python do_stage_1.py
    outs:
      - artifact_of_stage_1.txt
  do_p4_s2:
    cmd: python do_stage_2.py
    deps:
      - artifact_of_stage_1.txt
    outs:
      - artifact_of_stage_2.txt
  do_p4_s3:
    cmd: python do_stage_3.py
    deps:
      - artifact_of_stage_2.txt
    outs:
      - artifact_of_stage_3.txt
  do_p4_s4:
    cmd: python do_stage_4.py
    deps:
      - artifact_of_stage_3.txt
    outs:
      - artifact_of_stage_4.txt

```


---
## monorepo_4
### ./dvc.yaml
```yaml
stages:
  projects:
    cmd: ./find_and_execute_pipelines.bash

```

### ./project_1/dvc.yaml
```yaml
stages:
  do_p1_s1:
    cmd: python do_stage_1.py
    outs:
      - artifact_of_stage_1.txt

```

### ./project_2/dvc.yaml
```yaml
stages:
  do_p2_s1:
    cmd: python do_stage_1.py
    outs:
      - artifact_of_stage_1.txt
  do_p2_s2:
    cmd: python do_stage_2.py
    deps:
      - artifact_of_stage_1.txt
    outs:
      - artifact_of_stage_2.txt

```

### ./project_3/dvc.yaml
```yaml
stages:
  do_p3_s1:
    cmd: python do_stage_1.py 
    outs:
      - artifact_of_stage_1.txt
  do_p3_s2:
    cmd: python do_stage_2.py
    deps:
      - artifact_of_stage_1.txt
    outs:
      - artifact_of_stage_2.txt
  do_p3_s3:
    cmd: python do_stage_3.py
    deps:
      - artifact_of_stage_2.txt
    outs:
      - artifact_of_stage_3.txt
```

### ./project_4/dvc.yaml
```yaml
stages:
  do_p4_s1:
    cmd: python do_stage_1.py
    outs:
      - artifact_of_stage_1.txt
  do_p4_s2:
    cmd: python do_stage_2.py
    deps:
      - artifact_of_stage_1.txt
    outs:
      - artifact_of_stage_2.txt
  do_p4_s3:
    cmd: python do_stage_3.py
    deps:
      - artifact_of_stage_2.txt
    outs:
      - artifact_of_stage_3.txt
  do_p4_s4:
    cmd: python do_stage_4.py
    deps:
      - artifact_of_stage_3.txt
    outs:
      - artifact_of_stage_4.txt

```
