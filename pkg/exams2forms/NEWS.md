# exams2forms 0.1-1

* Based on the package vignette, the R/exams web page has a tutorial
  for `exams2forms`: <https://www.R-exams.org/tutorials/exams2forms/>.
  
* Some small improvements in `webex.css` and `webex.js` so that
  `exams2forms` output also renders correctly in jekyll projects,
  in particular with the feeling responsive theme used on
  <https://www.R-exams.org/>.
  
* All exercise template pages on the R/exams web page now feature an
  interactive preview with three random variations of each exercise.
  See <https://www.R-exams.org/templates/boxplots/> or
  <https://www.R-exams.org/templates/lm2/> for two examples.

* The function `exams2forms()` as well as all underlying `forms_*()`
  functions gained an argument `obfuscate = TRUE` which provides some
  basic obfuscation of the correct answers for all forms in the
  underlying HTML code. Thus, all correct answers are still stored in
  the HTML but they are not easily readable anymore.

* In the answer lists of single- and multiple-choice exercises
  apostrophes are no longer escaped by `forms_schoice()` and
  `forms_mchoice()` so that expressions like $f'(x)$ render correctly.


# exams2forms 0.1-0

* New R/exams (<https://www.R-exams.org/>) interface for
  embedding exercises as (interactive) forms in R/Markdown or
  Quarto documents.

* For an introduction see the package vignette:

  `vignette("exams2forms", package = "exams2forms")`

* The idea and original code for inserting interactions into
  R/Markdown documents along with CSS and Javascript is adapted from
  the [webexercises](https://psyteachr.github.io/webexercises/) package,
  authored by Dale Barr and Lisa DeBruine.

* The main function is `exams2forms()` which is typically
  used within R/Markdown or Quarto documents. The package provides two
  demo documents.

  - `questions.Rmd`: All questions set up indvidually.
  - `quiz.Rmd`: An entire quiz set up in one go.

* Additionally, the function `exams2webquiz()` can be used to quickly
  set up and render a quiz document interactively based on a set of
  R/exams exercises. For example:  

  `exams2webquiz(c("swisscapital.Rmd", "capitals.Rmd", "fruit.Rmd", "function.Rmd", "lm2.Rmd"))`
