library(plyr)
library(reshape2)

league <- as.factor("spa")
df <- read.csv(file=paste0("data/",league,".csv"), header=F)
names(df) <- c("Round","H","H.pts","A", "A.pts")

# W = 1, D = 0, L = -1 

df$H.W <- as.integer(df$H.pts > df$A.pts)
df$H.L <- -as.integer(df$H.pts < df$A.pts)
df$A.W <- as.integer(df$A.pts > df$H.pts)
df$A.L <- -as.integer(df$A.pts < df$H.pts)

head(df); tail(df)

# Wrangle into tidy format

df.H <- subset(df,select=Round)
df.H$Team <- df$H # home team data partition
df.H$Outcome <- df$H.W + df$H.L
df.H$Score <- paste0(df$H.pts,"-",df$A.pts)
df.H$Location <- "home"
df.H$Opponent <- df$A

head(df.H) # Tidy Data, Home Teams

df.A <- subset(df,select=Round)
df.A$Team <- df$A # away team data partition
df.A$Outcome <- df$A.W + df$A.L
df.A$Score <- paste0(df$H.pts,"-",df$A.pts)
df.A$Location <- "away"
df.A$Opponent <- df$H

head(df.A) # Tidy Data, Away Teams

outcome.H <- dcast(df.H,Team ~ Outcome, margins=T, fun.aggregate=length, value.var=1)
outcome.A <- dcast(df.A,Team ~ Outcome, margins=T, fun.aggregate=length, value.var=1)
names(outcome.H) <- c("Team", "L", "D", "W", "Total")
names(outcome.A) <- c("Team", "L", "D", "W", "Total")

# OVERALL

df.all <- rbind(df.H,df.A) # Tidy Data, All teams 
outcome <- dcast(df.all,Team ~ Outcome, margins=T, fun.aggregate=length, value.var=1)
names(outcome) <- c("Team", "L", "D", "W", "Total")

###### PROBABILITIES #######

P.H <- subset(outcome.H,select=Team)
P.H$W <- outcome.H$W/outcome.H$Total
P.H$L <- outcome.H$L/outcome.H$Total
P.H$D <- outcome.H$D/outcome.H$Total

P.H # Probability of home team X, winning/losing/drawing

P.A <- subset(outcome.A,select=Team)
P.A$W <- outcome.A$W/outcome.A$Total
P.A$L <- outcome.A$L/outcome.A$Total
P.A$D <- outcome.A$D/outcome.A$Total

P.A # Probability of away team X, winning/losing/drawing

P <- subset(outcome,select=Team)
P$W <- outcome$W/outcome$Total
P$L <- outcome$L/outcome$Total
P$D <- outcome$D/outcome$Total

P # OVERALL Probability of team X winning/losing/drawing, regardless of location

### EXPORT #### not currently porducing legible files... TODO!

# save(df.all,file=paste0("df.all_",league,".csv"))
# save(outcome,file=paste0("outcome_",league,".csv"))
