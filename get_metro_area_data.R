## Get wikipedia page of metro populations
## Winston Saunders Sept 18 2016
##    rev 0.1 Sept 28 2016 modified grep to include m-dash and fwd slash
##    rev 0.2 Sept 30 2016 cleaned a few names
##
## reads wikipedia page 
## gets table
## converts from html to data_frame
## cleans
## stores data as csv


library(XML)
library(RCurl)
library(dplyr)

theurl = "https://en.wikipedia.org/wiki/List_of_Metropolitan_Statistical_Areas"


webpage <- getURL(theurl)
webpage <- readLines(tc <- textConnection(webpage)); close(tc)

pagetree <- htmlTreeParse(webpage, error=function(...){}, useInternalNodes = TRUE)

# Extract table header and contents
tablehead <- xpathSApply(pagetree, "//*/table[@class='wikitable sortable']/tr/th", xmlValue)
results <- xpathSApply(pagetree, "//*/table[@class='wikitable sortable']/tr/td", xmlValue)

# Convert character vector to dataframe
content <- as.data.frame(matrix(results, ncol = 6, byrow = TRUE))

# assign meaningful column names
colnames(content) <- c("rank", "metro_stat_area", "pop_2015", "pop_2010", "change", "encompassing_stat_area")

# add rank
content$rank <- 1:nrow(content)

# convert to characters
content$pop_2015 <- as.character(content$pop_2015)
content$pop_2010 <- as.character(content$pop_2010)
content$change <- as.character(content$change)
# get rid of commas
content$pop_2015 <- gsub("," , "", content$pop_2015)
content$pop_2010 <- gsub("," , "", content$pop_2010)
# clean metro names
content <- content %>% mutate(metro = gsub('(/|–|-|,).*', "",metro_stat_area)) %>%
    mutate(metro = gsub('Boise City', 'Boise', metro)) %>%
    mutate(metro = gsub('Urban ', '', metro)) %>%
    mutate(metro = gsub('^York', 'Harrisburg', metro)) %>%
    mutate(metro = gsub('Winston', 'Winston-Salem', metro))


# convert population to numeric data
content <- content %>% mutate(population = as.numeric(pop_2015))
# cbind desired clean data
metro_data_clean <- cbind(content$rank, content$population, content$metro) %>% as_data_frame
# assign colnames
colnames(metro_data_clean) <- c("rank", "population", "metro")
# save data
write.csv(metro_data_clean, "/users/winstonsaunders/documents/city_politics/metro_pop_table_2015.csv")

## End (not run)
