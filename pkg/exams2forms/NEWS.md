# exams2forms 0.1-0

* New R/exams (<https://www.R-exams.org/>) interface for
  embedding exercises as (interactive) forms in R/Markdown or
  Quarto documents.

* The idea and original code for inserting interactions into
  R/Markdown documents along with CSS and Javascript is adapted from
  the [webexercises](https://psyteachr.github.io/webexercises/) package,
  authored by Dale Barr and Lisa DeBruine.

* The main function is `exams2forms()` which is typically
  used within R/Markdown or Quarto documents. The package provides two
  demo documents.

  - `questions.Rmd`: All questions set up indvidually.
  - `quiz.Rmd`: An entire quiz set up in one go.

* Additionally, the function `exams2webquiz()` can be used to
  quickly set up and run a quiz interactively based on a
  set of R/exams exercises. For example:  
  `exams2webquiz(c("swisscapital.Rmd", "capitals.Rmd", "fruit.Rmd", "function.Rmd", "lm.Rmd"))`
