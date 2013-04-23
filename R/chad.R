rm(list = ls())
setwd('/Users/Carol/Documents/Android')

library(forecast)
library(xts)
library(RColorBrewer)

filename = "INDPRO.txt"

findText <-function(data, key){
	# data is a list of words, key is the word you are looking for
	# return the index of the keyword
	index = 1
	while(data[index] != key){
		index = index + 1
	}
	return(index)
}
# parse the file
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

# plots 1
png('plot1.png')
par(mfrow=c(2,2))
plot(tSeries, main = title, ylab="Value")
plot(log(tSeries), main = paste("log(", title, ")"), ylab="Value") 
# can do BoxCox transform here
plot(diff(tSeries), main = paste("diff(", title, ")"), ylab="Value")
plot(diff(log(tSeries)), main = paste("log(diff(", title,"))"), ylab="Value")
dev.off()

# index = findText(text, "Range:")
# begin = text[index+1]

# follow this book: http://www.statoek.wiso.uni-goettingen.de/veranstaltungen/zeitreihen/sommer03/ts_r_intro.pdf

# regression analysis

# exponential smoothing

# ARIMA

# diagonostic plots
 
# stephold <- auto.arima(x = dif1data, max.p = 10, max.q = 10, d = 0, ic = "aicc", trace = TRUE, approximation = FALSE)