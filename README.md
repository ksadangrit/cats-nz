# cats_nz

![pexels-pixabay-257532](https://github.com/ksadangrit/cats_nz/assets/156267785/a33c478b-807e-4786-9de5-44a8d6934956)
_Photo by Pixabay from [Pexels](https://www.pexels.com/photo/low-angle-view-of-cat-on-tree-257532/)_

## Introduction
In this project, we will be looking at datasets of pet cats in New Zealand which had been collected from GPS sensors strapped by a number of voluntees on their pets to track the cat's number of activities. Cat's characteristics such as sex, age and hunting habits are also provided in the datasets.  This data is published by [Movebank](https://datarepository.movebank.org/entities/datapackage/75d6171c-d981-4bdf-bf23-bf2af17a7e47). 

I first came across this data through the [tidytuesday](https://github.com/rfordatascience/tidytuesday/blob/master/data/2023/2023-01-31/readme.md) post. As the datasets provided on the page is for the UK, I went to the original [website](https://datarepository.movebank.org/entities/datapackage/75d6171c-d981-4bdf-bf23-bf2af17a7e47) to retrieve all the New Zealand datasets. The researchers originally collected data regarding pet cats from six different countries such as the UK, Australia and New Zealand to study the ecological importace of pets as predators. This project will focus solely on the New Zealand dataset. R will be utilised for data analysis and visualisation.

Click here to view the [license](https://creativecommons.org/publicdomain/zero/1.0/) of this data. These data are also described in the following [publication](https://doi.org/10.1111/acv.12563): Kays R, Dunn RR, Parsons AW, Mcdonald B, Perkins T, Powers S, Shell L, McDonald JL, Cole H, Kikillus H, Woods L, Tindle H, Roetman P (2020) The small home ranges and large local ecological impacts of pet cats. Animal Conservation.

## My analytical workflow
1. Import and prepare data
2. Clean my data
3. Calculate and analyse my data
4. Findings and recommendations

## Import and prepare data
Firstly, I will download the datasets from [Movebank](https://datarepository.movebank.org/entities/datapackage/75d6171c-d981-4bdf-bf23-bf2af17a7e47) and import them to my RStudio using the below code . The datasets are from 2015 to 2017.

```
# we'll import the csv files for the cats data, starting with the tracking data. We'll use the pipe operator here to include clean_names() function to ensure that the column names are unique and consist only of the '_' character, numbers, and letters.
cats_nz <- read_csv("/Users/yanhua1/Downloads/pet_cats_nz.csv") %>% 
  clean_names()
```
