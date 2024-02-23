# Import tidyverse and ggplot2 since the packages were already installed
library(tidyverse)
library(ggplot2)

# Install janitor and hms packages then download the library. We also need dply and tidyr but they were already installed in my case.
install.packages("here")
install.packages("janitor")
library(janitor)
library(hms)

# Now we'll import the csv files for the cats data, starting with the tracking data. We'll use the pipe operator here to include clean_names() function to ensure that the column names are unique and consist only of the '_' character, numbers, and letters.
cats_nz <- read_csv("/Users/yanhua1/Downloads/pet_cats_nz.csv") %>% 
  clean_names()

# Next, we'll import the reference data with clean column names.
cats_reference <- read_csv("/Users/yanhua1/Downloads/pet_cats_nz_reference_data.csv") %>% 
  clean_names()

# We'll check out all the columns and the data using the glimpse() function
glimpse(cats_nz)
glimpse(cats_reference)

# Check whether all the event ids are unique (if the number of rows matches with the result)
length(unique(cats_nz$event_id))

# Clean the data sets
# Now we'll drop the columns that are not needed and change some column names to match the column names from the reference data frame. We'll name this new data frame cats_nz_clean.
cats_nz_clean <-cats_nz %>% 
  select(
    tag_id = tag_local_identifier,
    event_id,
    timestamp,
    location_lat,
    location_long,
    algorithm_marked_outlier,
    manually_marked_outlier,
    animal_id = individual_local_identifier
  ) %>%  
  # Encode FALSE for the outlier columns.
  tidyr::replace_na(
    list(
      algorithm_marked_outlier = FALSE,
      manually_marked_outlier = FALSE
    )
  )

# Check if there is still any rows with NA values in any columns by using the below syntax.
sum(is.na(cats_nz_clean))

# Create new columns for hour, day of week, month and year.
cats_nz_clean$hour <- hour(cats_nz_clean$timestamp)
cats_nz_clean$day_of_week <- weekdays(as.Date(cats_nz$timestamp))
cats_nz_clean$month <- format(as.Date(cats_nz_clean$timestamp, format="%Y/%m/%d"),"%m")
cats_nz_clean$year <- format(as.Date(cats_nz_clean$timestamp, format="%Y/%m/%d"),"%Y")

# A look into the final cats_nz_clean data frame 
glimpse(cats_nz_clean)
colnames(cats_nz_clean)


# To avoid dropping the columns in the cats_reference dataframe that may have multiple uniques values, we'll use unique() function to check.
unique(cats_reference$duty_cycle)
unique(cats_reference$attachment_type)
unique(cats_reference$deployment_end_type)
unique(cats_reference$manipulation_type)

# Now, we'll tidy the cats_reference data frame.
cats_reference_clean <- cats_reference %>%
  # Create a new column from animal_life_stage column, called age_years and the unit is year.
  mutate(
    age_years = case_when(
      str_detect(animal_life_stage, fixed("<")) ~ 0L,
      str_detect(animal_life_stage, "year") ~ str_extract(animal_life_stage, "\\d+") %>% as.integer(),
      TRUE ~ NA_integer_
    )
  ) %>%
  # Extract values from the animal_comments column and create two new columns: hunt and prey_p_month.
  separate_wider_delim(
    animal_comments,
    "; ",
    names = c("hunt", "prey_p_month")
  ) %>%
  mutate(
    hunt = case_when(
      str_detect(hunt, "Yes") ~ TRUE,
      str_detect(hunt, "No") ~ FALSE,
      TRUE ~ NA
    ),
    prey_p_month = as.numeric(str_remove(prey_p_month, "prey_p_month: "))
  ) %>%
  # Extract values from the manipulation_comments column and create two new columns: hrs_indoors and inside_overnight.
  separate_wider_delim(
    manipulation_comments,
    "; ",
    names = c("hrs_indoors", "inside_overnight")
  ) %>%
  mutate(
    hrs_indoors = as.numeric(str_remove(hrs_indoors, "hrs_indoors: ")),
    inside_overnight = case_when(
      str_detect(inside_overnight, "yes") ~ TRUE,
      str_detect(inside_overnight, "no") ~ FALSE,
      TRUE ~ NA
    )
  ) %>%
  # Calculate number of hours that the device was deployed to each cat
  mutate(
    deploy_hours = round(difftime(deploy_off_date, deploy_on_date, units = "hours")),
    deploy_days = round(difftime(deploy_off_date, deploy_on_date, units = "days"), 2)
  ) %>%
  # Drop the columns that we do not need
  select(
    -animal_taxon,
    -animal_life_stage,
    -attachment_type,
    -data_processing_software,
    -deployment_end_type,
    -duty_cycle,
    -deployment_id,
    -manipulation_type,
    -tag_manufacturer_name,
    -tag_mass,
    -tag_model,
    -tag_readout_method,
    -study_site
  ) 

# Check whether all cat names are unique and if the number matches with the number of rows from cats_reference_clean dataframe
length(unique(cats_reference_clean$animal_id))

# A look into the final cats_reference_clean data frame 
glimpse(cats_reference_clean)
colnames(cats_reference_clean)


# ------------------- Analysis ------------------
# Check for total number of events from the cats_nz_clean data frame
nrow(cats_nz_clean)

# Total numbers of events that occurred for each cat
total_events_cat <- cats_nz_clean %>% 
  group_by(animal_id) %>% 
  count(animal_id) %>% 
  arrange(desc(n)) %>% 
  rename("total_number" = "n") # Replace the column named n with total_number

# Average number of events per cat and total number of event that occurred per hour
hour_final <- cats_nz_clean %>%
  group_by(hour, animal_id) %>%
  summarise(total_number = n()) %>%
  group_by(hour) %>%
  summarise(avg = round(mean(total_number)),
            total = sum(total_number),
            num_cat = n_distinct(animal_id))

# Average number of events per cat for each day of the week
day_final <- cats_nz_clean %>%
  group_by(day_of_week, animal_id) %>%
  summarise(total_number = n()) %>%
  group_by(day_of_week) %>%
  summarise(avg = round(mean(total_number)),
            total = sum(total_number),
            num_cat = n_distinct(animal_id))

# Average number of events per cat and total number of events for each month
month_final <- cats_nz_clean %>% 
  group_by(month, animal_id) %>% 
  summarise(total_number = n()) %>% 
  group_by(month) %>% 
  summarise(avg = round(mean(total_number)),
            total = sum(total_number),
            num_cat = n_distinct(animal_id))

# Average number of events per cat and total number of events for each year
year_final <- cats_nz_clean %>%
  group_by(year, animal_id) %>%
  summarise(total_number = n()) %>%
  group_by(year) %>%
  summarise(avg = round(mean(total_number)),
            total = sum(total_number),
            num_cat = n_distinct(animal_id))

# Calculating the number of cats who hunts
hunt_counts <- cats_reference_clean %>% 
  count(hunt) 

# Calculate the average, minimum, and maximum ages
summary_age <- cats_reference_clean %>%
  summarise(
    average_age = round(mean(age_years, na.rm = TRUE), 2),
    min_age = min(age_years, na.rm = TRUE),
    max_age = max(age_years, na.rm = TRUE)
  )
# Print the dataframe
print(summary_age)
 

# Calculate the average, minimum, and maximum indoors hours
summary_indoors <- cats_reference_clean %>%
  summarise(
    average_indoors = round(mean(hrs_indoors, na.rm = TRUE), 2),
    min_indoors = min(hrs_indoors, na.rm = TRUE),
    max_indoors = max(hrs_indoors, na.rm = TRUE)
  )
# Print the results
print(summary_indoors)


# Calculate the summary statistics for preys per month
summary_prey <- cats_reference_clean %>%
  summarise(
    average_prey = round(mean(prey_p_month, na.rm = TRUE), 2),
    min_prey = min(prey_p_month, na.rm = TRUE),
    max_prey = max(prey_p_month, na.rm = TRUE)
  )
# Print the results
print(summary_prey)


# Calculate the summary statistics for deployed hours
summary_deployed_hours <- cats_reference_clean %>%
  summarise(
    average_deployed_hours = round(mean(as.numeric(gsub(" hours", "", deploy_hours)), na.rm = TRUE), 2),
    min_deployed_hours = min(as.numeric(gsub(" hours", "", deploy_hours)), na.rm = TRUE),
    max_deployed_hours = max(as.numeric(gsub(" hours", "", deploy_hours)), na.rm = TRUE)
  )
# Print the results
print(summary_deployed_hours)


# Compare the number of events occurred for each cat with other aspects
# Join total_event_cats dataframe with cats_reference_clean dataframe
cats_joined <- cats_reference_clean %>% 
  full_join(y = total_events_cat, by=c("animal_id"))


# Find average number of events a cat takes in a day separated by sex, excluding NA values in animal_sex
avg_day <- cats_joined %>%
  filter(!is.na(animal_sex)) %>%  # Filter out NA values in animal_sex
  group_by(animal_sex) %>%
  summarise(
    total_number_sum = sum(total_number),
    deploy_days_total = sum(as.numeric(deploy_days), na.rm = TRUE),  # Convert deploy_days to numeric
    avg_per_deploy_day = round(total_number_sum / deploy_days_total, 2)
  )


# ----------------- Visualisation ----------------
# Top 10 cats with the most total events 
ggplot(total_events_cat[tail(order(total_events_cat$total_number), 10), ], ) + 
  geom_col(mapping = aes(x = reorder(animal_id, -total_number), y = total_number, fill= animal_id)) +
  geom_text(aes(x= animal_id, y = total_number, label = total_number), nudge_y = 100, size = 3) +
  labs(y = "Total number of events", x = "animal_id") +
  ggtitle("Top 10 cats with the most events")

# Top 10 cats with the least total events
ggplot(total_events_cat[head(order(total_events_cat$total_number), 10), ], ) + 
  geom_col(mapping = aes(x = reorder(animal_id, total_number), y = total_number, fill= animal_id)) +
  geom_text(aes(x= animal_id, y = total_number, label = total_number), nudge_y = 8, size = 3) +
  labs(y = "Total number of events", x = "animal_id") +
  ggtitle("Top 10 cats with the least events") 

# Average number of events per cat for each hour
ggplot(data = hour_final, mapping = aes(x = hour, y = avg)) +
  geom_line(color = "indianred") +
  geom_point( size=1, color = "indianred4") +
  labs(y = "Average number of events per cat", x = "Hour") +
  ggtitle("Average number of events per cat for each hour")+
  geom_text(data = rbind(hour_final[which.min(hour_final$avg), ], hour_final[which.max(hour_final$avg),]), aes(x = hour, y = avg, label = avg), nudge_y = 0.5)

# Average number of events per cat for each day of the week
day_final %>%
  arrange(avg) %>%
  mutate(day_of_week = factor(day_of_week, levels=c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"))) %>%
  ggplot( aes(x = day_of_week, y = avg)) +
  geom_col( aes(x = day_of_week, y = avg, fill = day_of_week)) +
  scale_fill_manual(values = c("Monday" = "yellow",
                               "Tuesday" = "pink",
                               "Wednesday" = "green",
                               "Thursday" = "orange",
                               "Friday" = "lightblue",
                               "Saturday" = "purple",
                               "Sunday" = "red")) +
  geom_text(aes(x = day_of_week, y = avg, label = avg), nudge_y = 5, size = 3) +
  ggtitle("Avergae number of events per cat for each day of the week") +
  labs(y = "Avergae number of events per cat")


# Average number of events per cat for each month
ggplot(data = month_final, mapping = aes(x = month, y = avg, group = 1)) +
  geom_line(color = "slateblue1") +
  geom_point( size=1, color = "slateblue") +
  labs(y = "Average number of events per cat", x = "month") +
  ggtitle("Average number of events per cat for each month") +
  geom_text(data = rbind(month_final[which.min(month_final$avg), ], month_final[which.max(month_final$avg),]), aes(x = month, y = avg, label = avg), nudge_y = 50)

# Average number of events per cat for each year
ggplot(data = year_final) +
  geom_col(mapping = aes(x = year, y = avg, fill = avg)) +
  scale_y_continuous(labels = scales::comma) +
  geom_text(aes(x = year, y = avg, label = avg), nudge_y = 50, size = 3.5) +
  labs(y = "Average number of event per cat") +
  ggtitle("Average number of event per cat for each year") 

# Average number of events in a day separated by sex
ggplot(data = avg_day) +
  geom_col(mapping = aes(x = animal_sex, y = avg_per_deploy_day, fill = animal_sex)) +
  geom_text(aes(x= animal_sex, y = avg_per_deploy_day, label = avg_per_deploy_day), nudge_y = 10, size = 3.5) +
  scale_y_continuous(labels = scales::comma) +
  labs(y = "Average number of events") +
  ggtitle("Average number of events per cat in a day separated by sex") 

# Creating a bar graph for hunt
ggplot(hunt_counts, aes(x = hunt, y = n, fill = hunt)) +
  geom_bar(stat = "identity") + 
  geom_text(aes(label = paste0(n, " (", scales::percent(n / sum(n)), ")")), 
            vjust = -0.5, color = "black") +  # Add count and percentage labels on top of bars
  labs(title = "How many cats hunt?", x = "Hunt", y = "Count")  # Add labels

# -- Compare between two variables of each cat --
# Total number of events vs deployed hours -- there is only one cat with missing deploy_hrs data
ggplot(data = cats_joined, aes(x = deploy_hours, y = total_number)) +
  geom_point(color = "forestgreen") +
  geom_point(data = cats_joined[which.min(cats_joined$total_number), ], color="blue", size=2) +
  geom_point(data = cats_joined[which.max(cats_joined$total_number), ], color="red", size=2) +
  geom_text(data = rbind(cats_joined[which.min(cats_joined$total_number), ], cats_joined[which.max(cats_joined$total_number),]), aes(x = deploy_hours, y = total_number, label=animal_id), nudge_y = -100) +
  ggtitle("Cats New Zealand: Total number of events vs deployed hours") +
  labs(y = "Total number of events")

# Total events vs Age
ggplot(data = cats_joined, aes(x = age_years, y = total_number)) +
  geom_point(color = "turquoise") +
  geom_point(data = cats_joined[which.min(cats_joined$total_number), ], color="blue", size=2) +
  geom_point(data = cats_joined[which.max(cats_joined$total_number), ], color="red", size=2) +
  geom_text(data = rbind(cats_joined[which.min(cats_joined$total_number), ], cats_joined[which.max(cats_joined$total_number),]), aes(x = age_years, y = total_number, label=animal_id), size = 2.5, nudge_y = -100) +
  ggtitle("Cats New Zealand: Total number of events vs Age") +
  labs(y = "Total number of events")

# Total events vs Indoor hours
ggplot(data = cats_joined, aes(x = hrs_indoors, y = total_number)) +
  geom_point(color = "pink3") +
  geom_point(data = cats_joined[which.min(cats_joined$total_number), ], color="blue", size=2) +
  geom_point(data = cats_joined[which.max(cats_joined$total_number), ], color="red", size=2) +
  geom_text(data = rbind(cats_joined[which.min(cats_joined$total_number), ], cats_joined[which.max(cats_joined$total_number),]), aes(x = hrs_indoors, y = total_number, label=animal_id), size = 2.5, nudge_y = -100) +
  ggtitle("Cats New Zealand: Total number of events vs Indoor hours") +
  labs(y = "Total number of events")

# Total events vs Preys per month
ggplot(data = cats_joined, aes(x = prey_p_month, y = total_number)) +
  geom_point(color = "sienna1") +
  geom_point(data = cats_joined[which.min(cats_joined$total_number), ], color="blue", size=2) +
  geom_point(data = cats_joined[which.max(cats_joined$total_number), ], color="red", size=2) +
  geom_text(data = rbind(cats_joined[which.min(cats_joined$total_number), ], cats_joined[which.max(cats_joined$total_number),]), aes(x = prey_p_month, y = total_number, label=animal_id), size = 2.5, nudge_y = -100) +
  ggtitle("Cats New Zealand: Total number of events vs Number of preys per month") +
  labs(y = "Total number of events")

# Creating a graph from long and latitude
library(sf)

cat_nz_sf <- st_as_sf(cats_nz_clean, coords = c("location_long", "location_lat"))

cat_nz_sf <- st_set_crs(cat_nz_sf, "EPSG:4326")

grid_size <- c(0.1, 0.1)

grid <- st_make_grid(cat_nz_sf, cellsize = grid_size)

# Convert grid to an sf object
grid_sf <- st_as_sf(grid)

# Perform spatial join and summarization
grid_summary <- st_join(cat_nz_sf, grid_sf) %>%
  group_by(geometry) %>%
  summarise(total_points = n())

# Calculate how many points are there in the two main areas
filtered_points <- cat_nz_sf %>%
  filter(st_coordinates(geometry)[, "Y"] < 60 & st_coordinates(geometry)[, "X"] < 0)
num_points <- nrow(filtered_points)
print(num_points)

filtered_points2 <- cat_nz_sf %>%
  filter(st_coordinates(geometry)[, "Y"] < -40 & st_coordinates(geometry)[, "X"] > 0)
num_points2 <- nrow(filtered_points2)
print(num_points2)


# Calculate the total count
total_count <- num_points + num_points2

# Calculate the percentage of num_points
percentage_points <- (num_points / total_count) * 100

# Calculate the percentage of num_points2
percentage_points2 <- (num_points2 / total_count) * 100

# Print the percentages
print(percentage_points)
print(percentage_points2)

# Plotting the graph 
ggplot() +
  geom_sf(data = grid_summary, aes(fill = total_points), color = "black") +  # Change grid lines color to black
  scale_fill_gradient(low = "lightblue", high = "darkblue") +
  labs(title = "Location of events from geometry data", x = "latitude", y = "longitude", fill = "Total events") +
  annotate("text",x = 35, y = 50, size = 3.5, color = "blue", label ="1155 events (0.3%) happened in this area ") +
  annotate("text",x = 140, y = -30, size = 3.5, color = "red", label ="405317 events (99.7%) happened in this area ") +
  theme_minimal()    
