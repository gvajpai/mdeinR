\name{valence_shifters}
\alias{valence_shifters}
\docType{data}
\title{Valence Shifters Table}
\description{
A data.table of 248 English valence-shifter tokens used to modulate raw MDE
dimension scores. Bundled directly in mdeinR so no external NLP package is
required. The type coding scheme follows Rinker (2021).
}
\format{
A data.table with 248 rows and 2 columns:
\describe{
  \item{x}{Character. The lower-case token.}
  \item{y}{Integer. Shifter type: 1 = negator, 2 = amplifier,
    3 = de-amplifier, 4 = adversative conjunction.}
}
}
\references{
Rinker, T. W. (2021). sentimentr: Calculate text polarity sentiment.
University at Buffalo/SUNY. \url{https://github.com/trinker/sentimentr}
}
\examples{
head(valence_shifters)
table(valence_shifters$y)
}
