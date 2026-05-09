\name{get_sentences}
\alias{get_sentences}
\title{Split Text Into Sentences}
\description{
Splits one or more character strings into individual sentences. Common
abbreviations (Mr., Dr., vs., etc.) are protected and do not trigger a
split. Sentence boundaries are detected at periods, exclamation marks,
question marks, and semicolons.
}
\usage{
get_sentences(text)
}
\arguments{
  \item{text}{A character vector. Each element is treated as one document.}
}
\value{
A \code{data.table} with columns:
\describe{
  \item{element_id}{Integer. Index of the source document.}
  \item{sentence_id}{Integer. Index of the sentence within its document.}
  \item{sentences}{Character. The sentence text (trimmed).}
}
}
\examples{
\dontrun{
get_sentences(c(
  "The food was amazing. Staff were so caring!",
  "We learned about Thai cuisine. Truly memorable."
))
}
}
