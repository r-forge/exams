if (!file.exists(file.path(getwd(), "appdata")))
  dir.create(file.path(getwd(), "appdata"))

owd = paste0(getwd(), "/appdata")

if (!file.exists(file.path(owd, "zzz")))
  dir.create(file.path(owd, "zzz"))
if (!file.exists(file.path(owd, "exercises"))) {
  dir.create(file.path(owd, "exercises"))
} else {
  ex <- dir(file.path(owd, "exercises"), full.names = TRUE, recursive = TRUE)
  file.remove(ex)
}
if (!file.exists(file.path(owd, "tmp"))) {
  dir.create(file.path(owd, "tmp"))
} else {
  tf = dir(file.path(owd, "tmp"), full.names = TRUE)
  unlink(tf)
}
if (!file.exists(file.path(owd, "exams"))) {
  dir.create(file.path(owd, "exams"))
} else {
  tf = dir(file.path(owd, "exams"), full.names = TRUE)
  unlink(tf)
}

directories = reactiveValues(
  tmp = file.path(owd, "tmp"),
  exercises = file.path(owd, "exercises"),
  www = file.path(owd, "zzz"),
  exams = file.path(owd, "exams"),
  pkg_ex = file.path(find.package("exams"), "exercises")
)

# 
# 
# 
# # file.path(find.package("exams"), "exercises")
# 
# 
# 
# writeLines(chooser.js, file.path(dir, "zzz", "chooser-binding.js"))
# registerInputHandler("shinyjsexamples.chooser", function(data, ...) {
#   if (is.null(data))
#     NULL
#   else
#     list(
#       questions = as.character(data$questions),
#       left = as.character(data$left),
#       right = as.character(data$right)
#     )
# }, force = TRUE)
# 
# 
# 
# 
# 
# 
# #### general helpers ####
# pasteDot = function(...) {
#   paste(..., sep = ".")
# }
# 
# writeBold = function(chr) {
#   tags$b(chr)
# }
# 
# makeInfoDescription = function(header, body, width, inline = TRUE) {
#   if (inline) {
#       column(width = width, align = "center", div(class = "padded-text", h5(body)))
#   } else {
#     column(width = width, align = "center", writeBold(header), h5(body))
#   }
# }
# 
# #### error handlers ####
# errAsString = function(err) {
#   err$message
# }
# 
# #### needy functions ####
# 
# reqAndAssign = function(obj, name) {
#   req(obj)
#   assign(name, obj, pos = 1L)
# }
# 
# 
# helpBox = function(content) {
#   div(class = "helptext",
#     box(width = 12, status = "warning", collapsible = TRUE,
#       span(icon("info-circle")), span(content)
#     )
#   )
# }
