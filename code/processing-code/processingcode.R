###############################
# Initial data processing script
###############################


## ---- packages --------
#load needed packages. make sure they are installed.
library(readxl) #for loading Excel files
library(dplyr) #for data processing/cleaning
library(tidyr) #for data processing/cleaning
library(skimr) #for nice visualization of data 
library(here) #to set paths
library(readr) #open excel csv files


## ---- loaddata --------
#path to data
#note the use of the here() package and not absolute paths
hypertension_cdv_adult_mortality_location <- here::here("data","raw-data","hypertension_related_CDV_disease_mortality_US_adults_35_demographics_2000-2019.csv")


#load data. 
hypertension_cdv_adult_mortality_data <- readr::read_csv(hypertension_cdv_adult_mortality_location)


## ---- explore hypertension data --------
#take a look at the data
dplyr::glimpse(hypertension_cdv_adult_mortality_data)
#another way to look at the data
summary(hypertension_cdv_adult_mortality_data)
#yet another way to get an idea of the data
head(hypertension_cdv_adult_mortality_data)
#this is a nice way to look at data
skimr::skim(hypertension_cdv_adult_mortality_data)
#look in the Codebook for a variable explanation
print(hypertension_cdv_adult_mortality_data)

View(hypertension_cdv_adult_mortality_data)




#It is clear that this is a massive dataset with over 1.1 million observations. 
#It is not possible to go through all of the rows and entries manually and so we will have to check for issues and errors as we go.
#We might consider cutting this down a bit. 
#Unfortunately, it seems like the only way to reduce the number of observations would be to delete data, which we do not want to do, so we can consider splitting this into groups based on different areas if we want, since this is based on region and county. This will be decided and done later if needed.
#There seems to be some unnecessary columns (e.g. data value footnote symbol) with information that doesn't help our understanding and may make this less readable.We can remove these columns.
#It seems like the columns used for stratified groups (e.g race, age and sex) are strangely formatted and there is a column for entries which could perhaps be the heading of the column instead.
#We will confirm that entries in these columns and then rename the headings and delete unnecessary columns.


## ---- cleandata1 --------

#Before we can delete columns that we think are redundant we just want to double check them. 
#We are making sure that the column has all the same value and that it is unnecessary information or could be included as a column title or a footnote.
head(hypertension_cdv_adult_mortality_data$DataSource)
skimr::skim(hypertension_cdv_adult_mortality_data$DataSource)
#Remove DataSource

#As suspected, We can delete this whole column since it only contains one repeated value with the same source. 
#This process will be repeated for the other columns that can be removed identified.
#Cleaning steps will follow afterwards.

#Class
head(hypertension_cdv_adult_mortality_data$Class)
skimr::skim(hypertension_cdv_adult_mortality_data$Class)
#Remove class

#Topic
head(hypertension_cdv_adult_mortality_data$Topic)
skimr::skim(hypertension_cdv_adult_mortality_data$Topic)
#Remove Topic

#StratificationCategory1
head(hypertension_cdv_adult_mortality_data$StratificationCategory1)
skimr::skim(hypertension_cdv_adult_mortality_data$StratificationCategory1)
#Remove column and rename Stratification1 column as age_group instead

#StratificationCategory2
head(hypertension_cdv_adult_mortality_data$StratificationCategory2)
skimr::skim(hypertension_cdv_adult_mortality_data$StratificationCategory2)
#Remove column and rename Stratification2 column as race_ethnicity

#StratificationCategory3
head(hypertension_cdv_adult_mortality_data$StratificationCategory3)
skimr::skim(hypertension_cdv_adult_mortality_data$StratificationCategory3)
#Remove column and rename Stratification3 column as sex

#TopicID
head(hypertension_cdv_adult_mortality_data$TopicID)
skimr::skim(hypertension_cdv_adult_mortality_data$TopicID)
#Remove TopicID

#GeographicLevel
head(hypertension_cdv_adult_mortality_data$GeographicLevel)
skimr::skim(hypertension_cdv_adult_mortality_data$GeographicLevel)
#Remove GeographicLevel

#Data_Value_Footnote_Symbol
head(hypertension_cdv_adult_mortality_data$Data_Value_Footnote_Symbol)
skimr::skim(hypertension_cdv_adult_mortality_data$Data_Value_Footnote_Symbol)
#Remove Data_Value_Footnote_Symbol

#Data_Value_Footnote
head(hypertension_cdv_adult_mortality_data$Data_Value_Footnote)
skimr::skim(hypertension_cdv_adult_mortality_data$Data_Value_Footnote)
#Remove Data_Value_Footnote

#Data_Value
head(hypertension_cdv_adult_mortality_data$Data_Value)
skimr::skim(hypertension_cdv_adult_mortality_data$Data_Value)
#Rename Data_Value as mortalities to make the column title clear and relevant

#Deleting and renaming the columns 


## ---- cleandata2 --------
#Delete the columns from the data frame. We are using the same name here in order to reduce the size of the dataframe through the deleting of columns
hypertension_cdv_adult_mortality_data <- hypertension_cdv_adult_mortality_data %>% select(-DataSource, -Class, -Topic, -StratificationCategory1, -StratificationCategory2, -StratificationCategory3, -TopicID, -GeographicLevel, -Data_Value_Footnote_Symbol, -Data_Value_Footnote)

#Create a new dataframe with a shorter title with the renamed columns
hypertens_adult_mortality <- hypertension_cdv_adult_mortality_data %>% rename(age_group = Stratification1, race_ethnicity = Stratification2, sex = Stratification3, mortalities = Data_Value)

#Saving the new dataframe as an RDS file to try reduce the size of the files for the Github repository

saveRDS(hypertens_adult_mortality, file = here("data", "raw-data", "cleaned_hypertens_adult_mortality.rds"))



