library(rCharts)

source(file="munge/process.R")

# curse of dimensionality strikes, too high to vizualize without further wrangling
melt.P <- melt(P) # melting is one (lazy) technqiue, subsetting is another


# Horizontal Stacked bars chart 100%, optional Storyboard

d1 <- dPlot(y="Team", x="value", data=melt.P, groups="variable",type="bar") 
d1$yAxis(type="addCategoryAxis", orderRule="Team")
d1$xAxis(type="addPctAxis") # instead of addMeasureAxis used in the Horizontal Stacked Bar
d1$legend(x = 0, y = 0, width = 500, height = 75, horizontalAlign = "right")
# d1$set(storyboard = "league") # chart will change by league

d1 # execute to browser

d1$save('viz_stackchart1.html')