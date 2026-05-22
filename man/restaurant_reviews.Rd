\name{restaurant_reviews}
\alias{restaurant_reviews}
\docType{data}
\title{Sample Restaurant Reviews Dataset}
\description{
A sample dataset of 400 restaurant reviews from eight fictional restaurants,
designed to demonstrate the mdeinR package functions with reproducible
examples. Reviews cover all five MDE dimensions and include valence-shifter
examples (negation, amplification, de-amplification, adversative conjunctions).
}
\format{
A data.table with 400 rows and 4 columns:
\describe{
  \item{reviewID}{Character. Unique review identifier (e.g. "R0001").}
  \item{restaurant}{Character. One of eight restaurant names: Bella Italia,
    The Spice Garden, Ocean Blue, The Corner Bistro, Sakura Japanese,
    Le Petit Paris, The Grill House, and Cafe Mango.}
  \item{stars}{Integer. Star rating from 1 (lowest) to 5 (highest).}
  \item{text}{Character. The review text.}
}
}
\details{
Reviews deliberately include high-dimension examples, negated reviews
(e.g. "not amazing"), amplified reviews ("absolutely stunning"),
de-amplified reviews ("somewhat appealing"), adversative reviews
("beautiful but slow"), and multi-sentence reviews.
}
\examples{
head(restaurant_reviews)
table(restaurant_reviews$stars)
table(restaurant_reviews$restaurant)
}
