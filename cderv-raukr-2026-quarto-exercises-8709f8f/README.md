# RaukR 2026 · Quarto — exercises

Hands-on files for Christophe Dervieux's two Quarto sessions at **RaukR 2026** (Advanced R for
Bioinformatics, Visby): *Introduction to Quarto* (Mon 10 Aug) and *Quarto projects* (Tue 11 Aug).
One download covers **both** days. No Git or GitHub account needed.

> **This folder is generated.** A sync script assembles it from the course repo
> [`cderv/raukr-2026-quarto`](https://github.com/cderv/raukr-2026-quarto). Do not hand-edit it here.
> Edits are overwritten on the next sync. File issues on the course repo.

## Get the files

In R, set your working directory to the folder where you want the materials. Then run one line of R:

```r
# install.packages("usethis")
usethis::use_course("cderv/raukr-2026-quarto-exercises", destdir = ".")
```

Answer **No** when it offers to delete the ZIP. Keep it so you can reset the files (see below). No R?
Download the ZIP in a browser from the green **Code ▸ Download ZIP** button and unzip it.

## Open the right folder

Work from the day folder for the session:

- **Day 1** → `day1-intro/`
- **Day 2** → `day2-projects/`

Use *File ▸ Open Folder…* in Positron or VS Code, or double-click the `.Rproj` inside the folder in
RStudio. Either route opens the day folder as your workspace.

Each day folder is self-contained. Rendered files are written next to their source files.

## Check your setup (do this once, before Day 1)

From this top folder, run the setup check. It verifies R, Quarto, the packages, and the data, then
renders the Day-1 Typst sample. This downloads and caches the brand fonts before the session:

```r
source("00-check-setup.R", local = new.env())
```

Packages, if you need them:

```r
install.packages(c(
  "dplyr", "ggplot2", "ggrepel", "gt", "ggokabeito",
  "brand.yml", "prismatic", "knitr", "rmarkdown"))
```

## What's here

| Path | What it is |
|---|---|
| `day1-intro/` | Day-1 working folder with the starter and checkpoint files, optional parameters exercise, Typst sample, and citation and brand assets. See its README for details. |
| `day2-projects/` | Day-2 working folder with four pages that render on their own but are **not yet a project**. The exercise adds `_quarto.yml`, so that file is intentionally absent. |
| `solutions/` | Reference solutions for both days. Try the exercise yourself first. |
| `00-check-setup.R` | Setup check and Typst font download. |

## Reset (no Git needed)

If an attempt goes wrong, get a **fresh folder** (don't extract over your working copy):

- Re-run the `use_course()` line above (with `destdir = "."`). Each download unpacks into its own
  versioned folder, so your old attempt is untouched.
- Or unzip the ZIP you kept to a **new** location.

## Reuse

Instructor reusing this? It's a **template repository** — click **Use this template** for your own
copy. License: content CC BY 4.0.
