.onAttach <- function(lib, pkg) {
  if(interactive()) {
    packageStartupMessage(
      "You have installed the 'c403' package (version 0.9-4) from R-Forge.\n",
      "Newer versions of the package can be installed from R-universe via\n",
      "install.packages(\"c403\", repos = \"https://zeileis.R-universe.dev\")\n",
      "The source code is hosted now at https://codeberg.org/zeileis/c403")
  }
}
