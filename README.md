# RaukR 2026 • Workshop Website  [![ci_badge](https://github.com/nbisweden/raukr-2026/workflows/deploy/badge.svg)](https://github.com/nbisweden/raukr-2026/actions?workflow=deploy)  
**NBIS Summer School • Data Science With R**  

## Environment

To edit, preview, and render documents, you need the following prerequisites:

- [Quarto\>=1.8.27](https://quarto.org/docs/download/)
- RStudio [v2025.09.2 or newer](https://posit.co/download/rstudio-desktop/) or [Positron](https://positron.posit.co/) or [VS Code](https://arinbasu.medium.com/why-quarto-with-vscode-is-a-great-data-science-tool-f0a259d28702)
- You need to install the R packages necessary for your topic/document

## Quick start

- Fork/clone the repository
- Install Quarto and required R packages
- Preview: `quarto preview`
- Render: `quarto render`
- Commit changes and send a pull request

## Adding or Modifying Topics

- Fork/Clone the repository
- If your topic doesn't exist, create a branch from `develop` branch and add your topic
- Keep the topic name simple, preferably one word
- To add a **topic**, create
  - **slides/topic/index.qmd**
  - **labs/topic/index.qmd**
  - The YAML metadata should minimally look like this:

    ```         
    ---
    title: "Topic"
    author: "Author"
    description: "This topic covers this and that."
    format: html
    ---
    ```

- `format` must be `html` for reports and `revealjs` for presentations
- For assets relating to the document (figures, files etc), create an **assets** folder
  - **slides/topic/assets/**
  - **labs/topic/assets/**

:bulb: The document can be live previewed to view changes. Preview is automatically updated on saving the document. Sometimes, the preview can look a bit wonky, in which case, cancel and rerun.

- To preview, run in terminal
  - `quarto preview`
  - Saving the file updates the preview

- To render, run in terminal
  - `quarto render`
  - Rendered files are written to **/docs**
  - To view in browser, open
    - **docs/slides/topic/index.html**
    - **docs/labs/topic/index.html**

:tip: Rendered documents in **docs/** are only for local preview and are excluded from git. The HTML files for the website are rendered by GitHub Actions. Make sure to commit the **_freeze/** folder. We use freeze to cache chunks so rendering works without the original environment on GitHub Actions.

- Finally commit changes

```
git add .
git commit -m "Added topic"
```

- Pull latest changes from the repo or from main branch to your branch
- Optionally, merge your branch to develop branch
- Resolve conflicts as needed
- Push your branch or the develop branch and send a pull request like one of the options below

```
nbisweden/raukr-2026:main <- nbisweden/raukr-2026:your-branch
nbisweden/raukr-2026:main <- you/raukr-2026:your-branch
nbisweden/raukr-2026:main <- nbisweden/raukr-2026:develop
nbisweden/raukr-2026:main <- you/raukr-2026:develop
```

## Branches

- `main` - Finalized material for the workshop website
- `develop` - Work in progress including above and working slides and labs
- `<topic>` - Individual topic branches for development

## Tips & Conventions

- Be selective about packages used. Drop packages and dependencies that are not crucial
- Opt for packages with fewer dependencies
- For compute heavy steps, save intermediates and read them in
- Be mindful of the size of files
  - Store large data files elsewhere (dropbox, google drive etc) and link them
  - If you have images that are more than a few hundred KB in size, scale them down to about 600px-800px and [compress](https://compressjpeg.com/) them and/or use more efficient formats like webp
- Use simple topic labels and do not make them needlessly complex
- The qmd files must be in the correct location when rendering/previewing else metadata from config is not used. 
- Declare all R packages at the beginning of every qmd document
- qmd files must have a format defined, either **format: html** or **format: revealjs**
- Make a note of the default **execute** settings in `_quarto.yml`. This applies to all documents. You can override this by copying the code below to the yaml part of your document and modifying it.

  ```
  execute:
    eval: true
    echo: false
  ```
  
- Use level 2 heading (##) as the highest level heading
- Bullet points are defined by `-`
- Define options in code chunks using `#|` like `#| echo: true`
- Adjusting dimension of images `![Caption](path/to/image.jpg){width="50%"}`
- Divs are defined using `:::` and classes are defined using `{.class}`
  - Example of a class on a div
  
  ```
  ::: {.callout-note}
  content
  :::
  ```
- Example of a class on a span `[Content]{.class}`
- Columns are defined as such

```
:::: {.columns}
::: {.column width="50%"}
Contents
:::
::: {.column width="50%"}
Contents
:::
::::
```

- Remember to spell-check your document
  - Language used is en-us

- To view a demo report, click [here](https://nbisweden.github.io/raukr-2026/labs/demo/)

### Reveal.js (Slides)

These are slide specific info. Comparisons here are to xaringan used previously for RaukR.

- Slides are defined by H2 title (`##`) rather than `---`
- Manual increment is defined by `. . .` rather than `--`
- Horizontal rule is defined by `---` rather than `***`
- Presenter notes are defined by `:::{.notes} content :::` rather than `???`
- For small notes in the bottom of the slide, you can use

```
::: {.aside}
Contents
:::
```

- To view a demo presentation, click [here](https://nbisweden.github.io/raukr-2026/slides/demo/)

## Quarto extensions

Quarto extensions in use:

```bash
# Fontawesome icons
quarto add quarto-ext/fontawesome
# Accordion layout
quarto add royfrancis/quarto-accordion
# Top logos in revealjs slides
quarto add royfrancis/quarto-reveal-logo
```

---

**2026** • NBIS • SciLifeLab

