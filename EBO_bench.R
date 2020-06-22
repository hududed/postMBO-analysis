require(EBO)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

d = as.data.frame(read.csv("data/GOQ_3campaigns/ML.csv"))
d = subset(d, select = -c(gas,estimated,estimatedUpper,EI))

## Not run: 
# set.seed(1)
# data <- data.frame(a = runif(100,10,4000), b = runif(100,500,10000),
#                    c = runif(100,0,1000),
#                    d = sample(c("nitrogen","air","argon"), 50, replace = TRUE),
#                    e = sample(c("cat1","cat2","cat3"), 50, replace = TRUE))
# data$ratio <- rowSums(data[,1:3]^2)
# data$ratio <- data$ratio/max(data$ratio)
# colnames(data) <- c("power", "time", "pressure", "gas", "cat","testTarget")
instance = mlr::train(mlr::makeLearner("regr.randomForest"), 
                      mlr::makeRegrTask(data = d, target = "target"))

# define parameter space
psOpt = ParamHelpers::makeParamSet(
  ParamHelpers::makeIntegerParam("power", lower = 10, upper = 4000),
  ParamHelpers::makeIntegerParam("time", lower = 500, upper = 10000)
  # ParamHelpers::makeIntegerParam("pressure", lower = 0, upper = 1000)
)

funcEvals = 60

task = task(
  simulation = "regr.randomForest",
  data = d,
  target = "target",
  psOpt = psOpt,
  minimize = FALSE
)
plotBenchmark2 = plotBenchmark(task, funcEvals, repls = 20, seed = 5)
ggsave(plotBenchmark2, file = "GOQ_bench.png", height = 3, width = 5)
