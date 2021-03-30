## create toy example data set
data("x_test", package = "MetNet")

## transformations object for structual calculation
transformations <- rbind(
    c("Malonyl group (-H2O)", "C3H2O3", "86.0003939305", "-"),
    c("Monosaccharide (-H2O)", "C6H10O5", "162.0528234315", "-"))
transformations <- data.frame(group = as.character(transformations[, 1]),
    formula = as.character(transformations[, 2]),
    mass = as.numeric(transformations[, 3]),
    rt = as.character(transformations[, 4]))

## create structural network
struct_adj <- structural(x_test,
    transformation = transformations, ppm = 5, directed = FALSE)
struct_adj_thr <- rtCorrection(am = struct_adj, x = x_test, 
    transformation = transformations)

## create statistical network
x_test_cut <- as.matrix(x_test[, -c(1:2)])
stat_adj <- statistical(x_test_cut,
    model = c("clr", "aracne", "pearson", "spearman"))
stat_adj_thr <- threshold(am = stat_adj, type = "top2", args = list(n = 10))

## combine the two AdjacencyMatrix objects
cons_adj <- combine(am_structural = struct_adj, am_statistical = stat_adj_thr)

## START unit test methods ##
test_that("length", {
    expect_equal(length(struct_adj), 36)
    expect_equal(length(struct_adj_thr), 36)
    expect_equal(length(stat_adj), 36)
    expect_equal(length(stat_adj_thr), 36)
    expect_equal(length(cons_adj), 36)
})

test_that("dim", {
    expect_equal(dim(struct_adj), c(36, 36))
    expect_equal(dim(struct_adj_thr), c(36, 36))
    expect_equal(dim(stat_adj), c(36, 36))
    expect_equal(dim(stat_adj_thr), c(36, 36))
    expect_equal(dim(cons_adj), c(36, 36))
})

test_that("type", {
    expect_equal(type(struct_adj), "structural")
    expect_equal(type(struct_adj_thr), "structural")
    expect_equal(type(stat_adj), "statistical")
    expect_equal(type(stat_adj_thr), "statistical")
    expect_equal(type(cons_adj), "combine")
})

test_that("directed", {
    expect_equal(directed(struct_adj), FALSE)
    expect_equal(directed(struct_adj_thr), FALSE)
    struct_adj_dir <- structural(x_test,
        transformation = transformations, ppm = 5, directed = TRUE)
    expect_equal(directed(struct_adj_dir), TRUE)
    stat_adj_dir <- statistical(x_test_cut[1:5, 1:5],
        model = c("clr", "aracne", "pearson", "spearman", "bayes"))
    expect_equal(directed(stat_adj_dir), TRUE)
    expect_equal(directed(stat_adj), FALSE)
    expect_equal(directed(stat_adj_thr), FALSE)
    expect_equal(directed(cons_adj), FALSE)
})

test_that("thresholded", {
    expect_equal(thresholded(struct_adj), FALSE)
    expect_equal(thresholded(struct_adj_thr), TRUE)
    expect_equal(thresholded(stat_adj), FALSE)
    expect_equal(thresholded(stat_adj_thr), TRUE)
    cons_adj <- combine(struct_adj, stat_adj_thr)
    expect_equal(thresholded(cons_adj), TRUE)
    cons_adj <- combine(struct_adj_thr, stat_adj_thr)
    expect_equal(thresholded(cons_adj), TRUE)
})

test_that("as.data.frame", {
    ## struct_adj
    df <- as.data.frame(struct_adj)
    expect_equal(dim(df), c(666, 5))
    expect_equal(colnames(df), 
        c("Row", "Col", "binary", "transformation", "mass_difference"))
    expect_equal(df$Row[1:5], c("x9485", "x7449", "x7449", "x11179", "x11179"))
    expect_equal(df$Col[1:5], c("x9485", "x9485", "x7449", "x9485", "x7449")) 
    expect_equal(df$binary[1:5], c(0, 0, 0, 0, 1))
    expect_equal(as.vector(table(df$binary)), c(650, 16))
    expect_equal(df$transformation[1:5], c(rep("", 4), "Monosaccharide (-H2O)"))
    expect_equal(as.vector(table(df$transformation)), c(650, 10, 6))
    expect_equal(df$mass_difference[1:5], c(rep("", 4), "162.0528234315"))
    expect_equal(as.vector(table(df$mass_difference)), c(650, 6, 10))
    
    ## struct_adj_thr
    df <- as.data.frame(struct_adj_thr)
    expect_equal(dim(df), c(666, 5))
    expect_equal(colnames(df),
        c("Row", "Col", "binary", "transformation", "mass_difference"))
    expect_equal(df$Row[1:5], c("x9485", "x7449", "x7449", "x11179", "x11179"))
    expect_equal(df$Col[1:5], c("x9485", "x9485", "x7449", "x9485", "x7449"))
    expect_equal(df$binary[1:5], c(0, 0, 0, 0, 0))
    expect_equal(as.vector(table(df$binary)), c(656, 10))
    expect_equal(df$transformation[1:5], rep("", 5))
    expect_equal(as.vector(table(df$transformation)), c(656, 10))
    expect_equal(df$mass_difference[1:5], rep("", 5))
    expect_equal(as.vector(table(df$mass_difference)), c(656, 10))
    
    ## stat_adj
    df <- as.data.frame(stat_adj)
    expect_equal(dim(df), c(630, 8))
    expect_equal(colnames(df), 
        c("Row", "Col", "clr_coef", "aracne_coef", "pearson_coef",
            "pearson_pvalue", "spearman_coef", "spearman_pvalue"))
    expect_equal(df$Row[1:5], c("x7449", "x11179", "x11179", "x11374", "x11374"))
    expect_equal(df$Col[1:5], c("x9485", "x9485", "x7449", "x9485", "x7449"))
    expect_equal(sum(df$clr_coef), 276.4948, tolerance = 1e-06)
    expect_equal(sum(df$aracne_coef), 57.64072, tolerance = 1e-06)
    expect_equal(sum(df$pearson_coef), 213.6638, tolerance = 1e-06)
    expect_equal(sum(df$pearson_pvalue), 51.07814, tolerance = 1e-06)
    expect_equal(sum(df$spearman_coef), 203.2846, tolerance = 1e-06)
    expect_equal(sum(df$spearman_pvalue), 58.33817, tolerance = 1e-06)
    
    ## stat_adj_thr
    df <- as.data.frame(stat_adj_thr)
    expect_equal(dim(df), c(630, 9))
    expect_equal(colnames(df), 
        c("Row", "Col", "clr_coef", "aracne_coef", "pearson_coef",
            "pearson_pvalue", "spearman_coef", "spearman_pvalue", "consensus"))
    expect_equal(df$Row[1:5], c("x7449", "x11179", "x11179", "x11374", "x11374"))
    expect_equal(df$Col[1:5], c("x9485", "x9485", "x7449", "x9485", "x7449"))
    expect_equal(sum(df$clr_coef), 276.4948, tolerance = 1e-06)
    expect_equal(sum(df$aracne_coef), 57.64072, tolerance = 1e-06)
    expect_equal(sum(df$pearson_coef), 213.6638, tolerance = 1e-06)
    expect_equal(sum(df$pearson_pvalue), 51.07814, tolerance = 1e-06)
    expect_equal(sum(df$spearman_coef), 203.2846, tolerance = 1e-06)
    expect_equal(sum(df$spearman_pvalue), 58.33817, tolerance = 1e-06)
    expect_equal(sum(df$consensus), 14)
    
    ## combine
    df <- as.data.frame(cons_adj)
    expect_equal(dim(df), c(666, 15))
    expect_equal(colnames(df), 
        c("Row", "Col", "clr_coef", "aracne_coef", "pearson_coef",
            "pearson_pvalue", "spearman_coef", "spearman_pvalue", "consensus",
            "binary", "transformation", "mass_difference",
            "combine_binary", "combine_transformation",
            "combine_mass_difference"))
    expect_equal(df$Row[1:5], c("x9485", "x7449", "x7449", "x11179", "x11179"))
    expect_equal(df$Col[1:5], c("x9485", "x9485", "x7449", "x9485", "x7449"))
    expect_equal(sum(df$clr_coef, na.rm = TRUE), 276.4948,
        tolerance = 1e-06)
    expect_equal(sum(df$aracne_coef, na.rm = TRUE), 57.64072,
        tolerance = 1e-06)
    expect_equal(sum(df$pearson_coef, na.rm = TRUE), 213.6638,
        tolerance = 1e-06)
    expect_equal(sum(df$pearson_pvalue, na.rm = TRUE), 51.07814,
        tolerance = 1e-06)
    expect_equal(sum(df$spearman_coef, na.rm = TRUE), 203.2846,
        tolerance = 1e-06)
    expect_equal(sum(df$spearman_pvalue, na.rm = TRUE), 58.33817,
        tolerance = 1e-06)
    expect_equal(sum(df$consensus, na.rm = TRUE), 14)
    expect_equal(df$binary[1:5], c(0, 0, 0, 0, 1))
    expect_equal(as.vector(table(df$binary)), c(650, 16))
    expect_equal(df$transformation[1:5], c(rep("", 4), "Monosaccharide (-H2O)"))
    expect_equal(as.vector(table(df$transformation)), c(650, 10, 6))
    expect_equal(df$mass_difference[1:5], c(rep("", 4), "162.0528234315"))
    expect_equal(as.vector(table(df$mass_difference)), c(650, 6, 10))
    expect_equal(df$combine_binary[1:5], c(NA, 0, NA, 0, 0))
    expect_equal(as.vector(table(df$combine_binary)), c(623, 7))
    expect_equal(df$combine_transformation[1:5], c(NA, "", NA, "", ""))
    expect_equal(as.vector(table(df$combine_transformation)), c(623, 6, 1))
    expect_equal(df$combine_mass_difference[1:5], c(NA, "", NA, "", ""))
    expect_equal(as.vector(table(df$combine_mass_difference)), c(623, 1, 6))
    
})