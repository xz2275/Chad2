args<-commandArgs(TRUE)
# provide seriesID in the command line 
setwd('/Users/Carol/Documents/Android/Chad2/R')

library(forecast)
library(xts)
library(tseries)
library(RColorBrewer)

# filename = "IC4WSA.txt"
filename = paste0(args, ".txt")

findText <-function(data, key){
	# data is a list of words, key is the word you are looking for
	# return the index of the keyword
	index = 1
	while(data[index] != key){
		index = index + 1
	}
	return(index)
}
# -- [ Parse the data file ] --
# =========================
text = scan(filename, character(0))
line = readLines(filename, 1)
title = strsplit(line, "               ")[[1]][2]

index = findText(text, "VALUE")
value = c()
for (i in seq((index+2), length(text), 2)){
	value = append(value, as.numeric(text[i]))
}
dates = c()
for (i in seq((index+1), length(text)-1, 2)){
	dates = append(dates, as.Date(text[i]))
}
data = data.frame(value, row.names=dates)
tSeries = xts(data, order.by=dates)

paste("DATE PROCESSED...")

# -- [ Data Visualization ] --
# =============================

png('plot1.png')
par(mfrow=c(2,2))
plot(tSeries, main = title, ylab="Value")
plot(log(tSeries), main = paste("log(", title, ")"), ylab="Value") 
# can do BoxCox transform here
plot(diff(tSeries), main = paste("diff(", title, ")"), ylab="Value")
plot(diff(log(tSeries)), main = paste("log(diff(", title,"))"), ylab="Value")
dev.off()

paste("INITIAL PLOTTING DONE...")
# follow this book: http://www.statoek.wiso.uni-goettingen.de/veranstaltungen/zeitreihen/sommer03/ts_r_intro.pdf

# -- [ Linear Filtering ] --
# ===========================
# This is a method to obtain trend in tsa
png('plot2.png')
par(mfrow=c(2,1))
plot(as.numeric(tSeries), type="l", main=paste("Linear Filtering Output of ", title), xlab="", ylab="Value", xaxt="n")
abline(v=(seq(0,length(tSeries),60)), col="lightgray", lwd=1, lty=4)
abline(h=(seq(0,100,20)), col="lightgray", lwd=1, lty=4)
tui.1 <- filter(tSeries,filter=rep(1/5,5))
tui.2 <- filter(tSeries,filter=rep(1/25,25))
tui.3 <- filter(tSeries,filter=rep(1/81,81))
lines(tui.1,col="red")
lines(tui.2,col="purple")
lines(tui.3,col="blue")

paste("LINEAR FILTERING DONE...")

# -- [ Regression Analysis ] --
# ==============================
index = findText(text, "Range:")
begin = text[index+1]
end = text[index+3]
byy = as.numeric(strsplit(begin, "-")[[1]][1])
bmm = as.numeric(strsplit(begin, "-")[[1]][2])
bdd = as.numeric(strsplit(begin, "-")[[1]][3])
eyy = as.numeric(strsplit(end, "-")[[1]][1])
emm = as.numeric(strsplit(end, "-")[[1]][2])
edd = as.numeric(strsplit(end, "-")[[1]][3])
from_date = byy + bmm/10 
to_date = eyy + emm/10

lseries = log(tSeries)
t<-seq(from_date,to_date,length=length(lseries))
t2<-t^2
plot(lseries, ylab="Value", main="Performing Regression Analysis")
regress = lm(lseries ~ t + t2)
lines(lm(lseries~t+t2)$fit,col=2,lwd=2)
dev.off()

paste("REGRESSION DONE...")

# -- [ ARIMA Analysis ] --
# =========================
holdfit = auto.arima(log(as.ts(tSeries)), d = 1, approx=FALSE, ic="aicc", trace=TRUE)

# -- [ Residual Diagonostic for ARIMA ] --
# =====================================
png('plot3.png')
tsdiag(holdfit)
dev.off()
paste("ARIMA DONE...")

# -- [ Forecast ] --
# ===================
horoscope = forecast(holdfit)
png('plot3.png')
plot(horoscope)
dev.off()

# -- [ Output Model Summaries ] --
# =================================
cat("Printing Model Summaries (in .txt file):\n")
sink("TSA_result.txt", append=T)
cat("Time Series Analysis Output for ", title, "\n")
cat("\nRegression Analysis:\n")
print(summary(regress))

cat("\nARIMA Analysis:\n")
print(summary(holdfit))

cat("\nForecast Result (Complex):\n")
print(summary(horoscope))
sink()