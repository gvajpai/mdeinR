\name{mde}
\alias{mde}
\title{Score Memorable Dining Experience Dimensions in Text}
\description{
Detects and scores the five MDE dimensions — sensory, affect, behavioral,
social, and intellectual — in each sentence of the supplied text, applying
valence-shifter (negator, amplifier, de-amplifier, adversative conjunction)
adjustments.
}
\usage{
mde(
  text,
  mde_dt = mdeinR::mde_dictionary,
  valence_shifters_dt = mdeinR::valence_shifters,
  n.before = 5L,
  n.after = 2L,
  amplifier.weight = 0.8,
  n.neutral = 0.2,
  neutral.nonword.check = TRUE,
  ...
)
}
\arguments{
  \item{text}{A character vector, data.frame, or output of \code{get_sentences()}.}
  \item{mde_dt}{A data.table with columns \code{token} and \code{dimension}. Defaults to the built-in \code{mde_dictionary}.}
  \item{valence_shifters_dt}{A data.table with columns \code{x} (token) and \code{y} (integer type code). Defaults to the built-in \code{valence_shifters} table.}
  \item{n.before}{Number of words before a dimension word to scan for valence shifters. Default \code{5}.}
  \item{n.after}{Number of words after a dimension word to scan for valence shifters. Default \code{2}.}
  \item{amplifier.weight}{Multiplicative boost for amplifiers. Default \code{0.8}.}
  \item{n.neutral}{Fraction toward neutral applied for de-amplifiers. Default \code{0.2}.}
  \item{neutral.nonword.check}{If \code{TRUE}, punctuation-only tokens are ignored. Default \code{TRUE}.}
  \item{...}{Currently unused.}
}
\value{
A \code{data.table} with one row per sentence containing columns:
\code{element_id}, \code{sentence_id}, \code{word_count}, \code{sensory},
\code{affect}, \code{behavioral}, \code{social}, \code{intellectual},
\code{mde_count}.
}
\references{
Vajpai, G. N., Webb, T., & Beldona, S. (2025). Designing a memorable
dining experience lexicon based on theory and text mining.
\emph{International Journal of Hospitality Management}, 130, 104245.
\doi{10.1016/j.ijhm.2025.104245}
}
\examples{
\dontrun{
reviews <- c(
  "The aroma and presentation were absolutely stunning.",
  "Staff were warm and genuinely caring."
)
mde(reviews)
}
}
