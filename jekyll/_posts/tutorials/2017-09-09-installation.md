---
layout: page
#
# Content
#
title: "Installing R/exams"
teaser: "Installation guide for R itself and the R package \"exams\" as well as further open-source tools that are required for certain tasks."
categories:
  - tutorials
tags:
  - R
  - RStudio
  - LaTeX
  - Markdown
  - pandoc
author: zeileis

#
# Style
#
image:
  # shown on top of blog post
  title: logo.title.svg
  # preview in list of posts
  thumb: logo.150.svg
  # shown on landing page
  # homepage:
  # shown under image on top of blog post
  caption: "R/exams logo (CC-BY-SA | GPL-2)."
---

## TL;DR

To make full use of R/exams install: [1. R](#1-r) and optionally RStudio and Rtools on Windows, [2. R package "exams"](#2-r-package-exams) and its dependencies, [3. LaTeX](#3-latex) either as a full system tool -- or just `tinytex` from within R, [4. Pandoc](#4-pandoc) (automatically available with RStudio), [5. Ghostscript](#5-ghostscript) (only needed for scanning NOPS exams).

Detailed instructions for all steps are provided in the following sections.


## 1. R

[R/exams](https://www.R-exams.org/) is an extension for the [R system for statistical computing](https://www.R-project.org) and hence the first installation step is the base R system. 

- **Windows and MacOS:** Go to <https://CRAN.R-project.org/>, the Comprehensive R Archive Network (CRAN). Simply click on the link for your operating system and at least install the "base" system.  
   For some tasks (e.g., output for some learning management systems) it is necessary that the base R `zip()` function works. On Windows this requires to install the [Rtools](https://CRAN.R-project.org/bin/windows/Rtools/) and to include them in the PATH environment variable.
- **Linux:** While it is possible to download from CRAN by hand, it is easier for most distributions to install the packaged binary. For example, on Debian/Ubuntu:

  ```{r}
  sudo apt-get install r-base-core r-base-dev
  ```

There is a wide variety of interfaces for using R including simply the shell, Emacs, VS Code, Positron, or dedicated graphical user interfaces for Windows and MacOS, respectively. Moreover, RStudio is an open-source cross-platform integrated development environment that facilitates many common tasks for R beginners.

- **For R beginners:** Go to <https://posit.co/products/open-source/rstudio/> and obtain the "Open Source Edition" of RStudio Desktop.



## 2. R package "exams"

The core of R/exams is the open-source R package ["exams"](https://CRAN.R-project.org/package=exams), also available from CRAN. It can be easily installed -- along with all CRAN packages it depends on -- interactively from within R with a single command. Thus, you can run the first command below in R's command line after starting R (e.g., by starting RStudio or any other user interface selected or by typing `R` on the shell in a terminal window). Subsequently, if desired, the development version of the package can be installed from R-Forge, which may provide some new features or small improvements.

- **Stable version:**

  ```{r}
  install.packages("exams", dependencies = TRUE)
  ```
- **Development version:**

  ```{r}
  install.packages("exams", repos = "https://R-Forge.R-project.org")
  ```
  
  In some setups (e.g., on MacOS or when using an older version of R) it may be necessary to add the argument `type = "source"` to the command above.

_Dependencies:_ Several additional R packages, automatically installed by the command above, are needed for certain tasks: `base64enc` (HTML-based output: Base64 encoding of supplements), `knitr` (R/Markdown-based exercises), `rmarkdown` (pandoc-based conversion), `magick` (converting PDFs into images, e.g., for scanning NOPS exams or TikZ graphics), `openxlsx` (Kahoot: exporting exercises to Excel sheets), `png` (NOPS exams: reading scanned PNG images), `qpdf` (NOPS exams: manipulating scanned PDF sheets), `RCurl` (ARSnova: posting exercises), `RJSONIO` (ARSnova: JSON format), `tinytex` (PDF output: lightweight LaTeX distribution), `tth` (HTML output from R/LaTeX exercises), `xml2` (converting XML from Moodle or Testvision to Rmd exercises).


_System requirements:_ When compiling the packages from source (typically on Linux), several system requirements are needed. For Debian/Ubuntu these can be installed via:

```{r}
sudo apt-get install pandoc libjpeg libpng libmagick++-dev libcurl4-openssl-dev libxml2-dev
```



## 3. LaTeX

For producing PDF output, the typesetting system LaTeX is used internally by R/exams. If no LaTeX distribution (like TeXLive or MikTeX) is already installed, then TinyTeX is a lightweight distribution that can be easily obtained and maintained with the `tinytex` R package (already installed in the step above). TinyTeX can be installed from within R with:

```{r}
tinytex::install_tinytex()
```

_Note:_ When producing the first PDF files with R/exams, `tinytex` will automatically install further required LaTeX packages and hence take somewhat longer to compile.

Instead of TinyTeX it is, of course, also possible to install a full LaTeX distribution, especially if this is not only needed for R/exams. See this [LaTeX blog post]({{ site.url }}/tutorials/latex/) for more details on the relative advantages.

- **Windows:** Go to <http://www.MikTeX.org/> and click on "Download" to obtain the MikTeX distribution for Windows.
- **MacOS and Linux:** LaTeX distributions are available in the standard repositories and can be installed in the "usual" way, typically using the [TeX Live](https://www.tug.org/texlive/) distribution.


## 4. Pandoc

For certain conversions performed internally in R/exams, specifically when Markdown is involved, the universal document converter [pandoc](https://www.pandoc.org/) is employed. If you have installed RStudio, then pandoc is provided along with it and nothing else needs to be done.

Otherwise pandoc can be obtained from its web page (linked above) or standard repositories, e.g., for Debian/Ubuntu:

```{r}
sudo apt-get install pandoc
```


## 5. Ghostscript

_Note:_ Unless you want to process [written NOPS exams]({{ site.url }}/intro/written/) from scanned PDF files, this step can also be skipped.

If the scanned images of written NOPS exams (from your photocopier) are in PDF format, they need to be converted to PNG, by default using the R packages `qpdf` and `magick` (see above). The latter relies on Ghostscript being available on the system path which is usually the case on Linux but might require additional installation on Windows and MacOS.

- **Windows:** <https://www.ghostscript.com/releases/gsdnld.html>.
- **MacOS:** Via Homebrew (https://brew.sh) in the terminal.

  ```{r}
  brew install ghostscript
  ```

- **Linux:** If it is not installed already, install Ghostscript from your distribution, e.g., for Debian/Ubuntu.

  ```{r}
  sudo apt-get install ghostscript
  ```



## Make sure everything works

To check that the software from Steps 1-4 works, try to run some examples from the exercise template gallery, e.g., [dist]({{ site.url }}/templates/dist) or [ttest]({{ site.url }}/templates/ttest). See the [First Steps]({{ site.url }}/tutorials/first_steps/) tutorial for further tips on how to get started.
