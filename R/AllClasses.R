
###
### Class AdjacencyMatrix
###
.AdjacencyMatrix <- setClass("AdjacencyMatrix",
    contains = c("SummarizedExperiment"),
    slots = c(
        type = "character", ## structural, statistical, combined
        thresholded = "logical" ## thresholded, e.g. by rtCorrection or by threshold
    )
)

AdjacencyMatrix <- function(..., rowData, type, thresholded) {
    se <- SummarizedExperiment(list(...), rowData = rowData, colData = rowData)
    .AdjacencyMatrix(se, type = type, thresholded = thresholded)
}

rD <- DataFrame(names = rownames(struct_adj[[1]]))
rownames(rD) <- rownames(struct_adj[[1]])
adj_se <- AdjacencyMatrix(binary = t(struct_adj[[1]]), transformation = t(struct_adj[[2]]), 
    mass_difference = struct_adj[[1]], rowData = rD, type = "structural", thresholded = FALSE)


### 
### Validity
###
setValidity2("AdjacencyMatrix", function(object) {
    msg <- NULL
    
    type_obj <- type(object)
    
    a <- assays(object)[[1]]
    if (nrow(a) != ncol(a)) {
        msg <- c(msg, "nrow not equal ncol for assays")
    }
    
    valid_names_struct <- c("binary", "transformation", "mass_difference")
    valid_names_stat <- c(
        "lasso_coef", "randomForest_coef", "clr_coef", "aracne_coef",
        "pearson_coef", "pearson_pvalue", "spearman_coef", "spearman_pvalue",
        "pearson_partial_coef", "pearson_partial_pvalue",
        "spearman_partial_coef", "spearman_partial_pvalue",
        "pearson_semipartial_coef", "pearson_semipartial_pvalue",
        "spearman_semipartial_coef", "spearman_semipartial_pvalue",
        "bayes_coef")
    
    if (type_obj == "structural" | type_obj == "combine") {
        
        if (!all(valid_names_struct %in% assayNames(object)))
            msg <- c(msg, "assay names must be 'binary', 'transformation', 'mass_difference'")
        
        
        .obj <- assay(object, "binary")
        if (!is.numeric(.obj))
            msg <- c(msg, "slot 'binary' must be numeric")
        
        .obj <- assay(object, "transformation")
        if (!is.character(.obj))
            msg <- c(msg, "slot 'transformation' must be character")
        
        .obj <- assay(object, "mass_difference")
        if (!is.numeric(.obj))
            msg <- c(msg, "slot 'mass_difference' must be character")
    }
    
    if (type_obj == "statistical" | type_obj == "combine") {
        
        if (any(!(assayNames(object) %in% validNames_stat)))
            msg <- c(msg, "assay names contain invalid entries")
        
        .nms <- assayNames(object)
        
        if (type_obj == "combine")
            .nms <- .nms[!(.nms %in% c("binary", "type", "mass_difference"))]
        
        assay_num <- lapply(seq_along(.nms),
                                    function(x) is.numeric(assay(object, i)))
        if (!all(unlist(assay_num)))
            msg <- c(msg, "assays must be all numeric")
    }
    
    if (is.null(msg)) {
        TRUE
    } else {
        msg
    }

})