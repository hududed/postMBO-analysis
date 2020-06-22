require(EBO)
# require(readr)
# require(data.table)
# require(ggplot2)
# require(BBmisc)
# require(scales)
# require(ggrepel)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# import data as df
dat = as.data.frame(read.csv("data/ML.csv"))
df = subset(dat, select = -c(gas,estimated,estimatedUpper,EI))


# define infillCrit
ctrl = mlrMBO::makeMBOControl()
ctrl = mlrMBO::setMBOControlInfill(ctrl, crit = mlrMBO::makeMBOInfillCritEI())

# # define runs of each algorithm
# repls = 20
# define function evaluations
funcEvals = 42


# define parameter space
psOpt = ParamHelpers::makeParamSet(
  ParamHelpers::makeIntegerParam("power", lower = 10, upper = 5555),
  ParamHelpers::makeIntegerParam("time", lower = 500, upper = 20210),
  ParamHelpers::makeIntegerParam("pressure", lower = 0, upper = 1000)
)
# create task
task = EBO::task(
  simulation = "regr.randomForest",
  data = df,
  target = "target",
  psOpt = psOpt,
  minimize = FALSE
)
# # define hyperparameter space
# psParamPlot = ParamHelpers::makeParamSet(
#   ParamHelpers::makeDiscreteParam("surrogate", values = ("regr.km")),
#   ParamHelpers::makeDiscreteParam("crit", values = ("makeMBOInfillCritCB")),
#   # benchmark the amount of initial design
#   ParamHelpers::makeIntegerParam("amountDesign", lower = 5, upper = 35)
# )
# # define reosultion for the hyperparameter space
# resolution = 5
# 
# # execute computation
# EBO::plotMboHyperparams(task, funcEvals, psParamPlot, resolution,
#                         repls = repls)

# define two hyperparameters
psParamPlot = ParamHelpers::makeParamSet(
  ParamHelpers::makeDiscreteParam("surrogate", values = ("regr.randomForest")),
  ParamHelpers::makeDiscreteParam("crit", values = ("makeMBOInfillCritAdaCB")),
  # benchmark different values for cb.lambda.start and cb.lambda.end
  ParamHelpers::makeIntegerParam("cb.lambda.start",
                                 lower = 3, upper = 10,
                                 requires = quote(crit == "makeMBOInfillCritAdaCB")),
  ParamHelpers::makeNumericParam("cb.lambda.end",
                                 lower = 0, upper = 3,
                                 requires = quote(crit == "makeMBOInfillCritAdaCB"))
)
# define reosultion for the hyperparameter space
resolution = 3
# execute computation
EBO::plotMboHyperparams(task, funcEvals, psParamPlot, resolution, repls = 10)