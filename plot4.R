# This script assumes that the dataset zip file, named "data1.zip" is in the current working directory, otherwise it downloads it
# As it has been created on a Mac, it will use the "curl" method
if (!file.exists("data1.zip")) {
  download.file("https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip", destfile = "data1.zip", method = "curl")
}

# After that, we check whether the file has been unzipped and, if not, we proceed to do so

filename <- unzip("data1.zip", list= T)[[1]]
if (!file.exists(filename)) {
  unzip("data1.zip")
}

# We read the dataset and store it in a Data Table. 
# We then extract the data we want to use and throw away the original data table to free some memory.
# Since the "Global_intensity" variable is not used, we ignore it
# For some reason, even with the na.strings parameter set, when fread convert the whole column to character when it meets a "?"
DT <- fread(filename, sep = ";", na.strings = "?", drop = "Global_intensity")
DT2 <- DT[(DT$Date == "1/2/2007" | DT$Date == "2/2/2007"),]
rm(DT)

# In order to get the correct labels, we need the locale to be set to English
mylocale <- Sys.getlocale("LC_TIME")
Sys.setlocale("LC_TIME", "en_GB.UTF-8")

# We add a DateTime column using the handy lubridate package
library(lubridate)
DT2[,DateTime:=dmy_hms(paste(Date,Time))]

# We can finally do the actual plotting, storing it into a PNG file
png(filename = "plot4.png", width = 480, height = 480)

par(mfcol = c(2,2))

with(DT2, plot(DateTime, as.numeric(Global_active_power), type="l", xlab = "", ylab = "Global Active Power"))
with(DT2, plot(DateTime, as.numeric(Sub_metering_1), col = "black", type="l", xlab = "", ylab = "Energy sub metering"))
with(DT2, lines(DateTime, as.numeric(Sub_metering_2), col = "red"))
with(DT2, lines(DateTime, as.numeric(Sub_metering_3), col = "blue"))
legend("topright", c("Sub_metering_1","Sub_metering_2","Sub_metering_3"), lty = 1, col = c("black","red","blue"), bty = "n")
with(DT2, plot(DateTime, as.numeric(Voltage), type="l", xlab = "datetime", ylab = "Voltage"))
with(DT2, plot(DateTime, as.numeric(Global_reactive_power), type="l", xlab = "datetime", ylab = "Global_reactive_power"))

dev.off()

par(mfcol = c(1,1))