# exams2webexercises 0.1-1

* Development of the exams2webexercises package is discontinued. An improved
  package that directly incorporates an enhanced and customized version of the
  webexercises functionality is available in exams2forms. See:
  <https://www.R-exams.org/tutorials/exams2webexercises/>


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
  | Cloze           | `cloze`   | Combinations of the above |

* The main function is `exams2webexercises()` which is typically
  used within Rmd or Quarto documents with `webexercises`. The
  package provides two demo documents.

  - `webexercises_questions.Rmd`: All questions set up indvidually.
  - `webexercises_quiz.Rmd`: An entire quiz set up in one go.

* Additionally, the function `render_quiz()` can be used to
  quickly set up and run a quiz interactively based on a
  set of R/exams exercises. For example:  
  `render_quiz(c("swisscapital.Rmd", "capitals.Rmd", "fruit.Rmd", "function.Rmd", "lm.Rmd"))`
