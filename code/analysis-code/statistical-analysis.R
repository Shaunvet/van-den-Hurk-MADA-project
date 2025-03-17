###############################
# analysis script
#
#this script loads the processed, cleaned data, does a simple analysis
#and saves the results to the results folder

#load needed packages. make sure they are installed.
#install.packages("gt")
library(ggplot2) #for plotting
library(broom) #for cleaning up output from lm()
library(here) #for data loading/saving
library(tidyverse)
library(tidymodels)
library(gt)
library(stringr)
library(patchwork)


#path to data
#note the use of the here() package and not absolute paths
data_location <- here::here("data","processed-data","final_processed_data.rds")

#load data. 
final_processed_data <- readRDS(data_location)

# Extract key datasets
processed_data_no_percent <- final_processed_data[["processed_data_no_percent"]]
county_race_sex <- final_processed_data[["county_race_sex"]]
county_race <- final_processed_data[["county_race"]]
county_sex <- final_processed_data[["county_sex"]]
county_overall <- final_processed_data[["county_overall"]]

######################################
#Data fitting/statistical analysis
######################################

############################

# Exploring relationships between mortality rates and individual predictors

# Relationship between mortality and race
race_plot <- ggplot(county_race, aes(x = race_ethnicity, y = mortalities)) +
  geom_boxplot() +
  theme_minimal() +
  labs(title = "Mortality Rates by Race/Ethnicity", x = "Race/Ethnicity", y = "Mortality Rate") +
  theme(axis.text.x = element_text(size = 10)) +
  scale_x_discrete(labels = function(x) stringr::str_wrap(x, width = 10))

print(race_plot)
ggsave(here::here("products", "manuscript", "supplement", "mortality_by_race.png"), plot = race_plot)

# Relationship between mortality and sex
sex_plot <- ggplot(county_sex, aes(x = sex, y = mortalities)) +
  geom_boxplot() +
  theme_minimal() +
  labs(title = "Mortality Rates by Sex", x = "Sex", y = "Mortality Rate")

print(sex_plot)
ggsave(here::here("products", "manuscript", "supplement", "mortality_by_sex.png"), plot = sex_plot)


#### First model fit

# Checking the relationship between mortality and year
lm_model_year <- lm(mortalities ~ Year, data = county_overall)
lm_results_year <- broom::tidy(lm_model_year)

# Display and save the regression results
print(lm_results_year)
saveRDS(lm_results_year, file = here::here("products", "manuscript", "supplement", "lm_results_year.rds"))

# Plot linear regression results
lm_plot_year <- ggplot(county_overall, aes(x = Year, y = mortalities)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  theme_minimal() +
  labs(title = "Linear Regression: Mortality Rates Over Time", x = "Year", y = "Mortality Rate")

print(lm_plot_year)
ggsave(here::here("products", "manuscript", "supplement", "lm_plot_year.png"), plot = lm_plot_year)



### Multivariable Generalized Linear Model (GLM)
# Examining multiple predictors
glm_model <- glm(mortalities ~ Year + race_ethnicity + sex, data = county_race_sex, family = gaussian())
glm_results <- broom::tidy(glm_model)

# Display and save the GLM results
print(glm_results)
saveRDS(glm_results, file = here::here("products", "manuscript", "supplement", "glm_results.rds"))


# Plot GLM predictions
  county_race_sex$predicted_mortalities <- predict(glm_model, type = "response")
  glm_plot <- ggplot(county_race_sex, aes(x = Year, y = predicted_mortalities, color = race_ethnicity)) +
    geom_line(size = 1) +
    theme_minimal() +
    labs(title = "GLM Predictions: Mortality Rates by Year and Race/Ethnicity", x = "Year", y = "Predicted Mortality Rate", color = "Race/Ethnicity") +
    scale_x_continuous(breaks = seq(min(county_race_sex$Year, na.rm = TRUE), max(county_race_sex$Year, na.rm = TRUE), by = 5)) +
    theme(legend.position = "right", legend.text = element_text(size = 10), legend.key.size = unit(0.4, "cm"), legend.spacing.y = unit(0.2, "cm"), axis.text.x = element_text(angle = 45, hjust = 1))
  
  print(glm_plot)
  ggsave(here::here("products", "manuscript", "supplement", "glm_plot.png"), plot = glm_plot)
  


#explore whether interactions exist between year and race/sex:

glm_model_interaction <- glm(mortalities ~ Year * race_ethnicity + sex, 
                             data = county_race_sex, 
                             family = gaussian())

glm_results_interaction <- broom::tidy(glm_model_interaction)
print(glm_results_interaction)

saveRDS(glm_results_interaction, file = here::here("products", "manuscript", "supplement", "glm_results_interaction.rds"))


# Plot the interaction model results
county_race_sex$predicted_mortalities_interaction <- predict(glm_model_interaction, type = "response")
glm_interaction_plot <- ggplot(county_race_sex, aes(x = Year, y = predicted_mortalities_interaction, color = race_ethnicity)) +
  geom_line(size = 1) +
  theme_minimal() +
  labs(title = "GLM Interaction Model: Mortality Trends by Year and Race", x = "Year", y = "Predicted Mortality Rate", color = "Race/Ethnicity") +
  scale_x_continuous(breaks = seq(min(county_race_sex$Year, na.rm = TRUE), max(county_race_sex$Year, na.rm = TRUE), by = 5)) +
  theme(legend.position = "right", legend.text = element_text(size = 10), legend.key.size = unit(0.4, "cm"), legend.spacing.y = unit(0.2, "cm"), axis.text.x = element_text(angle = 45, hjust = 1))

print(glm_interaction_plot)
ggsave(here::here("products", "manuscript", "supplement", "glm_interaction_plot.png"), plot = glm_interaction_plot)



#Evaluating spatial patterns for mortality data for all races together and individually:

#Convert dataset to an SF spatial object
county_race_sex_sf <- county_race_sex %>%
  st_as_sf(coords = c("X_long", "Y_lat"), crs = 4326, remove = FALSE)

# Spatial plot for all races
spatial_plot_all <- ggplot() +
  geom_sf(data = county_race_sex_sf, aes(color = mortalities), size = 0.7) +
  scale_color_viridis_c() +
  theme_minimal() +
  labs(title = "Spatial Distribution of Mortality Rates (All Races)", x = "Longitude", y = "Latitude", color = "Mortality Rate")

print(spatial_plot_all)
ggsave(here::here("products", "manuscript", "supplement", "spatial_plot_all.png"), plot = spatial_plot_all)

# Spatial plot for Black race
black_race_sf <- county_race_sex_sf %>% filter(race_ethnicity == "Black")
black_spatial_plot <- ggplot() +
  geom_sf(data = black_race_sf, aes(color = mortalities), size = 0.7) +
  scale_color_viridis_c() +
  theme_minimal() +
  labs(title = "Spatial Distribution of Mortality Rates (Black Race)", x = "Longitude", y = "Latitude", color = "Mortality Rate")

print(black_spatial_plot)
ggsave(here::here("products", "manuscript", "supplement", "black_spatial_plot.png"), plot = black_spatial_plot)

# Spatial plot for White race
white_race_sf <- county_race_sex_sf %>% filter(race_ethnicity == "White")
white_spatial_plot <- ggplot() +
  geom_sf(data = white_race_sf, aes(color = mortalities), size = 0.7) +
  scale_color_viridis_c() +
  theme_minimal() +
  labs(title = "Spatial Distribution of Mortality Rates (White Race)", x = "Longitude", y = "Latitude", color = "Mortality Rate")

print(white_spatial_plot)
ggsave(here::here("products", "manuscript", "supplement", "white_spatial_plot.png"), plot = white_spatial_plot)


# Spatial plot for Hispanic race
hispanic_sf <- county_race_sex_sf %>% filter(race_ethnicity == "Hispanic")
hispanic_spatial_plot <- ggplot() +
  geom_sf(data = hispanic_sf, aes(color = mortalities), size = 0.7) +
  scale_color_viridis_c() +
  theme_minimal() +
  labs(title = "Spatial Distribution of Mortality Rates (Hispanic)", x = "Longitude", y = "Latitude", color = "Mortality Rate")
ggsave(here::here("products", "manuscript", "supplement", "hispanic_spatial_plot.png"), plot = hispanic_spatial_plot)



# Spatial plot for American Indian and Alaska Native race
native_sf <- county_race_sex_sf %>% filter(race_ethnicity == "American Indian and Alaska Native")
native_spatial_plot <- ggplot() +
  geom_sf(data = native_sf, aes(color = mortalities), size = 0.7) +
  scale_color_viridis_c() +
  theme_minimal() +
  labs(title = "Spatial Distribution of Mortality Rates\n(American Indian and Alaska Native)", x = "Longitude", y = "Latitude", color = "Mortality Rate")
ggsave(here::here("products", "manuscript", "supplement", "native_spatial_plot.png"), plot = native_spatial_plot)


# Spatial plot for Asian and Pacific Islander race
asian_sf <- county_race_sex_sf %>% filter(race_ethnicity == "Asian and Pacific Islander")
asian_spatial_plot <- ggplot() +
  geom_sf(data = asian_sf, aes(color = mortalities), size = 0.7) +
  scale_color_viridis_c() +
  theme_minimal() +
  labs(title = "Spatial Distribution of Mortality Rates\n(Asian and Pacific Islander)", x = "Longitude", y = "Latitude", color = "Mortality Rate")
ggsave(here::here("products", "manuscript", "supplement", "asian_spatial_plot.png"), plot = asian_spatial_plot)



# Combine all of the spatial charts using patchwork
combined_spatial_plot <- (spatial_plot_all | black_spatial_plot | white_spatial_plot) /
  (hispanic_spatial_plot | native_spatial_plot |
  asian_spatial_plot)

# Print and save the combined spatial plot
print(combined_spatial_plot)
ggsave(here::here("products", "manuscript", "supplement", "combined_spatial_plot.png"), 
       plot = combined_spatial_plot, width = 14, height = 10)








  