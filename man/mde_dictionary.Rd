\name{mde_dictionary}
\alias{mde_dictionary}
\docType{data}
\title{MDE Dimension Dictionary}
\description{
A data.table containing 324 tokens and their corresponding Memorable Dining
Experience (MDE) dimension assignments, validated by Vajpai, Webb & Beldona
(2025) from 11,481 French fine-dining restaurant reviews.
}
\format{
A data.table with 324 rows and 2 columns:
\describe{
  \item{token}{Character. The dictionary word (lower-case).}
  \item{dimension}{Character. One of \code{sensory}, \code{affect},
    \code{behavioral}, \code{social}, or \code{intellectual}.}
}
}
\references{
Vajpai, G. N., Webb, T., & Beldona, S. (2025). Designing a memorable
dining experience lexicon based on theory and text mining.
\emph{International Journal of Hospitality Management}, 130, 104245.
\doi{10.1016/j.ijhm.2025.104245}
}
\examples{
head(mde_dictionary, 10)
table(mde_dictionary$dimension)
}
