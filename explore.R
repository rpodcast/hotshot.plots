# send output to Viewer rather than external X11 window
#options(rgl.useNULL = TRUE, rgl.printRglwidget = TRUE)

library(dplyr)
library(tidyr)
library(purrr)
library(ggplot2)
library(rayshader)
library(rayrender)

#library(rgl)
source("utils/hotshot_data.R")
source("utils/hotshot_points.R")
source("utils/fct_data_helpers.R")

raw_df <- readRDS("data/data.rds")

car_df <- gen_tidy_racers(hotshot_data) %>%
  select(driver = driver_name, car = car_name, type, speed, acceleration, drift)

df2 <- gen_tidy_race_data(raw_df, hotshot_data) %>%
  left_join(car_df, by = c("driver", "car"))

df_summ_gp <- gen_summary_gp_data(df2)

df_gp_summ <- gen_grandprix_summary(df2)
df_summ_overall <- gen_summary_overall(df_summ_gp)

plot_data <- gen_plot_data(df2)


# gg <- ggplot(diamonds, aes(x, depth)) +
#   stat_density_2d(aes(fill = stat(nlevel)), 
#                   geom = "polygon",
#                   n = 100,bins = 10,contour = TRUE) +
#   facet_wrap(clarity~.) +
#   scale_fill_viridis_c(option = "A")
# 
# 
# gg


# continuous variables to try
# - points
# - margin of victory
# - chosen car's drift, speed, acceleration rankings


hotshot_gg <- ggplot(df2, aes(x = player_name, y = drift, color = points)) +
  geom_point(size = 2) +
  facet_wrap(track ~ .)

plot_gg(
  hotshot_gg, 
  height = 7, 
  width = 7, 
  multicore = TRUE, 
  pointcontract = 0.7, 
  soliddepth = -200, 
  raytrace = FALSE,
  windowsize = c(1100, 700),
)

save_obj("hotshot_ggplot.obj")
rgl::rgl.close()

disk(
  radius = 1000,
  y = -1,
  material = diffuse(checkerperiod = 6, "#0d401b", color="#496651")
) %>%
add_object(
  obj_model("hotshot_ggplot.obj", y = -0.02, texture = TRUE, scale_obj = 1/100)
) %>%
add_object(
  sphere(y = 30, z = 10, radius = 5, material = light(intensity = 40))
) %>%
render_scene(lookfrom = c(20,20,20), fov = 0, ortho_dimensions = c(30, 30), width = 800, height = 800)

library(rayimage)
library(raster)

plot_image("raysurface.png")
vals <- locator(n=20)
