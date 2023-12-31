% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/structural.R
\name{structural}
\alias{structural}
\title{Create adjacency matrix based on m/z (molecular weight) difference}
\usage{
structural(x, transformation, var = character(), ppm = 5, directed = FALSE)
}
\arguments{
\item{x}{`matrix` or `data.frame`, where columns are the samples and the rows are 
features (metabolites), cell entries are intensity values. `x` contains the
column `"mz"` that has the m/z information (numerical values) for the
calculation of mass differences between features}

\item{transformation}{`data.frame`, containing the columns `"group"`,
and `"mass"` that will be used for detection of transformation of
(functional) groups}

\item{var}{`character` corresponding to column names in `transformation`}

\item{ppm}{`numeric(1)`, mass accuracy of m/z features in parts per million (ppm)}

\item{directed}{`logical(1)`, if `TRUE`, absolute values of m/z differences will be
taken to query against `transformation`  (irrespective the sign of `mass`)
and undirected adjacency matrices will be returned as the respective
assays. This means, if there is a negative mass in 
`transformation[, "mass"]`, this negative mass will not be reported. 
If `FALSE`, directed
adjacency matrices will be returned with links reported that match the
transformations defined in `transformation` (respecting the sign of `mass`).
The `directed` slot of the returned `AdjacencyMatrix` object will contain
the information on `directed`.}
}
\value{
`AdjacencyMatrix` object. The object will store the adjacency matrix/matrices
in the assay slot/slots. The numerical (unweighted) adjacency matrix
inferred from mass differences is stored as the assay `"binary"`. Depending
on the `var` argument, there are additional adjacency matrices stored
in the assay slot.
}
\description{
The function `structural` infers an unweighted
adjacency matrix using differences in m/z values that are matched against a
`data.frame` (`transformation` of calculated theoretical differences of
loss/addition of functional groups. `structural` returns
an `AdjacencyMatrix` object containing
the unweighted `numeric` `matrix` (assay `binary`), together with one or 
multiple `character` matrices containing e.g. the type of loss/addition 
or the mass differences. The creation of the additional `character` matrices
is controlled by the `var` argument that specifies the column in 
`transformation` as the data source for the adjacency matrices.
}
\details{
`structural` accesses the column `"mz"` of
`x` to infer structural topologies based on the functional groups
defined by `transformation`. To account for the mass accuracy of
the dataset `x`, the user can specify the accuracy of m/z features
in parts per million (ppm) by the `ppm` argument. The m/z values in the
`"mz"` column of `x`" will be converted to m/z ranges according to
the `ppm` argument (default `ppm = 5`).

The returned `AdjacencyMatrix` object contains the assays 
`binary` and additional adjacency matrices depending on the `var` 
parameter. The assay `binary` stores the `numeric`
`matrix` with binary edges inferred from mass differences. The `var` 
parameter has to be set according to the column names in `transformation`.
E.g. if the `transformation` object contains a `"group"` column that stores
the name of the transformation, setting `var = "group"` will create an
assay `"group"` that contains the adjacency matrices where the entries
correspond to the `"group"` information for the respective feature pairs.

The `type` slot is set to `structural`. The `directed` slot is set 
accordingly to the `directed` argument of the function `structural`.
The `thresholded` slot is set to `FALSE`.
}
\examples{
data("x_test", package = "MetNet")
transformation <- rbind(
    c("Monosaccharide (-H2O)", "C6H10O5", "162.0528234315"),
    c("Disaccharide (-H2O)", "C12H20O11", "340.1005614851"),
    c("Trisaccharide (-H2O)", "C18H30O15", "486.1584702945"))
transformation <- data.frame(group = transformation[, 1],
                                formula = transformation[, 2],
                                mass = as.numeric(transformation[, 3]))
am_struct <- structural(x_test, transformation, var = c("group", "mass"),
    ppm = 10, directed = TRUE)

}
\author{
Thomas Naake, \email{thomasnaake@googlemail.com} and
Liesa Salzer, \email{liesa.salzer@helmholtz-muenchen.de}
}
