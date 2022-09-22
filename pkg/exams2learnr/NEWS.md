# exams2learnr 0.1-0

* New R/exams (<https://www.R-exams.org/>) interface for
  [learnr](https://rstudio.github.io/learnr/) tutorials.

* Currently, there is support for the following question types:

  | Description     | R/exams   | `learnr`                                                            |
  |:----------------|:----------|:--------------------------------------------------------------------|
  | Single-choice   | `schoice` | `learnr_radio`                                                      |
  | Multiple-choice | `mchoice` | `learnr_checkbox`                                                   |
  | Text            | `string`  | `learnr_text`                                                       |
  | Numeric         | `num`     | `learnr_numeric` (if version > 0.10.1) or `learnr_text` (otherwise) |

  Thus, there is no support, yet, for cloze questions. And
  note that in `learnr` versions up to 0.10.1 numeric questions are processed
  as text, i.e., without correct handling of tolerances.
