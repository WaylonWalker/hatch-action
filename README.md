This action bumps [hatch](https://hatch.pypa.io/latest/version/) hatch
projects.  This is pretty rigidly setup for my workflow, and is not likely to
work for everyone.  If you want something different, fork it and make it work
for you.

## Example usage

``` yaml
- uses: waylonwalker/hatch-version-action
```

## Example project

I made an [example project](https://github.com/WaylonWalker/hatch-version-action-example/actions/workflows/main.yml) with `hatch new` and added this example workflow.

``` yaml
name: Use hatch-version-action

on:
  push:
    branches: [ "*" ]

  workflow_dispatch:

env:
  HATCH_INDEX_USER: __token__
  HATCH_INDEX_AUTH: ${{ secrets.pypi_token }}

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
      - uses: waylonwalker/hatch-action@v1
        with:
          before-command: "test-lint"
```

## Example Runs

Here is what  some runs using this action look like.

* [🟢 Example Good Run](https://github.com/WaylonWalker/hatch-version-action-example/actions/runs/2975837348)
* [🔴 Example flake8 Error](https://github.com/WaylonWalker/hatch-version-action-example/actions/runs/2975842403)
* [🔴 Example pytest failure](https://github.com/WaylonWalker/hatch-version-action-example/actions/runs/2975846813)
* [🔴 Example missing dependency](https://github.com/WaylonWalker/hatch-version-action-example/actions/runs/2975866133)

## Publishing

You will need to get a token, and upload it to your projects secrets, and pass it in as the `HATCH_INDEX_AUTH` env variable.
