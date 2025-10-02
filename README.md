<p align="center">
  <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=600&size=28&duration=2600&pause=700&center=true&vCenter=true&multiline=true&width=980&height=90&lines=Data+Analysis+with+R;Clean+%E2%80%A2+Trustworthy+%E2%80%A2+Beautiful+Visuals" alt="Typing banner" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/R-%3E%3D4.3-276DC3" />
  <img src="https://img.shields.io/badge/tidyverse-ready-brightgreen" />
  <img src="https://img.shields.io/badge/ggplot2-plots-success" />
  <img src="https://img.shields.io/badge/renv-reproducible-informational" />
  <img src="https://img.shields.io/badge/Quarto-reporting-blueviolet" />
  <img src="https://img.shields.io/badge/License-MIT-lightgrey" />
</p>

<p align="center">
  <img src="https://media.giphy.com/media/xT9IgzoKnwFNmISR8I/giphy.gif" width="520" alt="data animation" />
</p>

---

## 🚀 Overview

This repository delivers a **reproducible R pipeline** that takes a raw business dataset, **cleans it to analytics‑grade quality**, and generates **clear visualizations** for decision‑making. It’s built for fast iteration, auditability, and handoff to non‑dev teams.

> TL;DR: Load → Clean → Validate → Visualize → Share a report. All steps scripted and repeatable.

---

## ✨ What’s inside

* 🧹 **Data cleaning** with `dplyr`, `tidyr`, `janitor`, and `lubridate` (nulls, types, outliers, duplicates, naming).
* ✅ **Data quality checks** (row counts, unique keys, business rules) with a compact summary table.
* 📊 **Visualization gallery** using `ggplot2` (and optional interactive `plotly`).
* 📓 **Auto‑generated report** (Quarto/R Markdown) with narrative + charts for stakeholders.
* ♻️ **Reproducible environment** via `renv` so results are consistent across machines.
* 🗂️ **Modular scripts** for easy reuse in new datasets or future updates.

---

## 🧭 Repository structure

```
.
├─ README.md
├─ renv.lock                 # reproducible R package versions
├─ .Rprofile                 # auto-activate renv
├─ data/
│  ├─ raw/                   # raw CSVs/Excels (gitignored)
│  ├─ interim/               # intermediate files (gitignored)
│  └─ clean/                 # cleaned outputs (gitignored)
├─ scripts/
│  ├─ 01_load.R              # load raw data
│  ├─ 02_clean.R             # cleaning + feature fixes
│  ├─ 03_validate.R          # data quality checks
│  ├─ 04_visualize.R         # generate figures
│  └─ utils.R                # helper functions
├─ reports/
│  └─ eda.qmd                # Quarto report (render to HTML/PDF)
├─ figs/                     # exported charts
└─ .gitignore
```

> Tip: keep `data/raw` and `data/clean` out of version control. Only push scripts, figures, and reports.

---

## ⚙️ Quickstart

### 1) Restore environment

```r
install.packages("renv")
renv::restore()
```

### 2) Configure dataset path

Edit `scripts/01_load.R` with your file path, example:

```r
raw_path <- "data/raw/transactions.csv"  # or .xlsx
```

### 3) Run the pipeline

```r
source("scripts/01_load.R")
source("scripts/02_clean.R")
source("scripts/03_validate.R")
source("scripts/04_visualize.R")
```

### 4) Render the report

```bash
# if you have Quarto installed
quarto render reports/eda.qmd --to html
```

The report will appear in `reports/eda.html` with charts and summary
