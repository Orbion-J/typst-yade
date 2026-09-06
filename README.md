# The `yade` Package
<div align="center">Version 0.0.1</div>

This package allows to include diagrams made with the [yade](https://amblafont.github.io/graph-editor-web/index.html) diagram editor in your Typst documents.


## Template adaptation checklist

- [ ] Fill out `README.md`
  - Change the `my-package` package name, including code snippets
  - Check section contents and/or delete sections that don't apply
- [ ] Check and/or replace `LICENSE` by something that suits your needs
- [ ] Fill out `typst.toml`
  - See also the [typst/packages README](https://github.com/typst/packages/?tab=readme-ov-file#package-format)
- [ ] Adapt Repository URLs in `CHANGELOG.md`
  - Consider only committing that file with your first release, or removing the "Initial Release" part in the beginning
- [ ] Adapt or deactivate the release workflow in `.github/workflows/release.yml`
  - to deactivate it, delete that file or remove/comment out lines 2-4 (`on:` and following)
  - to use the workflow
    - [ ] check the values under `env:`, particularly `REGISTRY_REPO`
    - [ ] if you don't have one, [create a fine-grained personal access token](https://github.com/settings/tokens?type=beta) with [only Contents permission](https://stackoverflow.com/a/75116350/371191) for the `REGISTRY_REPO`
    - [ ] on this repo, create a secret `REGISTRY_TOKEN` (at `https://github.com/[user]/[repo]/settings/secrets/actions`) that contains the so created token

    if configured correctly, whenever you create a tag `v...`, your package will be pushed onto a branch on the `REGISTRY_REPO`, from which you can then create a pull request against [typst/packages](https://github.com/typst/packages/)
- [ ] remove this section from the README

## Usage

NOTE: This package is not yet on the Universe. Install it locally to use it.

NOTE: This package depends on `fletcher` v0.6.0, available on the `dev` branch of `fletcher`'s Github repository. Make `fletcher` to be accessible under `@local/fletcher:0.6.0` in order to use `yade`.

Import `yade` with

```typ
#import "@local/yade:0.0.1" as yade
```

This exposes 3 functions:
- `yade.diagram`
- `yade.yade`
- `yade.nodes_and_edges`

There are three ways of importing a yade diagram in your document.

### Via an external file 

Save your diagram in a file `path/to/my/diagram.yade`

Import it with 

```typ
#yade.diagram(path("path/to/my/diagram.yade"))
```

### Directly in your document 

#### One diagram at a time

Copy the yade diagram and paste it in a raw environment. Apply the `diagram` function on it.

```typ
#yade.diagram(\`\`\`
{"graph":{"activeTabId":0,"latexBackgroundColor":"white","latexPreamble":"\\newcommand{\\coqproof}[1]{\\checkmark}","nextTabId":1,"tabs":[{"edges":[{"from":0,"id":4,"label":{"label":"h","options":{},"zindex":0},"to":1},{"from":2,"id":5,"label":{"label":"f","options":{},"zindex":0},"to":3},{"from":0,"id":6,"label":{"label":"k","options":{"alignment":"right"},"zindex":0},"to":2},{"from":1,"id":7,"label":{"label":"g","options":{},"zindex":0},"to":3}],"freehandDrawings":[],"id":0,"nextGraphId":8,"nodes":[{"id":0,"label":{"label":"A","options":{},"pos":[533,117],"zindex":0}},{"id":1,"label":{"label":"B","options":{},"pos":[611,117],"zindex":0}},{"id":2,"label":{"label":"C","options":{},"pos":[585,195],"zindex":0}},{"id":3,"label":{"label":"D","options":{},"pos":[663,195],"zindex":0}}],"sizeGrid":26,"title":"1"}]},"version":20}
\`\`\`)
```

#### With a show rule

Use the `yade` function in a show rule to make all raw environments tagged with language `yade` into diagrams.

```typ
#show yade.yade

\`\`\`yade
{"graph":{"activeTabId":0,"latexBackgroundColor":"white","latexPreamble":"\\newcommand{\\coqproof}[1]{\\checkmark}","nextTabId":1,"tabs":[{"edges":[{"from":0,"id":4,"label":{"label":"h","options":{},"zindex":0},"to":1},{"from":2,"id":5,"label":{"label":"f","options":{},"zindex":0},"to":3},{"from":0,"id":6,"label":{"label":"k","options":{"alignment":"right"},"zindex":0},"to":2},{"from":1,"id":7,"label":{"label":"g","options":{},"zindex":0},"to":3}],"freehandDrawings":[],"id":0,"nextGraphId":8,"nodes":[{"id":0,"label":{"label":"A","options":{},"pos":[533,117],"zindex":0}},{"id":1,"label":{"label":"B","options":{},"pos":[611,117],"zindex":0}},{"id":2,"label":{"label":"C","options":{},"pos":[585,195],"zindex":0}},{"id":3,"label":{"label":"D","options":{},"pos":[663,195],"zindex":0}}],"sizeGrid":26,"title":"1"}]},"version":20}
\`\`\`)
```

### With Fletcher

Use the `nodes_and_edges` function to get the lists of `fletcher` nodes and edges. You can then insert them into a `fletcher` canvas and use fletcher to customize your diagram. Each node/edge is referencable with it's id number `<id>`.

```typ
#import "@local/fletcher:0.6.0" as fletcher

#let NnE = nodes_and_edges(\`\`\`yade
{"graph":{"activeTabId":0,"latexBackgroundColor":"white","latexPreamble":"\\newcommand{\\coqproof}[1]{\\checkmark}","nextTabId":1,"tabs":[{"edges":[{"from":0,"id":4,"label":{"label":"h","options":{},"zindex":0},"to":1},{"from":2,"id":5,"label":{"label":"f","options":{},"zindex":0},"to":3},{"from":0,"id":6,"label":{"label":"k","options":{"alignment":"right"},"zindex":0},"to":2},{"from":1,"id":7,"label":{"label":"g","options":{},"zindex":0},"to":3}],"freehandDrawings":[],"id":0,"nextGraphId":8,"nodes":[{"id":0,"label":{"label":"A","options":{},"pos":[533,117],"zindex":0}},{"id":1,"label":{"label":"B","options":{},"pos":[611,117],"zindex":0}},{"id":2,"label":{"label":"C","options":{},"pos":[585,195],"zindex":0}},{"id":3,"label":{"label":"D","options":{},"pos":[663,195],"zindex":0}}],"sizeGrid":26,"title":"1"}]},"version":20}
\`\`\`)

#fletcher.diagram(..NnE)
```

<picture>
  <!-- <source media="(prefers-color-scheme: dark)" srcset="./thumbnail-dark.svg"> -->
  <img src="./tests/misc/path.svg">
</picture>

## Dependancy

This package depends on
- `fletcher` v0.6.0
- `cetz` v0.4.2 (via `fletcher`)
- `mitex` v0.2.6

## Known issues

- some bend arrows do not snap
- pullback arrows scale
