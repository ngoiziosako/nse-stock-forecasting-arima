# Stock Price Forecasting Using ARIMA (Nairobi Securities Exchange)

BSc Actuarial Science capstone project, The Catholic University of Eastern Africa (September 2021).
Group project by Lynette Ngoizi Osako, Shadrack Kiplagat Koech, and Kevin Makokha, with equal contributions from all three members.

## Overview

This project applies ARIMA time series models to daily price data from the Nairobi Securities Exchange (NSE) to produce 5-day forecasts for:

- **Safaricom Plc**
- **Equity Group Holdings Plc**
- **NSE FTSE 15 Share Index**

The goal was to test how well a classical univariate time series model performs for short-term forecasting, and whether R's `auto.arima` picks better models than manual identification from ACF/PACF plots.

## Data

- **Source:** Synergy Systems Limited, a licensed data vendor of the NSE
- **Coverage:** January 2007 – April 2021, as 15 yearly CSV files covering all NSE-traded securities
- **Size:** 221,766 rows × 13 columns after combining the files

> **The dataset is not included in this repository.** It was provided under license by the data vendor and cannot be redistributed.

## Methodology

1. **Data wrangling (R / tidyverse):** combined the 15 yearly CSV files into one dataframe, converted date strings to date objects, and split out the three series.
2. **Cleaning:**
   - Removed two IPO-period records for Safaricom (a 400%+ jump between the first two entries).
   - Excluded Equity's early high-volatility period (2007–mid 2009).
   - Identified and corrected an outlier introduced by weekend gap-filling (`tsclean` from the `forecast` package).
3. **Stationarity:** STL decomposition with seasonal adjustment, log transformation, and first/second differencing. Stationarity was confirmed with the Augmented Dickey-Fuller test.
4. **Model selection:** compared `auto.arima` suggestions against models identified from ACF/PACF plots, choosing the lower AIC.
5. **Evaluation:** held out the last 5 trading days, forecast them, and computed percentage error against actual prices.

## Results

| Series | Selected model | Chosen by | Avg. absolute error (5-day holdout) | Max daily error |
|---|---|---|---|---|
| Safaricom Plc | ARIMA(3,1,2) | auto.arima | ≈2.7% | 4.09% |
| Equity Group Holdings | ARIMA(2,1,1) | ACF/PACF analysis | ≈1.7% | 2.10% |
| NSE FTSE 15 Index | ARIMA(1,1,3) | ACF/PACF analysis | ≈1.0% | 1.70% |

Forecast errors generally grew as the forecast horizon lengthened, which suggests ARIMA is best suited to very short-term forecasting.

## Limitations (looking back)

- **Small test set:** evaluation used a single 5-day holdout. A rolling-origin evaluation over many periods would give a more reliable estimate of accuracy.
- **No naive baseline:** results were not compared against a random-walk ("tomorrow = today") forecast, which is the standard benchmark for stock prices.
- **Seasonality:** a seasonal ARIMA (SARIMA) model and a shorter, more recent training window were recommended as next steps in the original report.

## Repository contents

| File | Description |
|---|---|
| `README.md` | This summary |
| `arima_forecasting.R` | R code as submitted in the report's appendix (see note in the file) |

The full written report (methodology, figures, and literature review) is available on request.

## Tools

R · forecast · tseries · TSstudio · tidyverse · xts · ggplot2 · plotly
