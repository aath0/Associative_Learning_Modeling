# Code to compute linear mixed effects models
rm(list=ls())
library(R.matlab)
library(nlme)
library(ggplot2)
library(effects)

# path of data and experiment we want to analyse:
filepath = '/Users/atzovara/Documents/Projects/SCR/Data2Release/Estimates2Release/'
setwd(filepath)
experiment = "PubFe_PSR"

# import .mat files:
d2t = paste("Experiment", experiment, "_4R.mat", sep = "")
matdata <- readMat(d2t)
matdata = matdata$ansest
matdata = matdata[, ,1]

# retrieve data and factors:
Estimates = t(matdata$estimate)
Condition = matdata$condition
Condition[Condition==1] <- "CS+"
Condition[Condition==2] <- "CS-"
Condition = factor(t(Condition), levels = c("CS+", "CS-"))
Participants = factor(t(matdata$participant))
Trial = t(matdata$trial)
Block = t(matdata$block)

# combine factors & data in a dataframe:
tff <- data.frame(Condition,Participants,Trial,Estimates)
# compute LME:
modd <- lme(Estimates ~ 1+Condition*Trial, random = ~ 1|Participants, data = tff)
# anova on LME results:
an <- anova(modd)

# extract effects and plot:
ef <- effect("Condition:Trial", modd, xlevels = 40)
a <- as.data.frame(ef)
p <- ggplot(data = a, aes(x=Trial, y = fit, colour = Condition), size = 2) +scale_color_manual(values= c("#252525","#969696"))
p <- p + stat_summary(fun.y = 'mean', geom = 'line', size = 1.25)+xlim(1, 40)+theme_minimal()
p <- p + geom_ribbon(aes(ymin=fit-se, ymax=fit+se, linetype = NA), alpha = 0.3) + theme_bw(base_size=12)
p <- p + theme(axis.text.x= element_text(size=14), axis.title.x = element_text(size = 12, face = "bold"))+ scale_x_continuous(breaks=c(0, 80, 160))
p <- p + theme(axis.title.y = element_text(size = 14, face = "bold"))+theme(legend.position="none")
p <- p + theme(strip.text = element_text(size=18), legend.text=element_text(size=14), legend.title=element_text(size=14))
print(p)
ggsave(paste(filepath, "/writing/version18/LMEs_", experiment, ".png", sep=""), width = 4, height = 3, dpi = 350)
