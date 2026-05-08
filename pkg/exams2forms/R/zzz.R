.onAttach <- function(lib, pkg) {
  if(interactive()) {
    packageStartupMessage(
      "You have installed the 'exams2forms' package (version 0.2-1) from R-Forge.\n",
      "Newer versions of the package can be installed from R-universe via\n",
      "install.packages(\"exams2forms\", repos = \"https://zeileis.R-universe.dev\")\n",
      "The source code is hosted now at https://codeberg.org/zeileis/exams2forms")
  }
}
