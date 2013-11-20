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

games.H <- subset(df,select=Round)
games.H$Team <- df$H # home team data partition
games.H$Outcome <- df$H.W + df$H.L
games.H$Score <- paste0(df$H.pts,"-",df$A.pts)
games.H$Location <- "home"
games.H$Opponent <- df$A

head(games.H) # Tidy Data, Home Teams

games.A <- subset(df,select=Round)
games.A$Team <- df$A # away team data partition
games.A$Outcome <- df$A.W + df$A.L
games.A$Score <- paste0(df$H.pts,"-",df$A.pts)
games.A$Location <- "away"
games.A$Opponent <- df$H

head(games.A) # Tidy Data, Away Teams

outcome.H <- dcast(games.H,Team ~ Outcome, margins=T, fun.aggregate=length, value.var=1)
outcome.A <- dcast(games.A,Team ~ Outcome, margins=T, fun.aggregate=length, value.var=1)
names(outcome.H) <- c("Team", "L", "D", "W", "Total")
names(outcome.A) <- c("Team", "L", "D", "W", "Total")

# OVERALL

games.all <- rbind(games.H,games.A) # Tidy Data, All teams 
outcome <- dcast(games.all,Team ~ Outcome, margins=T, fun.aggregate=length, value.var=1)
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

write.csv(games.all,file=paste0(league,"_games.csv"))
write.csv(outcome,file=paste0(league,"_standings.csv"))
write.csv(P,file=paste0(league,"_probabilities.csv"))
write.csv(P.A,file=paste0(league,"_probabilities_away.csv"))
write.csv(P.H,file=paste0(league,"_probabilities_home.csv"))
