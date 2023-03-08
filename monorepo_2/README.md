# Using `-P` or `--all-pipelines`

For this example you can run `dvc exp run -P` or `dvc repro -P` to execute all pipelines within you mono repro. This is possible because dvc was intitialized at the root level of your repo. If you initialized dvc indivially in each of your `project_*` then something like what you initially had here would be required.

----

You can also establish inter project dependenices, see my edit or `project_4`'s dvc pipeline. 