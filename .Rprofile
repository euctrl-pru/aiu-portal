# in .Rprofile of the website project
if (file.exists("~/.Rprofile")) {
  base::sys.source("~/.Rprofile", envir = environment())
}


options(
  knitr.graphics.error = FALSE,
  blogdown.ext = ".Rmd",
  blogdown.yaml.empty = TRUE,
  blogdown.new_bundle = TRUE,
  blogdown.title_case = TRUE,
  # recompile Rmd on change
  blogdown.knit.on_save = TRUE,
  blogdown.serve_site.startup = FALSE,
  blogdown.publishDir = '../aiu-portal-generated',
  blogdown.hugo.version = "0.92.1"
)
