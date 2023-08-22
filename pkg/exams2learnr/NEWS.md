# exams2learnr 0.1-1

* Handle the case with `run_quiz(..., dir = NULL, edir = NULL)`
  better: `edir` is set to the current working directory so that
  local exercise files are found when using a temporary `dir`.


# exams2learnr 0.1-0

* New R/exams (<https://www.R-exams.org/>) interface for
  [learnr](https://rstudio.github.io/learnr/) tutorials.

* Currently, there is support for the following question types:

  | Description     | R/exams   | `learnr`          |
  |:----------------|:----------|:------------------|
  | Single-choice   | `schoice` | `learnr_radio`    |
  | Multiple-choice | `mchoice` | `learnr_checkbox` |
  | Numeric         | `num`     | `learnr_numeric`  |
  | Text            | `string`  | `learnr_text`     |

  Thus, there is no support, yet, for `cloze` questions.

* The main function is `exams2learnr()` which is typically
  used within `learnr` Rmd tutorials. For a single exercise
  the function returns a `learnr` `tutorial_question` and
  for several exercises it yields a `learnr` `tutorial_quiz`.
  Both usages are illustrated by two example files provided
  within the package.

  - `learnr_questions.Rmd`: All questions set up indvidually.
  - `learnr_quiz.Rmd`: An entire quiz set up in one go.

* Additionally, the function `run_quiz()` can be used to
  quickly set up and run a quiz interactively based on a
  set of R/exams exercises. For example:  
  `run_quiz(c("capitals.Rmd", "fruit.Rmd", "function.Rmd"))`
