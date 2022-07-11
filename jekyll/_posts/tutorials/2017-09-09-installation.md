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

## 1. R

[R/exams](https://www.R-exams.org/) is an extension for the [R system for statistical computing](https://www.R-project.org) and hence the first installation step is the base R system. 

- **Windows and (Mac) OS X:** Go to <https://CRAN.R-project.org/>, the Comprehensive R Archive Network (CRAN). Simply click on the link for your operating system and at least install the "base" system.  
   For some tasks (e.g., output for some learning management systems) it is necessary that the base R `zip()` function works. On Windows this requires to install the [Rtools](https://CRAN.R-project.org/bin/windows/Rtools/) and to include them in the PATH environment variable.
- **Linux:** While it is possible to download from CRAN by hand, it is easier for most distributions to install the packaged binary. For example, on Debian/Ubuntu:

  ```{r}
  apt-get install r-base-core r-base-dev
  ```

There is a wide variety of interfaces for using R including simply the shell, Emacs, or dedicated graphical user interfaces for Windows and OS X, respectively. Moreover, RStudio is an open-source cross-platform integrated development environment that facilitates many common tasks for R beginners.

- **For R beginners:** Go to <https://www.RStudio.com/products/RStudio/> and obtain the "Desktop" version of RStudio (Open Source Edition).



## 2. R package "exams"

The core of R/exams is the open-source R package ["exams"](https://CRAN.R-project.org/package=exams), also available from CRAN. It can be easily installed interactively from within R with a single command. If necessary, the development version of the package is also available, which may provide some new features or small improvements.

- **Stable version:**

  ```{r}
  install.packages("exams", dependencies = TRUE)
  ```
- **Development version:**

  ```{r}
  install.packages("exams", repos = "http://R-Forge.R-project.org")
  ```

_Details:_ Several additional R packages, automatically installed by the command above, are needed for certain tasks: `base64enc` (HTML-based output: Base64 encoding of supplements), `knitr` (R/Markdown-based exercises), `magick` (turning LaTeX output into images, e.g., for TikZ graphics), `png` (NOPS exams: reading scanned PNG images), `RCurl` (ARSnova: posting exercises), `RJSONIO` (ARSnova: JSON format), `rmarkdown` (pandoc-based conversion), `tinytex` (PDF output: lightweight LaTeX distribution), `tth` (HTML output from R/LaTeX exercises).



## 3. LaTeX

For producing PDF output, the typesetting system LaTeX is used internally by R/exams. If no LaTeX distribution (like TeXLive or MikTeX) is already installed, then TinyTeX is a lightweight distribution that can be easily obtained and maintained with the `tinytex` R package (already installed in the step above). TinyTeX can be installed from within R with:

```{r}
tinytex::install_tinytex()
```

_Note:_ When producing the first PDF files with R/exams, `tinytex` will automatically install further required LaTeX packages and hence take somewhat longer to compile.

Instead of TinyTeX it is, of course, also possible to install a full LaTeX distribution, especially if this is not only needed for R/exams. See this [LaTeX blog post]({{ site.url }}/tutorials/latex/) for more details on the relative advantages.

- **Windows:** Go to <http://www.MikTeX.org/> and click on "Download" to obtain the MikTeX distribution for Windows.
- **(Mac) OS X and Linux:** LaTeX distributions are available in the standard repositories and can be installed in the "usual" way, typically using the [TeX Live](https://www.tug.org/texlive/) distribution.


## 4. Pandoc

For certain conversions performed internally in R/exams, specifically when Markdown is involved, the universal document converter [pandoc](https://www.pandoc.org/) is employed. If you have installed RStudio, then pandoc is provided along with it and nothing else needs to be done.

Otherwise pandoc can be obtained from its web page (linked above) or standard repositories, e.g., for Debian/Ubuntu:

```{r}
apt-get install pandoc
```


## Optional: Further scanning tools

_Note:_ Unless you want to process [written NOPS exams]({{ site.url }}/intro/written/) from scanned PDF files, this section can be skipped.

If the scanned images of written NOPS exams (from your photocopier) are in PDF format, they need to be converted to PNG first using the PDF Toolkit `pdftk` and ImageMagick's `convert`.

- **Windows:** Install PDFTk Free, ImageMagick, and Ghostscript.
  - <https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/pdftk_free-2.02-win-setup.exe>
  - <https://www.imagemagick.org/script/download.php#windows>
  - <https://www.ghostscript.com/releases/gsdnld.html>
  - _Note:_ During the installation of PDFTk and ImageMagick check the boxes for 
    "Add application directory to your environmental path" or
    "Add application directory to your System Path", respectively.
- **(Mac) OS X:** Install MacPorts, PDFTk Free, and ImageMagick.
  - <https://www.macports.org/>
  - <https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/pdftk_server-2.02-mac_osx-10.11-setup.pkg>
  - <https://www.imagemagick.org/script/download.php#macosx>
  - _Note:_ ImageMagick requires MacPorts which in turn automatically installs Ghostscript as a dependency.
    The PDFTk version is for OS X 10.11 up to 10.13 (High Sierra).
- **Linux:** Install PDFTk and ImageMagick from your distribution, e.g., for Debian/Ubuntu:

  ```{r}
  apt-get install pdftk imagemagick
  ```



## Make sure everything works

To check that the software from Steps 1-4 works, try to run some examples from the exercise template gallery, e.g., [dist]({{ site.url }}/templates/dist) or [ttest]({{ site.url }}/templates/ttest). See the [First Steps]({{ site.url }}/tutorials/first_steps/) tutorial for further tips on how to get started.
