# this doesn't work
# http://skedasis.com/d3/slopegraph/


getData <- function(dataURL){
  require(reshape2); require(plyr)
  df <- read.csv(dataURL, stringsAsFactors = F)
  df <- df[, c(2, 3, 4, 7)]
  df <- rename(df, c(Date = "date", HomeTeam = "H", AwayTeam = "A"))
  df$date <- as.Date(df$date, format = "%d/%m/%y")
  
  dfm <- melt(df, measure.vars = c("H", "A"), 
              variable.name = "loc", value.name = 'team')
  dfm <- arrange(dfm, date)
  
  dfm <- mutate(dfm, 
                loc = as.character(loc), 
                points = 3*(loc == FTR) + 1*(FTR == 'D')
  )
  return(dfm)
}


# Compute the League Table on a Given Date
getLeagueTable <- function(date_, data_){
  dat <- subset(data_, date <= date_)
  dat2 <- ddply(dat, .(team), summarize,
                P = sum(points),
                G = length(points),
                W = length(points == 3),
                D = length(points == 1),
                L = length(points == 0)
  )
  dat3 <- arrange(dat2, P)
  dat3 <- transform(dat3, rank = rank(P, ties.method = 'min'))
  arrange(dat3, rank)
}


getBumpChartData <- function(url){
  require(plyr)
  #' Utility function to convert dates to seconds for javascript
  to_jsdate <- function(date_){
    val = as.POSIXct(as.Date(date_),origin="1970-01-01")
    as.numeric(val)
  }
  dfm <- getData(url)
  bumpChartData <- ldply(unique(dfm$date), function(date_){
    cbind(getLeagueTable(date_, dfm), date = to_jsdate(date_))
  })
  return(bumpChartData)
}

# Function to plot bump chart
plotBumpChart <- function(bData){
  require(rCharts);
  bump_chart <- Rickshaw$new()
  mycolors = ggthemes::tableau_color_pal("tableau20")(20)
  bump_chart$layer(rank ~ date, group = 'team', data = bData, 
                   type = 'line', interpolation = 'basis', colors = mycolors)
  bump_chart$yAxis(orientation = 'left')
  bump_chart$xAxis(type = 'Time')
  bump_chart$set(slider = TRUE, highlight = TRUE)
  options(RCHART_TEMPLATE = 'Rickshaw.html');
  return(bump_chart)
}

# data url for 2012-2013 results
url <- 'http://www.football-data.co.uk/mmz4281/1213/E0.csv'
bData <- getBumpChartData(url)
b1 <- plotBumpChart(bData)
b1$yAxis(tickFormat = 'function(n){return(n == 0 ? "": String(21 - n))}')
b1$hoverDetail(formatter = 'function(series, x, y){
  return "<b>" + series.name + "</b>: " + String(21 - y)        
}')