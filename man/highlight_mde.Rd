\name{highlight_mde}
\alias{highlight_mde}
\title{Highlight MDE Dimension Words in a Review}
\description{
Returns a character string with MDE dimension keywords wrapped in
XML-style annotation tags for qualitative inspection and debugging.
The default produces tags of the form <dimension>word</dimension>,
for example <sensory>aroma</sensory>.
}
\usage{
highlight_mde(text, mde_dt = mdeinR::mde_dictionary,
              tag_format = NULL)
}
\arguments{
\item{text}{A single character string (one review).}
\item{mde_dt}{A data.table with columns \code{token} and \code{dimension}.
  Defaults to the built-in \code{mde_dictionary}.}
\item{tag_format}{A sprintf-style format string with three \code{\%s}
  placeholders: dimension name (open tag), matched word, dimension name
  (close tag). When \code{NULL} (default), uses XML-style dimension tags.}
}
\value{
A character string with matched dimension words annotated with tags.
}
\examples{
\dontrun{
highlight_mde("The aroma was wonderful and staff were so caring.")
}
}
