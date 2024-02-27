# Pet Cats in New Zealand
![pexels-pixabay-257532](https://github.com/ksadangrit/cats_nz/assets/156267785/a60327d8-80dc-454c-9ab4-f9f146034219)

_Photo by Pixabay from [Pexels](https://www.pexels.com/photo/low-angle-view-of-cat-on-tree-257532/)_

## Introduction
In this project, we will be looking at datasets of pet cats in New Zealand which had been collected from GPS sensors strapped by a number of voluntees on their pets to track the cat's number of activities. The datasets are from 2015 to 2017. Cat's characteristics such as sex, age and hunting habits are also provided in the datasets.  This data is published by [Movebank](https://datarepository.movebank.org/entities/datapackage/75d6171c-d981-4bdf-bf23-bf2af17a7e47). 

I first came across this data through the [tidytuesday](https://github.com/rfordatascience/tidytuesday/blob/master/data/2023/2023-01-31/readme.md) post. As the datasets provided on the page is for the UK, I went to the original [website](https://datarepository.movebank.org/entities/datapackage/75d6171c-d981-4bdf-bf23-bf2af17a7e47) to retrieve all the New Zealand datasets. The researchers originally collected data regarding pet cats from six different countries such as the UK, Australia and New Zealand to study the ecological importace of pets as predators. This project will focus solely on the New Zealand dataset. R will be utilised for data analysis and visualisation. 

This project will focus only on the New Zealand cats data in which all the animals involved share the same taxon and does not contain any details of the preys that those cats hunt. The main objectives that I hope to find by the end of this project are whether there are any correlations between the number of events recorded for cats and other factors such as their ages, indoor hours, number of preys they catch and hours of GPS deployment. I also would like to explore if there are any trends in terms of the number of events and time measurements such as hour of the day, weekdays, months and year.

_Note: Click here to view the [license](https://creativecommons.org/publicdomain/zero/1.0/) of this data. These data are also described in the following [publication](https://doi.org/10.1111/acv.12563): Kays R, Dunn RR, Parsons AW, Mcdonald B, Perkins T, Powers S, Shell L, McDonald JL, Cole H, Kikillus H, Woods L, Tindle H, Roetman P (2020) The small home ranges and large local ecological impacts of pet cats. Animal Conservation._


## My analytical workflow
1. Importing data
2. Cleaning and Preparing the data
3. Calculation and analysis 
4. Visualisations and findings
5. Conclusions and recommendations

## 1. Importing and preparing data
Firstly, we will download the datasets from [Movebank](https://datarepository.movebank.org/entities/datapackage/75d6171c-d981-4bdf-bf23-bf2af17a7e47) and save them into my computer file. 

Before we import the datasets into the RStudio, we will to ensure that all the neccesary packages are installed by running the following code.
```
# Install the following packages
install.packages("tidyverse")
install.packages("ggplot2")
install.packages("janitor")
```

```
# Download the libraries
library("tidyverse")
library("ggplot2")
library(janitor)
library(hms)
```

we will then import the csv files for the cats data into the RStudio, starting with the tracking data. We'll use the pipe operator here to include clean_names() function to ensure that the column names are unique and consist only of the '_' character, numbers, and letters.
```
cats_nz <- read_csv("/Users/yanhua1/Downloads/pet_cats_nz.csv") %>% 
  clean_names()
```
Next, we will import the reference dataser with clean column names using the below code.
```
cats_reference <- read_csv("/Users/yanhua1/Downloads/pet_cats_nz_reference_data.csv") %>% 
  clean_names()
```
We will check out all the columns and the data using the `glimpse()` function and check whether all the event ids are unique and matches the number of roes using `length()`
```
glimpse(cats_nz)
glimpse(cats_reference)
length(unique(cats_nz$event_id))
```

### Data Dictionary 
For full definitions click [here](https://datarepository.movebank.org/server/api/core/bitstreams/a4ef5439-621e-4c95-b4d6-b4f34fe85504/content)https://datarepository.movebank.org/server/api/core/bitstreams/a4ef5439-621e-4c95-b4d6-b4f34fe85504/content.
* `algorithm_marked_outlier`: Identifies events marked as outliers using a user-selected filter algorithm in Movebank. Outliers have the value TRUE.
* `animal_comments`: Additional information about the animal that is not described by other reference data terms.
* `animal_id`: An individual identifier for the animal, provided by the data owner. If the data owner does not provide an Animal ID, an internal Movebank animal identifier is sometimes shown. same as: individual local identifier
* `animal_life_stage`: The age class or life stage of the animal at the beginning of the deployment. Can be years or months of age or terms such as 'adult', 'subadult' and 'juvenile'. Best practice is to define units in the values if needed (e.g. '2 years').
* `animal_reproductive_condition`: The reproductive condition of the animal at the beginning of the deployment. 
* `animal_sex`: The sex of the animal. Allowed values are m = male and f = female.
* `animal_taxon`: The scientific name of the species on which the tag was deployed, as defined by the Integrated Taxonomic Information System (ITIS, www.itis.gov). If the species name can not be provided, this should be the lowest level taxonomic rank that can be determined and that is used in the ITIS taxonomy.
* `deploy_off_date`: The timestamp when the tag deployment ended.
* `deploy_on_date`: The timestamp when the tag deployment started.
* `event_id`: An identifier for the set of values associated with each event, i.e. sensor measurement. A unique event ID is assigned to every time-location or other time-measurement record in Movebank. If multiple measurements are included within a single row of a data file, they will share an event ID. If users import the same sensor measurement to Movebank multiple times, a separate event ID will be assigned to each.
* `location_lat`: The geographic longitude of the location as estimated by the sensor. Positive values are east of the Greenwich Meridian, negative values are west of it. example: -41.0982423.
* `location_long`: The geographic longitude of the location as estimated by the sensor. Positive values are east of the Greenwich Meridian, negative values are west of it.
* `manually_marked_outlier`: Identifies events flagged manually as outliers, typically using the Event Editor in Movebank, and may also include outliers identified using other methods. Outliers have the value TRUE.
* `tag_id`: A unique identifier for the tag, provided by the data owner. If the data owner does not provide a tag ID, an internal Movebank tag identifier may sometimes be shown. example: 2342.
* `timestamp`: The date and time corresponding to a sensor measurement or an estimate derived from sensor measurements. 

## 2. Cleaning and preparing the data
We will start by cleaning the `cats_nz` dataset. We will drop the columns that are not needed and change `tag_local_identifier` and `individual_local_identifier` column names to match the same columns from the `cats_reference` dataset.
```
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
```

We'll also create columns for `hour`, `day_of_week`, `month` and `year`
```
cats_nz_clean$hour <- hour(cats_nz_clean$timestamp)
cats_nz_clean$day_of_week <- weekdays(as.Date(cats_nz$timestamp))
cats_nz_clean$month <- format(as.Date(cats_nz_clean$timestamp, format="%Y/%m/%d"),"%m")
cats_nz_clean$year <- format(as.Date(cats_nz_clean$timestamp, format="%Y/%m/%d"),"%Y")
```

Now we'll clean the `cats_reference` dataset. Before dropping certain columns with one value, we'll use the below code to ensure those columns do not have multiple unique values.
```
unique(cats_reference$duty_cycle)
unique(cats_reference$attachment_type)
unique(cats_reference$deployment_end_type)
unique(cats_reference$manipulation_type)
```

Now we'll tidy this dataset using the below code.
```
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
```

## 3. Calculation and analysis
At this stage, we're going to do calculations on the `cats_nz_clean` dataframe before looking at the `cats_reference_clean` dataframe. For this part, I will mainly talk about the code that will be use for different calculations. The results and insights from these calculations will be discussed at the next stage, except for the calculation of avg, min and max of ages, indoor hours, preys per month and deployed hours as I won't be making visualisations for those results.
### Total number of events 
-- From all cats --
```
nrow(cats_nz_clean)
```
-- From each cat in a descending order --

Pipe operator is used in the below code and we will create a new dataframe called `total_events_cat` which contains all the cat names and the total number of events each cat take.
```
total_events_cat <- cats_nz_clean %>% 
  group_by(animal_id) %>% 
  count(animal_id) %>% 
  arrange(desc(n)) %>% 
  rename("total_number" = "n") # Replace the column named n with total_number
```

### Average and total number of events
We will calculate both the average and total number of events that occurred using different time measurements including hour of the day, weekdays, month and year. A data frame for each result will be created to make it easier when making visualisations later. Pipes will be used to chain operations such as `group_by()` and `summarise()`. 

-- For each hour of the day --
```
hour_final <- cats_nz_clean %>%
  group_by(hour, animal_id) %>%
  summarise(total_number = n()) %>%
  group_by(hour) %>%
  summarise(avg = round(mean(total_number)),
            total = sum(total_number),
            num_cat = n_distinct(animal_id))
```

-- For each day of the week --
```
day_final <- cats_nz_clean %>%
  group_by(day_of_week, animal_id) %>%
  summarise(total_number = n()) %>%
  group_by(day_of_week) %>%
  summarise(avg = round(mean(total_number)),
            total = sum(total_number),
            num_cat = n_distinct(animal_id))
```

-- For each month --
```
month_final <- cats_nz_clean %>% 
  group_by(month, animal_id) %>% 
  summarise(total_number = n()) %>% 
  group_by(month) %>% 
  summarise(avg = round(mean(total_number)),
            total = sum(total_number),
            num_cat = n_distinct(animal_id))
```

-- For each year --
```
year_final <- cats_nz_clean %>%
  group_by(year, animal_id) %>%
  summarise(total_number = n()) %>%
  group_by(year) %>%
  summarise(avg = round(mean(total_number)),
            total = sum(total_number),
            num_cat = n_distinct(animal_id))
```
### How many cats hunnt
To find out how many cats hunt, we'll count the number of values in the `hunt` column from the `cats_reference_clean` using the below code.
```
hunt_counts <- cats_reference_clean %>% 
  count(hunt) 
```
### Calculating avg, min and max
We will perform calculations on the `cats_reference_clean` dataframe to find max, min and average of the `age_years`, `hrs_indoors`, `prey_p_month` and `deploy_hours`. NA values will not be included in these calculations.

-- ages --
```
summary_age <- cats_reference_clean %>%
  summarise(
    average_indoors = round(mean(age_years, na.rm = TRUE), 2),
    min_indoors = min(age_years, na.rm = TRUE),
    max_indoors = max(age_years, na.rm = TRUE)
  )
# Print the dataframe
print(summary_age)
```
![Screen Shot 2024-02-23 at 1 39 00 PM](https://github.com/ksadangrit/cats_nz/assets/156267785/e3156de0-9b0e-47bb-bcd8-da91d1195835)

The oldest cat is 16 years old and the youngest one is under one year old. The oldest cat is more than 3 times older than most cats in this research.

-- indoors hours --
```
summary_indoors <- cats_reference_clean %>%
  summarise(
    average_indoors = round(mean(hrs_indoors, na.rm = TRUE), 2),
    min_indoors = min(hrs_indoors, na.rm = TRUE),
    max_indoors = max(hrs_indoors, na.rm = TRUE)
  )
# Print the results
print(summary_indoors)
```
![Screen Shot 2024-02-23 at 12 49 37 PM](https://github.com/ksadangrit/cats_nz/assets/156267785/7bcedb1f-dbce-4e2a-86fd-88174b19caeb)

Some cat spends 23 hours indoors which over 11 times more than cat with the least indoor hours. In average cats in this research spends around 12 hours indoors.

-- preys per month --
```
summary_prey <- cats_reference_clean %>%
  summarise(
    average_prey = round(mean(prey_p_month, na.rm = TRUE), 2),
    min_prey = min(prey_p_month, na.rm = TRUE),
    max_prey = max(prey_p_month, na.rm = TRUE)
  )
# Print the results
print(summary_prey)
```
![Screen Shot 2024-02-23 at 12 51 16 PM](https://github.com/ksadangrit/cats_nz/assets/156267785/b8a2e972-b083-41e0-9b76-41551f784994)

Cats that hunt in this research catches at least 1 prey and in average they catch around 5 preys per month. The most preys that a cat catch per month is 21 preys which is about 4 times more than the average.

-- deployed hours --
```
summary_deployed_hours <- cats_reference_clean %>%
  summarise(
    average_deployed_hours = round(mean(as.numeric(gsub(" hours", "", deploy_hours)), na.rm = TRUE), 2),
    min_deployed_hours = min(as.numeric(gsub(" hours", "", deploy_hours)), na.rm = TRUE),
    max_deployed_hours = max(as.numeric(gsub(" hours", "", deploy_hours)), na.rm = TRUE)
  )
# Print the results
print(summary_deployed_hours)
```
![Screen Shot 2024-02-23 at 12 49 16 PM](https://github.com/ksadangrit/cats_nz/assets/156267785/e5f82ce3-942e-404d-81e9-db18831e3a0d)

In avergae, GPS device had been deployed on cats for around 175 hours. The least time that a device is deployed on a cat is only 13 hours while some cat had a device with them for as long as 2004 hours. That is around 83 days and 11 more time than most cats.

We will join the `total_evnet_cats` dataframe with the `cats_reference_clean` dataframe using the below code. The `cats_joined` dataframe will be used for comparison between the number of event with other aspects.
```
cats_joined <- cats_reference_clean %>% 
  full_join(y = total_events_cat, by=c("animal_id"))
```

### Finding the average number of events separated by sex
```
avg_day <- cats_joined %>%
  filter(!is.na(animal_sex)) %>%  # Filter out NA values in animal_sex
  group_by(animal_sex) %>%
  summarise(
    total_number_sum = sum(total_number),
    deploy_days_total = sum(as.numeric(deploy_days), na.rm = TRUE),  # Convert deploy_days to numeric
    avg_per_deploy_day = round(total_number_sum / deploy_days_total, 2)
  )

```

## 4. Visualisations and findings 
For this part of the project, I will not include the codes used for creating visualisations but the full codes can be accessed in the **cats_nz_complete.R** file under the same repository.

### Top 10 cats with the highest number of events
![top_10](https://github.com/ksadangrit/cats_nz/assets/156267785/33f7d8ef-0a04-4ffd-af68-c1e08f40c592)

Out of 233 cats in the experiment, **Luna** is the one with the most total number of events at **5151**, followed by **Whiskey, Skyll, Bella** and **Penny.** The difference between the number of events occured for Luna and Whiskey is 770 and between Whiskey and Skyll is 687. However, from rank 4 to 10, the difference in the number of events between the two cats ranked next to each other is never greater than 140.

### Top 10 cats with the lowest number of events
![last_10](https://github.com/ksadangrit/cats_nz/assets/156267785/cc466ced-f8cc-4cfe-bab3-073d8f438ef3)

Boots is the cat with the least total events at 11, followed by Barnaby1, Oscar, Aggie and Greyskull2. The diffetence in the number of events between Boots and Barnaby1 is over 80. There is also a big difference in the number of events that Minerva took and Timmy1 took by 215. Boots and Barnaby1 are the only 2 cats that have less than 100 events.

### Average number of events per cat 
In this part of the visualisations, we will only look at the average number of events that a cat take at different time measurements. This is because the participating cats were given the GPS device at different time period and the number of cats for each month varies. As a result, drawing conclusions based on the total number can potentially be inaccurate.

---- **For each hour** ----

![avg_hour](https://github.com/ksadangrit/cats_nz/assets/156267785/1686cc66-b3f8-4e48-93c0-f38bca9f5b34)

4am is when the average number of events occured the least. The average number of events that cats take increases from 5am onwards and reached the highest number at 4pm with the average number of events being 84. The average number of events continues to drop after 6 pm.

---- **For each day of the week** ----

![avg_weekday](https://github.com/ksadangrit/cats_nz/assets/156267785/f0f90862-f561-435a-bad5-a8c2c95cff94)

Sunday is the day with the highest average number of events, followed by Saturday and Monday. The average number of events continues to drop slightly throughout the weekdays and reaches the lowest on Thruday with 253 events occured. The number then gradually rises up from Friday onwards. It is worth noting that there is generally not much difference in the number of events cats take throughout the week as the difference between the highest number and the lowest is only 30.

---- **For each month** ----

![avg_month](https://github.com/ksadangrit/cats_nz/assets/156267785/4fccafb1-0cea-4fbf-8391-13558cb51ab8)

March is the month with the highest average number of events at 1884 events. The number drops significantly after March and reaches its lowest in June with only 520 events occured on average. However, there is a significant change after June as the number rises up from June and reaches the second peak in August before dropping once again until November. 

---- **For each year** ----

![avg_year](https://github.com/ksadangrit/cats_nz/assets/156267785/7a7f4693-50af-48ec-b6c1-2244dcae15c8)

2016 is the year with the highest average number of events, followed by 2015 and 2017. There is less than 60 events difference between the number of avergae events occured for cats in 2016 and 2015. However, the difference in the average number is quite significant between 2015 and the other two years as 2015 has at least 500 event less.

### Average number of events in a day separated by sex
![day_sex_nona](https://github.com/ksadangrit/cats_nz/assets/156267785/747f9d22-edab-4222-8bb6-05fcd747729f)

In a day, events occured more often for male cats than female cats with the difference being around 30 events. 

### How many cats hunt?
![hunt](https://github.com/ksadangrit/cats_nz/assets/156267785/01b288a8-384c-4f14-b784-76769202b923)

We can see from the graph that 67.4% of all the participating cats hunt and only around 13.7% do not hunt. The number of cats that hunt is almost 5 times more than the cats that do not hunt. The number of cats with unknown status or missing data as to whether they hunt or not contributes to almost 19% of all cats which is more than the number of cats that are confirmed for not hunting. 

### Total number of events vs Age
![total_age](https://github.com/ksadangrit/cats_nz/assets/156267785/ba14ec13-6d3f-4008-ae50-ba5d06ea56aa)

When we compare the cat ages and the total number of events each cat took, there seems to be no obvious correlation between the two factors. Luna is the cat with the highest number of event while Boots is the one with the least number of events although both cats are of the same age. In the plot, the are cats with high number of events and low number of events for all age ranges.

### Total number of events vs Indoor hours
![total_indoor](https://github.com/ksadangrit/cats_nz/assets/156267785/29e8a19b-db96-4fa2-bb38-5bae6a5bb9d8)

When we look at the number of events and the number of hours a cat stay indoors. There also seems to be no apparent correlation between the two factor. Although Boots, the cat with the lowest number of events has spend more time indoors than Luna, there are also other cats more time indoors than Boots and still have higher number of events.

### Total number of events vs Preys per month
![total_prey](https://github.com/ksadangrit/cats_nz/assets/156267785/9f39b097-1bc9-4b26-9b9e-44dc78d6da66)

There is no clear correlation between the number of events a cat takes and the number of preys they catch as there are cats with low number of events who catch over 20 preys and vice versa.

### Total number of events vs deployed hours
![total_deply_hr](https://github.com/ksadangrit/cats_nz/assets/156267785/5443c8db-9eca-45de-8df1-c35f12178eef)

There seems to be a correlation between the number of hours GPS deployed on cats and the number of events they take. As per the above plot, cat with more deployed hours tend to also have more number of events recorded. We can see that there are a few cats on the plot that outside of the lines. Theose outliers may be the exceptions to the major trend. However, it is evident that there is a strong correlation between the two factors.

### A graph based on longitude and latitude data
![Lat_long](https://github.com/ksadangrit/cats_nz/assets/156267785/feb1acc8-a358-4621-9abf-1ba4acbdbd2e)

When plotting a graph using the longitude and latitude data, it appears that most events (99.7% of the time) occured in the same area while 1155(0.3% of all events) happened in a further location. There are definitely some errors with the location data of the 1155 events as all cats in this project are from New Zealand but the outliers suggested that those events occured in a different continent.

## 5. Conclusions and recommendations
Based on the data available from 2015 to 2017, I found the following:
* Most cats hunt and they usually capture around 5 preys per month.
* The cat ages range from under one year old to 16 years old.
* Some cat has the GPS device on them for almost 83 days while some cat only has it with them for 13 hours.
* Most cats spend around 12 hours indoors. Some cat in this reseach spend only 1 hour outdoors while some only spends 2 hours indoors.
* There is correlation between the total number of events occured for each cat and their ages, indoor hours and number of preys they capture in a month.
* Howeevr, it is evident that the more time cats have GPS device with them, the more events will be recorded on the device.
* Luna has the highest number of events recorded and Boots has the least. Luna's number of events is over 468 times more than Boots.
* Male cats have more events recorded than females.
* More events had been recorded more during the afternoon (12pm to 6pm) and less at night (1am - 5am). This suggests that cats tend to go out and move around more in the afternoon.
* There is not much difference in the number of events recorded for each day of the week but more events had been recorded on weekends.
* In average, the least number of event occureed in June and the most in March. This is highly due to the fact that there was not as many cats in this reseach in June and more in March as the number of cats participated varied for different period.
* More events were averagely recorded in 2016, followed by 2015 and 2017. 

### Recommendations
1. For the results to be unbiased and more accurate, the reseachers should consider assigning the GPS tracker to the same number of cats for each year. Cats should have the GPS on for the same duration and time period.
2. It is unclear whether the event ids were craeted every time a movement is detected or when the cats go outside only. More clarification would provide better insights from the results.
3. Most cats in this research had been desexed or with the unknown status. It might be benificial to compare between cats that are desexed and not to see if there is any correlation between the events they have and their sexual status.




