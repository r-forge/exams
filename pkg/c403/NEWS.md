# c403 0.9-3

* Deprecated legacy interfaces `exams2openolat()`, `exams2nops()`, `nops_eval()`.
  The original functions in the `exams` package have improved substantially
  and the interfaces were not kept up to date. It is hence recommended to
  use the original `exams` functions directly, setting suitable arguments.


# c403 0.9-2

* Add pandoc as system requirement.
* Adapt to changes in `exams` itself, in particular new default UTF-8
  encoding etc.
* Use `openxlsx` (rather than `xlsx`) in more places.


# c403 0.9-1

* Omit old `exams2quiz()` function.
* Updates in `exams2openolat` (qti21test, and less description strings).
* Proper `roxygen2` documentation for `exams2openolat()`.


# c403 0.9-0

* Added this NEWS file.
* Added function `nops_feedback()` to create customized reports
  of nops tests. Currently only tested for single-choice questions
  without attachments (as we have to convert LaTeX > html).
