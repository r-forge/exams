
olat_eval_lang <- utils::read.table("olat_eval_lang.csv",
                                    header = TRUE,
                                    sep = ",", strip.white = TRUE,
                                    stringsAsFactors = FALSE)
library("devtools")
use_data(olat_eval_lang, overwrite = TRUE)

