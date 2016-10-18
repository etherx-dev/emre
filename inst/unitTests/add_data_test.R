TestInterceptTerm <- function() {
  i <- InterceptTerm$new("1")
  events <- AddData(i, data.frame(response = 1:10))
  checkEquals(events, sum(1:10))
}

TestOffsetTermData <- function() {
  o1 <- OffsetTerm$new("offset(x)")
  vec1 <- AddData(o1, data.frame(x = 1:10))
  checkEquals(vec1, 1:10)

  o2 <- OffsetTerm$new("offset(x*x)")
  vec2 <- AddData(o2, data.frame(x = 1:10))
  checkEquals(vec2, (1:10)^2)

  o3 <- OffsetTerm$new("offset(log(x))")
  vec3 <- AddData(o3, data.frame(x = 1:10))
  checkEqualsNumeric(vec3, log(1:10))

  o4 <- OffsetTerm$new("offset(log(x*x))")
  vec4 <- AddData(o4, data.frame(x = 1:10))
  checkEqualsNumeric(vec4, 2 * log(1:10))
}

TestLogOffsetTermData <- function() {
  o1 <- LogOffsetTerm$new("log.offset(x)")
  vec1 <- AddData(o1, data.frame(x = 1:10))
  checkEqualsNumeric(vec1, log(1:10))

  o2 <- LogOffsetTerm$new("log.offset(x*x)")
  vec2 <- AddData(o2, data.frame(x = 1:10))
  checkEqualsNumeric(vec2, 2 * log(1:10))

  # this should result in a 'double' log
  o3 <- LogOffsetTerm$new("log.offset(log(x))")
  vec3 <- AddData(o3, data.frame(x = 2:11))
  checkEqualsNumeric(vec3, log(log(2:11)))
}

TestFixedEffectSingleFactorDataFrame <- function() {
  f <- FixefTerm$new("x.1")
  df.in <- data.frame(x.1 = as.factor(1:10))
  df.out <- AddData(f, df.in)
  # the output data frame has a character column
  checkEquals(df.out$x.1, as.factor(as.character(1:10)))
}

TestFixedEffectSingleScalarDataFrame <- function() {
  f <- FixefTerm$new("x.1")
  df.in <- data.frame(x.1 = as.double(1:10))
  df.out <- AddData(f, df.in)
  checkEquals(df.out$x.1, as.factor(rep(1, 10)))
  checkEqualsNumeric(df.out[["x.1.scaling"]], df.in$x.1)
}

TestFixedEffectCrossedFactorsDataFrame <- function() {
  f <- FixefTerm$new("x.1*y.2")
  df.in <- data.frame(x.1 = as.factor(1:10), y.2 = as.factor(11:20))
  df.out <- AddData(f, df.in)
  checkEquals(df.out[["x.1__y.2"]], as.factor(paste(1:10, 11:20, sep = "*")))
}

TestFixedEffectCrossedScalarsDataFrame <- function() {
  f <- FixefTerm$new("x*y")
  df.in <- data.frame(x = 1:10, y = 11:20)
  df.out <- AddData(f, df.in)
  checkEquals(df.out[["x__y"]], as.factor(rep(1, 10)))
  checkEqualsNumeric(df.out[["x__y.scaling"]], (1:10) * (11:20))
}

TestGaussianNoiseVarianceDataFrame <- function() {
  g <- GaussianNoiseVarianceTerm$new("stddev(x)")
  df.in <- data.frame(x = 2:11)
  vec <- AddData(g, df.in)
  checkEqualsNumeric(vec, 1 / (2:11)^2)

  g2 <- GaussianNoiseVarianceTerm$new("sd(x*x)")
  vec2 <- AddData(g2, df.in)
  checkEqualsNumeric(vec2, 1 / (2:11)^4)

  # LMER type offset syntax
  g3 <- GaussianNoiseVarianceTerm$new("sd(log(x))")
  vec3 <- AddData(g3, df.in)
  checkEqualsNumeric(vec3, 1 / log(2:11)^2)
}