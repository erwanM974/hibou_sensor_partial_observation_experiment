#
# Copyright 2022 Erwan Mahe (github.com/erwanM974)
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#     http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#



rm(list=ls())
# ======================================================================
library(ggplot2)
# ======================================================================


# ======================================================================
read_exp_report <- function(file_path) {
  report <- read.table(file=file_path, 
                       header = FALSE, 
                       sep = ",",
                       blank.lines.skip = TRUE, 
                       fill = TRUE)
  
  names(report) <- as.matrix(report[1, ])
  report <- report[-1, ]
  report[] <- lapply(report, function(x) type.convert(as.character(x)))
  report
}
# ======================================================================

prepare_data <- function(mydata) {
  copied_data <- data.frame( mydata )
  copied_data$obs <- as.factor(copied_data$obs)
  copied_data$technique <- as.factor(copied_data$technique)
  copied_data
}

# ======================================================================

plot_fullobs <- function(mydata) {
  fullobs_mus <- prepare_data(mydata)
  fullobs_mus <- fullobs_mus[fullobs_mus$isPass == "True",]
  fullobs_mus <- fullobs_mus[fullobs_mus$obs == 100,]
  fullobs_mus$lengthCat <- cut(fullobs_mus$length, breaks=c(0, 50, 100, 150, 350, 700, Inf), labels=c("0-50","51-100","101-150","151-350","351-700","701+"))
  # ====
  p <- ggplot(fullobs_mus, aes(x=lengthCat, y=time,fill=technique)) + 
    geom_boxplot() + scale_fill_manual(values=c("green", "blue", "red", "yellow")) + scale_y_log10() +
    ylab("time (log10 scale)") + xlab("length category") + ggtitle("Full accepted multi-traces")
  p
}

# ======================================================================

plot_failure <- function(mydata) {
  fail_mus <- prepare_data(mydata)
  fail_mus <- fail_mus[fail_mus$isPass == "False",]
  fail_mus$lengthCat <- cut(fail_mus$length, breaks=c(0, 50, 100, 150, 350, 700, Inf), labels=c("0-50","51-100","101-150","151-350","351-700","701+"))
  # ====
  fail_mus<-filter(fail_mus, fail_mus$lengthCat== "0-50" | fail_mus$technique == "hid_wtloc" | fail_mus$technique == "sim_wtloc")
  fail_mus <- na.omit(fail_mus)
  p <- ggplot(fail_mus, aes(x=lengthCat, y=time,fill=technique)) + 
    geom_boxplot() + scale_fill_manual(values=c("green", "blue", "red", "yellow")) + scale_y_log10() +
    ylab("time (log10 scale)") + xlab("length category") + ggtitle("Failure multi-traces")
  p
}

# ======================================================================

plot_per_obs <- function(mydata) {
  perobs_mus <- prepare_data(mydata)
  perobs_mus <- perobs_mus[perobs_mus$isPass == "True",]
  perobs_mus$origLengthCat <- cut(perobs_mus$orig_length, breaks=c(0, 50, 100, 150, 350, 700, Inf), labels=c("0-50","51-100","101-150","151-350","351-700","701+"))
  perobs_mus <- perobs_mus[perobs_mus$origLengthCat == "701+",]
  # ====
  perobs_mus<-filter(perobs_mus, (perobs_mus$technique == "hid_wtloc") | (perobs_mus$technique == "sim_wtloc"))
  perobs_mus <- na.omit(perobs_mus)
  p <- ggplot(perobs_mus, aes(x=obs, y=time,fill=technique)) + 
    geom_boxplot() + scale_fill_manual(values=c("blue", "yellow")) + scale_y_log10() + 
    ylab("time (log10 scale)") + ggtitle("Multi-trace prefixes (original length category 701+)")
  p
}

# ======================================================================

mydata <- read_exp_report("./hibou_sensor_partial_observation_experiment/senmed_1to40.csv")


plot_fullobs(mydata)

plot_failure(mydata)

plot_per_obs(mydata)


# ======================================================================

print_data_detail <- function(mydata) {
  # ====
  print( sprintf("total number of multi-traces %d", nrow(mydata)) )
  for (cat_lab in c("0-50","51-100","101-150","151-350","351-700","701+")) {
    at_length_cat <- mydata[mydata$lengthCat == cat_lab,]
    print( sprintf("%d total multi-traces in length category %s", nrow( at_length_cat ), cat_lab ) )
  }
  # ====
  pass_mus <- mydata[mydata$isPass == "True",]
  fullobs_mus <- pass_mus[pass_mus$obs == "100",]
  print( sprintf("number of fully observed accepted multi-traces (originals) %d", nrow(fullobs_mus)) )
  print( sprintf("min length of original multi-traces %d", min( fullobs_mus$length ) ) )
  print( sprintf("max length of original multi-traces %d", max( fullobs_mus$length ) ) )
  for (cat_lab in c("0-50","51-100","101-150","151-350","351-700","701+")) {
    at_length_cat <- fullobs_mus[fullobs_mus$lengthCat == cat_lab,]
    print( sprintf("%d full multi-traces in length category %s", nrow( at_length_cat ), cat_lab ) )
  }
  # ====
  partobs_mus <- pass_mus[pass_mus$obs != "100",]
  print( sprintf("number of (strictly) partially observed multi-traces (strict prefixes) %d", nrow(partobs_mus)) )
  for (cat_lab in c("0-50","51-100","101-150","151-350","351-700","701+")) {
    at_length_cat <- partobs_mus[partobs_mus$lengthCat == cat_lab,]
    print( sprintf("%d partial multi-traces in length category %s", nrow( at_length_cat ), cat_lab ) )
  }
  # ====
  fail_mus <- mydata[mydata$isPass == "False",]
  print( sprintf("number of mutant multi-traces (failure traces) %d", nrow(fail_mus)) )
  for (cat_lab in c("0-50","51-100","101-150","151-350","351-700","701+")) {
    at_length_cat <- fail_mus[fail_mus$lengthCat == cat_lab,]
    print( sprintf("%d failure traces in length category %s", nrow( at_length_cat ), cat_lab ) )
  }
}

print_method_detail <- function(method_name,mydata) {
  print( sprintf("number of times the timeout is exceeded using %s : %d", method_name, sum(is.na(mydata$time)) ) )
  # ====
  for (cat_lab in c("0-50","51-100","101-150","151-350","351-700","701+")) {
    at_length_cat <- mydata[mydata$lengthCat == cat_lab,]
    time_summary <- summary(at_length_cat$time)
    print( sprintf("time summary at length category %s using %s :", cat_lab,method_name ) )
    print( time_summary )
  }
}

report_detail <- function(mydata) {
  hid_wtloc <- mydata[mydata$technique == "hid_wtloc",]
  sim_wtloc <- mydata[mydata$technique == "sim_wtloc",]
  hid_noloc <- mydata[mydata$technique == "hid_noloc",]
  sim_noloc <- mydata[mydata$technique == "sim_noloc",]
  # ====
  print_data_detail(sim_wtloc)
  # ====
  print_method_detail("hiding with local analyses", hid_wtloc)
  print_method_detail("simulation with local analyses", sim_wtloc)
  print_method_detail("hiding without local analyses", hid_noloc)
  print_method_detail("simulation without local analyses", sim_noloc)
}

prep_dat <- prepare_data(mydata)
prep_dat$lengthCat <- cut(prep_dat$length, breaks=c(0, 50, 100, 150, 350, 700, Inf), labels=c("0-50","51-100","101-150","151-350","351-700","701+"))
report_detail(prep_dat)















