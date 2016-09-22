# High Performance Reverse-Geo-Coding Model
Winston Saunders  
September 19, 2016  

###Summary

  
###Problem Statement










## Get city data

City coordinates and populations are available in the [`{maps}`](https://cran.r-project.org/web/packages/maps/index.html) package. The package is super-convenient as it contains all the information we need for plotting and normalizing the tweet data. 


```r
    require(maps)
    cities <- us.cities
    
    ## create city_name by removing state designnator
    cities <- cities %>% mutate(city_name = gsub(' [A-Z]{2,}','', name))
    ## clean
    cities <- cities[complete.cases(cities),] %>% as_data_frame
    ## sort
    cities <- cities[order(cities$pop, decreasing = TRUE), ]
```
 
The top cities by population are:  

<!-- html table generated in R 3.3.0 by xtable 1.8-2 package -->
<!--  -->
<table border=1>
<tr> <th> name </th> <th> country.etc </th> <th> pop </th> <th> lat </th> <th> long </th> <th> capital </th> <th> city_name </th>  </tr>
  <tr> <td align="right"> New York NY </td> <td align="center"> NY </td> <td align="center"> 8124427 </td> <td align="center"> 40.67 </td> <td align="center"> -73.94 </td> <td align="center">   0 </td> <td align="center"> New York </td> </tr>
  <tr> <td align="right"> Los Angeles CA </td> <td align="center"> CA </td> <td align="center"> 3911500 </td> <td align="center"> 34.11 </td> <td align="center"> -118.41 </td> <td align="center">   0 </td> <td align="center"> Los Angeles </td> </tr>
  <tr> <td align="right"> Chicago IL </td> <td align="center"> IL </td> <td align="center"> 2830144 </td> <td align="center"> 41.84 </td> <td align="center"> -87.68 </td> <td align="center">   0 </td> <td align="center"> Chicago </td> </tr>
  <tr> <td align="right"> Houston TX </td> <td align="center"> TX </td> <td align="center"> 2043005 </td> <td align="center"> 29.77 </td> <td align="center"> -95.39 </td> <td align="center">   0 </td> <td align="center"> Houston </td> </tr>
  <tr> <td align="right"> Phoenix AZ </td> <td align="center"> AZ </td> <td align="center"> 1450884 </td> <td align="center"> 33.54 </td> <td align="center"> -112.07 </td> <td align="center">   2 </td> <td align="center"> Phoenix </td> </tr>
  <tr> <td align="right"> Philadelphia PA </td> <td align="center"> PA </td> <td align="center"> 1439814 </td> <td align="center"> 40.01 </td> <td align="center"> -75.13 </td> <td align="center">   0 </td> <td align="center"> Philadelphia </td> </tr>
  <tr> <td align="right"> San Diego CA </td> <td align="center"> CA </td> <td align="center"> 1299352 </td> <td align="center"> 32.81 </td> <td align="center"> -117.14 </td> <td align="center">   0 </td> <td align="center"> San Diego </td> </tr>
  <tr> <td align="right"> San Antonio TX </td> <td align="center"> TX </td> <td align="center"> 1278171 </td> <td align="center"> 29.46 </td> <td align="center"> -98.51 </td> <td align="center">   0 </td> <td align="center"> San Antonio </td> </tr>
  <tr> <td align="right"> Dallas TX </td> <td align="center"> TX </td> <td align="center"> 1216543 </td> <td align="center"> 32.79 </td> <td align="center"> -96.77 </td> <td align="center">   0 </td> <td align="center"> Dallas </td> </tr>
  <tr> <td align="right"> San Jose CA </td> <td align="center"> CA </td> <td align="center"> 897883 </td> <td align="center"> 37.30 </td> <td align="center"> -121.85 </td> <td align="center">   0 </td> <td align="center"> San Jose </td> </tr>
   </table>

## Set up twitted API using the twitteR package

Setting up the twitter API is relatively quick. We can test package functionality by checking Michelle Obama's latest tweet.


```r
library(twitteR)
## create URLs
reqURL <- "https://api.twitter.com/oauth/request_token"
accessURL <- "https://api.twitter.com/oauth/access_token"
authURL <- "https://api.twitter.com/oauth/authorize"

## read file containing secret keys (obtained from apps.twitter.com)
keys <- read.table("/users/winstonsaunders/documents/city_politics/secret_t.key.txt")
## convert to characters
consumerKey <- keys[1,]%>%as.character()
consumerSecret <- keys[2,]%>%as.character()
accessToken <- keys[3,]%>%as.character()
accessTokenSecret <- keys[4,]%>%as.character()

## set up authentication
setup_twitter_oauth(consumerKey, consumerSecret, accessToken, accessTokenSecret)
```

```
## [1] "Using direct authentication"
```

```r
## test functionanlity
userTimeline(getUser('michelleobama'), n=1, includeRts=FALSE,excludeReplies=FALSE)
```

```
## [[1]]
## [1] "MichelleObama: “We can give all our children the bright, healthy futures they so richly deserve.” http://t.co/EgStdzksym #LetsMove"
```

## Getting the data

To get the tweet data use `twitteR::searchTwiter` command. 
Data collection with the following variables. Note the radius, which is used to localize tweet collected around specific geo-locations. In this initial case I chose a radius of 30 miles. For cases where major cities are in close proximity, this may pick up some redundant tweets.  


```r
## set up search terms
searchString.x <- "#rstats"
n.x <- 300
radius <- "30mi"
duration.days <- 7
since.date <- (Sys.Date() - duration.days) %>% as.character
```

Collected data are put into a dataframe `collected_df`. For this first pass analysis tweets are counted but not cached.   


```
## [1] "Rate limited .... blocking for a minute and retrying up to 119 times ..."
## [1] "Rate limited .... blocking for a minute and retrying up to 118 times ..."
## [1] "Rate limited .... blocking for a minute and retrying up to 117 times ..."
## [1] "Rate limited .... blocking for a minute and retrying up to 116 times ..."
## [1] "Rate limited .... blocking for a minute and retrying up to 115 times ..."
## [1] "Rate limited .... blocking for a minute and retrying up to 114 times ..."
## [1] "Rate limited .... blocking for a minute and retrying up to 113 times ..."
## [1] "Rate limited .... blocking for a minute and retrying up to 112 times ..."
## [1] "Rate limited .... blocking for a minute and retrying up to 111 times ..."
## [1] "Rate limited .... blocking for a minute and retrying up to 110 times ..."
## [1] "Rate limited .... blocking for a minute and retrying up to 109 times ..."
```

Once collected, the data are lightly analyzed. Specifically the 'tweet.density', representing the number of tweets per million people per day, is computed.


```r
analyzed_df <- collected_df %>% 
    mutate("tweet.density" = 10^6 * n.tweets/population/duration.days ) %>% 
    select(name, lon, lat, tweet.density, n.tweets, population)
```

## Tweet Map

Mapping uses the `{ggmap}` package. 

<img src="USAMapTest1_files/figure-html/unnamed-chunk-3-1.png" style="display: block; margin: auto;" />

here are the top few cities by tweet density

<!-- html table generated in R 3.3.0 by xtable 1.8-2 package -->
<!--  -->
<table border=1>
<tr> <th> name </th> <th> tweet.density </th> <th> n.tweets </th> <th> population </th>  </tr>
  <tr> <td> Boston MA </td> <td align="right"> 74.73 </td> <td align="right"> 297 </td> <td align="right"> 567759.00 </td> </tr>
  <tr> <td> Glendale CA </td> <td align="right"> 62.10 </td> <td align="right">  89 </td> <td align="right"> 204747.00 </td> </tr>
  <tr> <td> Fremont CA </td> <td align="right"> 57.83 </td> <td align="right">  82 </td> <td align="right"> 202574.00 </td> </tr>
  <tr> <td> Jersey City NJ </td> <td align="right"> 57.23 </td> <td align="right">  95 </td> <td align="right"> 237125.00 </td> </tr>
  <tr> <td> Newark NJ </td> <td align="right"> 48.23 </td> <td align="right">  95 </td> <td align="right"> 281378.00 </td> </tr>
  <tr> <td> Anaheim CA </td> <td align="right"> 37.96 </td> <td align="right">  89 </td> <td align="right"> 334909.00 </td> </tr>
  <tr> <td> Denver CO </td> <td align="right"> 37.73 </td> <td align="right"> 147 </td> <td align="right"> 556575.00 </td> </tr>
  <tr> <td> Santa Ana CA </td> <td align="right"> 36.95 </td> <td align="right">  89 </td> <td align="right"> 344086.00 </td> </tr>
  <tr> <td> Birmingham AL </td> <td align="right"> 33.02 </td> <td align="right">  53 </td> <td align="right"> 229300.00 </td> </tr>
  <tr> <td> Oakland CA </td> <td align="right"> 29.40 </td> <td align="right">  81 </td> <td align="right"> 393632.00 </td> </tr>
   </table>







