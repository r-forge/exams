# exams2webexercises 0.1-0

* New R/exams (<https://www.R-exams.org/>) interface for
  documents with [webexercises](https://psyteachr.github.io/webexercises/).

* Currently, there is support for the following question types:

  | Description     | R/exams   | `webexercises`  |
  |:----------------|:----------|:----------------|
  | Single-choice   | `schoice` | `longmcq`/`mcq` |
  | Multiple-choice | `mchoice` | `torf` list     |
  | Numeric         | `num`     | `fitb`          |
  | Text            | `string`  | `fitb`          |

  Thus, there is no support, yet, for `cloze` questions.

* The main function is `exams2webexercises()` which is typically
  used within Rmd documents with `webexercises`.

  - `webexercises_questions.Rmd`: All questions set up indvidually.
  - `webexercises_quiz.Rmd`: An entire quiz set up in one go.

* Additionally, the function `render_quiz()` can be used to
  quickly set up and run a quiz interactively based on a
  set of R/exams exercises. For example:  
  `render_quiz(c("swisscapital.Rmd", "capitals.Rmd", "fruit.Rmd", "function.Rmd"))`
