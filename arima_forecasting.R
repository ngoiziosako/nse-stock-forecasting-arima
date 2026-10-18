# =============================================================================
# Stock Price Forecasting Using ARIMA - Nairobi Securities Exchange
# BSc Actuarial Science capstone, The Catholic University of Eastern Africa (2021)
#
# NOTE: This is the code as submitted in the appendix of the 2021 report,
# reformatted for readability. It is provided for reference and is NOT fully
# runnable as-is:
#   - The original dataset (licensed from Synergy Systems Ltd.) is not included.
#   - The appendix did not include the lines that create the differenced series
#     (scomDiff1, scomDiff2, eqtyDiff1, eqtyDiff2, ftseDiff1, ftseDiff2), so
#     those objects are referenced below but never defined.
# One typo from the appendix was corrected: `DayPrice` -> `Day Price` in the
# Safaricom error calculation.
# =============================================================================


# ---- B.1 Data wrangling ------------------------------------------------------

# Install and load the necessary packages
install.packages("forecast")
install.packages("tseries")
install.packages("TSstudio")
install.packages("tidyverse")
install.packages("fpp2")
install.packages("rio")
install.packages("ggplot2")
install.packages("plotly")
install.packages("xts")

library("forecast")
library("rio")
library("ggplot2")
library("plotly")
library("tseries")
library("TSstudio")
library("tidyverse")
library("fpp2")
library("xts")

# Import data (all yearly CSV files in the working directory)
nse_all <- dir(full.names = TRUE) %>% map_df(read_csv)
str(nse_all)

# Isolate Safaricom, Equity and NSE FTSE 15 data
scom      <- nse_all[nse_all$CODE == "SCOM", ]
eqty      <- nse_all[nse_all$CODE == "EQTY", ]
nseFTSE15 <- nse_all[nse_all$CODE == "^FNK15", ]

# Convert date column to date objects
scom$DATE      <- as.Date(scom$DATE, format = "%m/%d/%Y")
eqty$DATE      <- as.Date(eqty$DATE, format = "%m/%d/%Y")
nseFTSE15$DATE <- as.Date(nseFTSE15$DATE, format = "%m/%d/%Y")

# Truncate Equity series to remove the early volatile period
eqtyTr <- eqty[-1:-580, ]

# Create indexed time series objects to avoid dealing with missing weekend data
scomDP2 <- ts(na.omit(scom$`Day Price`), frequency = 30)
eqtyDP2 <- ts(na.omit(eqtyTr$`Day Price`), frequency = 30)
ftseDP2 <- ts(na.omit(nseFTSE15$`Day Price`), frequency = 30)


# ---- B.2 ARIMA modeling ------------------------------------------------------

# Apply decomposition and seasonal adjustment
decompscomDP2     <- stl(scomDP2, s.window = "periodic")
deseasonalscomDP2 <- seasadj(decompscomDP2)

decompeqtyDP2     <- stl(eqtyDP2, s.window = "periodic")
deseasonaleqtyDP2 <- seasadj(decompeqtyDP2)

decompftseDP2     <- stl(ftseDP2, s.window = "periodic")
deseasonalftseDP2 <- seasadj(decompftseDP2)

# Create training sets (all but the last 5 values) and apply log
scomTrain <- log(deseasonalscomDP2[1:3214])
eqtyTrain <- log(deseasonaleqtyDP2[1:2990])
ftseTrain <- log(deseasonalftseDP2[1:2070])

# [Not in original appendix: creation of the differenced series
#  scomDiff1/2, eqtyDiff1/2, ftseDiff1/2 from the training sets.]

# Plot the differenced series and their ACF / PACF
par(mfrow = c(3, 1))
plot(scomDiff1, type = "l", main = "Safaricom first difference")
acf(scomDiff1,  main = "Safaricom 1st difference acf plot",  lag.max = 10)
pacf(scomDiff1, main = "Safaricom 1st difference pacf plot", lag.max = 10)

par(mfrow = c(3, 1))
plot(scomDiff2, type = "l", main = "Safaricom second difference")
acf(scomDiff2,  main = "Safaricom 2nd difference acf plot",  lag.max = 10)
pacf(scomDiff2, main = "Safaricom 2nd difference pacf plot", lag.max = 10)

par(mfrow = c(3, 1))
plot(eqtyDiff1, type = "l", main = "Equity first difference")
acf(eqtyDiff1,  main = "Equity 1st difference acf plot",  lag.max = 10)
pacf(eqtyDiff1, main = "Equity 1st difference pacf plot", lag.max = 10)

par(mfrow = c(3, 1))
plot(eqtyDiff2, type = "l", main = "Equity second difference")
acf(eqtyDiff2,  main = "Equity 2nd difference acf plot",  lag.max = 10)
pacf(eqtyDiff2, main = "Equity 2nd difference pacf plot", lag.max = 10)

par(mfrow = c(3, 1))
plot(ftseDiff1, type = "l", main = "FTSE 15 first difference")
acf(ftseDiff1,  main = "FTSE 1st difference acf plot",  lag.max = 10)
pacf(ftseDiff1, main = "FTSE 1st difference pacf plot", lag.max = 10)

par(mfrow = c(3, 1))
plot(ftseDiff2, type = "l", main = "FTSE 15 second difference")
acf(ftseDiff2,  main = "FTSE 15 2nd difference acf plot",  lag.max = 10)
pacf(ftseDiff2, main = "FTSE 15 2nd difference pacf plot", lag.max = 10)

# Test for stationarity (Augmented Dickey-Fuller)
adf.test(scomDiff1, alternative = "stationary")
adf.test(scomDiff2, alternative = "stationary")
adf.test(eqtyDiff1, alternative = "stationary")
adf.test(eqtyDiff2, alternative = "stationary")
adf.test(ftseDiff1, alternative = "stationary")
adf.test(ftseDiff2, alternative = "stationary")

# Fit using auto.arima and correlation analysis
scomfit1 <- auto.arima(scomTrain, seasonal = "FALSE")
summary(scomfit1)
scomfit2 <- Arima(scomTrain, order = c(1, 1, 2))
summary(scomfit2)

eqtyfit1 <- auto.arima(eqtyTrain, seasonal = "FALSE")
summary(eqtyfit1)
eqtyfit2 <- Arima(eqtyTrain, order = c(2, 1, 1))
summary(eqtyfit2)

ftsefit1 <- auto.arima(ftseTrain, seasonal = "FALSE")
summary(ftsefit1)
ftsefit2 <- Arima(ftseTrain, order = c(1, 1, 3))
summary(ftsefit2)

# Create five-day forecasts with the selected (lower-AIC) models
scomfcast <- forecast(scomfit1, h = 5)
eqtyfcast <- forecast(eqtyfit2, h = 5)
ftsefcast <- forecast(ftsefit2, h = 5)

scomvalues <- as.numeric(scomfcast$mean)
eqtyvalues <- as.numeric(eqtyfcast$mean)
ftsevalues <- as.numeric(ftsefcast$mean)

# Undo the log applied earlier
scomfinalValues <- exp(scomvalues)
eqtyfinalValues <- exp(eqtyvalues)
ftsefinalValues <- exp(ftsevalues)

# Calculate percentage errors and build results tables
scomerrors <- round((scom$`Day Price`[3215:3219] - scomfinalValues) /
                      scom$`Day Price`[3215:3219], 4) * 100
scomdf <- data.frame(scom$`Day Price`[3215:3219], scomfinalValues, scomerrors)

eqtyerrors <- round((eqtyTr$`Day Price`[2991:2995] - eqtyfinalValues) /
                      eqtyTr$`Day Price`[2991:2995], 4) * 100
eqtydf <- data.frame(eqtyTr$`Day Price`[2991:2995], eqtyfinalValues, eqtyerrors)

ftseerrors <- round((nseFTSE15$`Day Price`[2071:2075] - ftsefinalValues) /
                      nseFTSE15$`Day Price`[2071:2075], 4) * 100
ftsedf <- data.frame(nseFTSE15$`Day Price`[2071:2075], ftsefinalValues, ftseerrors)

names(scomdf) <- c("Actual Price", "Forecasted Price", "Forecast Error (%)")
names(eqtydf) <- c("Actual Price", "Forecasted Price", "Forecast Error (%)")
names(ftsedf) <- c("Actual Price", "Forecasted Price", "Forecast Error (%)")

view(scomdf)
view(eqtydf)
view(ftsedf)
