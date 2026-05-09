## ============================================================
## data-raw/build_dictionary.R
##
## Run this script once (from the package root) to convert the
## CSV dictionary into the R data object shipped with the package.
##
## Usage (from package root):
##   source("data-raw/build_dictionary.R")
## Or via devtools:
##   devtools::source_file("data-raw/build_dictionary.R")
## ============================================================

library(data.table)

## ---- 1. Build MDE dictionary -----------------------------------------------
csv_path <- "data-raw/mde-dictionary.csv"
if (!file.exists(csv_path)) {
  stop("CSV not found at: ", csv_path,
       "\nPlace mde-dictionary.csv in the data-raw/ folder and re-run.")
}

mde_dictionary <- data.table::fread(
  csv_path,
  colClasses = list(character = c("token", "dimension"))
)
mde_dictionary[, token     := trimws(tolower(token))]
mde_dictionary[, dimension := trimws(tolower(dimension))]

expected_dims <- c("sensory", "affect", "behavioral", "social", "intellectual")
bad <- unique(mde_dictionary[!dimension %in% expected_dims, dimension])
if (length(bad) > 0L) {
  warning("Unexpected dimension value(s) found and kept as-is: ",
          paste(bad, collapse = ", "))
}
data.table::setkey(mde_dictionary, token)

message("MDE dictionary built:")
print(table(mde_dictionary$dimension))
message("Total: ", nrow(mde_dictionary), " tokens")

usethis::use_data(mde_dictionary, overwrite = TRUE)
message("mde_dictionary saved to data/mde_dictionary.rda\n")

## ---- 2. Build valence shifters table ----------------------------------------
vs_path <- "data-raw/valence_shifters.csv"
if (!file.exists(vs_path)) {
  stop("CSV not found at: ", vs_path)
}

valence_shifters <- data.table::fread(
  vs_path,
  colClasses = list(character = "x", integer = "y")
)
valence_shifters[, x := trimws(tolower(x))]
data.table::setkey(valence_shifters, x)

message("Valence shifters built:")
print(table(valence_shifters$y))
message("Total: ", nrow(valence_shifters), " tokens")

usethis::use_data(valence_shifters, overwrite = TRUE)
message("valence_shifters saved to data/valence_shifters.rda")
