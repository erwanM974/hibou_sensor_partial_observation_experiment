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
library(plotly)  
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

# ======================================================================
plot_4_surfaces <- function(dataf) {
  myplot <- plot_ly(
    x = dataf$outer_loop_n,
    y = dataf$obs,
    showscale = TRUE
  ) %>% #layout(zaxis = list(type = "log")) %>%
    add_trace(
      z = log(dataf$sensor_mediation_hid_wtloc),opacity=.3,
      type = 'mesh3d',facecolor = rep("blue",1000)
    ) %>%
    add_trace(
      z = log(dataf$sensor_mediation_hid_noloc),opacity=.3,
      type = 'mesh3d',facecolor = rep("green",1000)
    ) %>%
    add_trace(
      z = log(dataf$sensor_mediation_sim_wtloc),opacity=.3,
      type = 'mesh3d',facecolor = rep("orange",1000)
    ) %>%
    add_trace(
      z = log(dataf$sensor_mediation_sim_noloc),opacity=.3,
      type = 'mesh3d',facecolor = rep("red",1000)
    )%>%
    layout(title = "",
           scene = list(xaxis = list(title = "loop instances"), 
                        yaxis = list(title = "observation"), 
                        zaxis = list(title = "time (log10)")))
  myplot 
}
# ======================================================================

# ======================================================================
plot_3_surfaces <- function(dataf) {
  myplot <- plot_ly(
    x = dataf$outer_loop_n,
    y = dataf$obs,
    showscale = TRUE
  ) %>%
    add_trace(
      z = dataf$sensor_mediation_hid_wtloc,opacity=.5,
      type = 'mesh3d',facecolor = rep("blue",1000)
    ) %>%
    add_trace(
      z = dataf$sensor_mediation_hid_noloc,opacity=.5,
      type = 'mesh3d',facecolor = rep("green",1000)
    ) %>%
    add_trace(
      z = dataf$sensor_mediation_sim_wtloc,opacity=.5,
      type = 'mesh3d',facecolor = rep("orange",1000)
    )%>%
    layout(title = "",
           scene = list(xaxis = list(title = "loop instances"), 
                        yaxis = list(title = "observation"), 
                        zaxis = list(title = "time")))
  myplot 
}
# ======================================================================

# ======================================================================
plot_2_surfaces_hid <- function(dataf) {
  myplot <- plot_ly(
    x = dataf$outer_loop_n,
    y = dataf$obs,
    showscale = TRUE
  ) %>%
    add_trace(
      z = dataf$sensor_mediation_hid_wtloc,opacity=.5,
      type = 'mesh3d',facecolor = rep("blue",1000)
    ) %>%
    add_trace(
      z = dataf$sensor_mediation_hid_noloc,opacity=.5,
      type = 'mesh3d',facecolor = rep("green",1000)
    )%>%
    layout(title = "",
           scene = list(xaxis = list(title = "loop instances"), 
                        yaxis = list(title = "observation"), 
                        zaxis = list(title = "time")))
  myplot 
}
# ======================================================================

# ======================================================================
plot_2_surfaces_loc <- function(dataf) {
  myplot <- plot_ly(
    x = dataf$outer_loop_n,
    y = dataf$obs,
    showscale = TRUE
  ) %>%
    add_trace(
      z = dataf$sensor_mediation_hid_wtloc,opacity=.5,
      type = 'mesh3d',facecolor = rep("blue",1000)
    ) %>%
    add_trace(
      z = dataf$sensor_mediation_sim_wtloc,opacity=.5,
      type = 'mesh3d',facecolor = rep("orange",1000)
    )%>%
    layout(title = "",
           scene = list(xaxis = list(title = "loop instances"), 
                        yaxis = list(title = "observation"), 
                        zaxis = list(title = "time")))
  myplot 
}
# ======================================================================



mydata <- read_exp_report("./sensor_exp_hibou/sensor_mediation.csv")

pass_mus <- mydata[mydata$isPass == "True",]

fail_mus <- mydata[mydata$isPass == "False",]


plot_3_surfaces(pass_mus)

plot_4_surfaces(pass_mus)

plot_4_surfaces(fail_mus)

plot_2_surfaces_loc(fail_mus)





