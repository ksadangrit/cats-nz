# cats_nz

![pexels-pixabay-257532](https://github.com/ksadangrit/cats_nz/assets/156267785/a33c478b-807e-4786-9de5-44a8d6934956)
_Photo by Pixabay from [Pexels](https://www.pexels.com/photo/low-angle-view-of-cat-on-tree-257532/)_

## Introduction
In this project, we will be looking at datasets of pet cats in New Zealand which had been collected from GPS sensors strapped by a number of voluntees on their pets to track the cat's number of activities. The datasets are from 2015 to 2017. Cat's characteristics such as sex, age and hunting habits are also provided in the datasets.  This data is published by [Movebank](https://datarepository.movebank.org/entities/datapackage/75d6171c-d981-4bdf-bf23-bf2af17a7e47). 

I first came across this data through the [tidytuesday](https://github.com/rfordatascience/tidytuesday/blob/master/data/2023/2023-01-31/readme.md) post. As the datasets provided on the page is for the UK, I went to the original [website](https://datarepository.movebank.org/entities/datapackage/75d6171c-d981-4bdf-bf23-bf2af17a7e47) to retrieve all the New Zealand datasets. The researchers originally collected data regarding pet cats from six different countries such as the UK, Australia and New Zealand to study the ecological importace of pets as predators. This project will focus solely on the New Zealand dataset. R will be utilised for data analysis and visualisation.

Click here to view the [license](https://creativecommons.org/publicdomain/zero/1.0/) of this data. These data are also described in the following [publication](https://doi.org/10.1111/acv.12563): Kays R, Dunn RR, Parsons AW, Mcdonald B, Perkins T, Powers S, Shell L, McDonald JL, Cole H, Kikillus H, Woods L, Tindle H, Roetman P (2020) The small home ranges and large local ecological impacts of pet cats. Animal Conservation.

## My analytical workflow
1. Import and prepare data
2. Clean my data
3. Calculate and analyse my data
4. Findings and recommendations

## 1. Import and prepare data
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

## 2. Clean my data
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

Now we'll tidy this dataset.
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
