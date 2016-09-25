# Leading Cities in #rstats Twipermipeds
Winston Saunders  
September 22, 2016  

# Summary

The question "what's the best city for data science?" was asked on the Sept ["Not So Standard Deviations"](https://www.patreon.com/NSSDeviations) podcast. To inject some analysis in the discussion, I used the `twitteR` package to measure interest in __R__ by computing the "flux" of tweets with the `#rstats` hashtag.   
The top metro areas are New York, Boston, and the SF Bay area, with a tweet flux of about 50 #rstat tweets per million residents per day ("twipermipeds"). Other leading cities include Long Beach, Washington DC, Seattle, Raleigh NC, and Henderson NV.  
Even Portland, Oregon (*yay*) weighs-in within the top 15 on tweets.
Results are sensitive to assumptions about metro size and show some short term time dependency.   
This was quick and dirty so no telling how stable the result will be over longer time.  

# Problem Statement

In their September NSSD Podcast, Hilary and Roger discussed "_the best city for data science._" Let's try measuring something just to inject a little analysis into the discussion. 






# Where do I get data?

Twitter is a good source of data on "interest" in topics since it is both timely and social. 

## Tweets, the Twitter API, and twitteR package.

Setting up the twitter API is relatively quick. 


```r
library(twitteR)
## create URLs
reqURL <- "https://api.twitter.com/oauth/request_token"
accessURL <- "https://api.twitter.com/oauth/access_token"
authURL <- "https://api.twitter.com/oauth/authorize"

## read file containing secret keys (obtained from apps.twitter.com)
keys <- read.table("/users/winstonsaunders/documents/city_politics/secret_t.key.txt", stringsAsFactors = FALSE, col.names = "secret" )
## convert to characters (read.table coerces to a factor)
consumerKey       <- keys$secret[1] 
consumerSecret    <- keys$secret[2] 
accessToken       <- keys$secret[3] 
accessTokenSecret <- keys$secret[4] 

## set up authentication
setup_twitter_oauth(consumerKey, consumerSecret, accessToken, accessTokenSecret)
```

```
[1] "Using direct authentication"
```

Test functionality with George Takei's latest tweet


```r
## test functionanlity with georgetakei tweets
userTimeline(getUser('georgetakei'), n=1, includeRts=FALSE, excludeReplies=FALSE)[[1]]
```

```
[1] "GeorgeTakei: Trump has reimbursed his own companies 8.2mil in campaign expenses. He once said he should run for president b/c he'd make a lot of money..."
```

it works!  

## City populations and geo-locations

We'll also need to localize tweets to cities and thus need the lat and lon of major US cities. It's alos be nice to mormalize the data to population. It turns out sity coordinates and populations are available in the super-convenient  [`{maps}`](https://cran.r-project.org/web/packages/maps/index.html) package. 


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
 
According to the package, the top US cities by population are:  

<!-- html table generated in R 3.3.0 by xtable 1.8-2 package -->
<!--  -->
<table border=1>
<tr> <th> name </th> <th> country.etc </th> <th> pop </th> <th> lat </th> <th> long </th> <th> capital </th> <th> city_name </th>  </tr>
  <tr> <td align="right"> New York NY </td> <td align="center"> NY </td> <td align="center"> 8124427 </td> <td align="center"> 40.67 </td> <td align="center"> -73.94 </td> <td align="center">   0 </td> <td align="center"> New York </td> </tr>
  <tr> <td align="right"> Los Angeles CA </td> <td align="center"> CA </td> <td align="center"> 3911500 </td> <td align="center"> 34.11 </td> <td align="center"> -118.41 </td> <td align="center">   0 </td> <td align="center"> Los Angeles </td> </tr>
  <tr> <td align="right"> Chicago IL </td> <td align="center"> IL </td> <td align="center"> 2830144 </td> <td align="center"> 41.84 </td> <td align="center"> -87.68 </td> <td align="center">   0 </td> <td align="center"> Chicago </td> </tr>
  <tr> <td align="right"> Houston TX </td> <td align="center"> TX </td> <td align="center"> 2043005 </td> <td align="center"> 29.77 </td> <td align="center"> -95.39 </td> <td align="center">   0 </td> <td align="center"> Houston </td> </tr>
   </table>

Looks right...

## Getting the tweets

To get the tweet data use the `twitteR::searchTwiter` command. 
Data collection is with the following variables. 


```r
## set up search terms
searchString.x <- "#rstats"    # search term
n.x <- 900                     # number of tweets
radius <- "10mi"               # radius around selected geo-location
duration.days <- 14             # how many days
since.date <- (Sys.Date() - duration.days) %>% as.character # calculated starting date
```

Note the radius of 10mi, which is used to localize tweet collected around specific geo-locations.  For cases, where major cities are in close proximity, this certainly picks up some redundant tweets. More work needed here...



```r
n.cities <- 57
```

I pull data for the top 57 cities (by population) in the U.S. This includes cities from New York NY to Riverside CA.

# Analysis

Once collected, the data are lightly analyzed. Specifically the 'tweet.flux', representing the number of tweets per million people per day ("twipermipeds"), is computed.


```r
analyzed_df <- collected_df %>% 
    mutate("tweet.flux" = 10^6 * n.tweets/population/duration.days ) %>% 
    select(name, lon, lat, tweet.flux, n.tweets, population)
```



Collected data are put into  `collected_df`. For this first-pass analysis tweets are counted but are not cached. 

# So, what _does_ the Tweet-Map look like?

Use the `{ggmap}` package to get a base Google map.


```r
    library(ggmap)
    map = get_googlemap(center =  c(lon = -95.58, lat = 36.83), 
              zoom = 3, size = c(390, 250), scale = 2, source = "google",
              maptype="roadmap") #, key = my.secret.key)
    map.plot <- ggmap(map)
```

After that standard `ggplot2` functions are used to plot the data. Note that several dimensions of data are shown. The latitude and longitude reprsent the geolocation of the town. The size of the point represents the number of tweets `n.tweets` and the shading of the dot represents the `tweet.flux` in "twipermipeds.""


```r
map.plot +
    geom_point(aes(x = lon, y = lat, fill = tweet.flux, size = n.tweets), data=analyzed_df, pch=21, color = "#33333399") +
    ggtitle(paste0(searchString.x, " tweets for ", duration.days," days since ", since.date, " within ", radius, " of metro center")) +
    scale_fill_gradient(low = "#BBBBFF", high = "#EE3300", space = "Lab", na.value = "grey50", guide = "colourbar")
```

<img src="USAMapTest1_files/figure-html/unnamed-chunk-5-1.png" style="display: block; margin: auto;" />

# What are the top cities in #rstats?

## AMB twipermipeds

Here are the top few cities by tweet flux (in "twipermipeds").

<!-- html table generated in R 3.3.0 by xtable 1.8-2 package -->
<!--  -->
<table border=1>
<tr> <th> name </th> <th> tweet.flux </th> <th> n.tweets </th> <th> population </th>  </tr>
  <tr> <td> Boston MA </td> <td align="right"> 60.89 </td> <td align="right"> 484 </td> <td align="right"> 567759 </td> </tr>
  <tr> <td> Oakland CA </td> <td align="right"> 14.15 </td> <td align="right">  78 </td> <td align="right"> 393632 </td> </tr>
  <tr> <td> WASHINGTON DC </td> <td align="right"> 13.55 </td> <td align="right"> 104 </td> <td align="right"> 548359 </td> </tr>
  <tr> <td> Seattle WA </td> <td align="right"> 9.27 </td> <td align="right">  74 </td> <td align="right"> 570430 </td> </tr>
  <tr> <td> Chicago IL </td> <td align="right"> 8.10 </td> <td align="right"> 321 </td> <td align="right"> 2830144 </td> </tr>
  <tr> <td> Arlington TX </td> <td align="right"> 4.57 </td> <td align="right">  24 </td> <td align="right"> 374729 </td> </tr>
  <tr> <td> Portland OR </td> <td align="right"> 3.68 </td> <td align="right">  28 </td> <td align="right"> 542751 </td> </tr>
  <tr> <td> Jacksonville FL </td> <td align="right"> 3.62 </td> <td align="right">  41 </td> <td align="right"> 809874 </td> </tr>
  <tr> <td> Tampa FL </td> <td align="right"> 3.48 </td> <td align="right">  16 </td> <td align="right"> 328578 </td> </tr>
  <tr> <td> Las Vegas NV </td> <td align="right"> 2.97 </td> <td align="right">  23 </td> <td align="right"> 553807 </td> </tr>
  <tr> <td> Fort Worth TX </td> <td align="right"> 2.70 </td> <td align="right">  24 </td> <td align="right"> 633849 </td> </tr>
  <tr> <td> San Francisco CA </td> <td align="right"> 2.37 </td> <td align="right">  24 </td> <td align="right"> 723724 </td> </tr>
  <tr> <td> Atlanta GA </td> <td align="right"> 2.36 </td> <td align="right">  14 </td> <td align="right"> 424096 </td> </tr>
  <tr> <td> New York NY </td> <td align="right"> 2.02 </td> <td align="right"> 230 </td> <td align="right"> 8124427 </td> </tr>
  <tr> <td> Denver CO </td> <td align="right"> 1.93 </td> <td align="right">  15 </td> <td align="right"> 556575 </td> </tr>
   </table>

## AMB tweets

Here are the top few cities sorted by raw tweets, again with major metro areas leading. Note that some other cities, like Chicago, have a large number of tweets but a lower flux because of their higher population.

<!-- html table generated in R 3.3.0 by xtable 1.8-2 package -->
<!--  -->
<table border=1>
<tr> <th> name </th> <th> tweet.flux </th> <th> n.tweets </th> <th> population </th>  </tr>
  <tr> <td> Boston MA </td> <td align="right"> 60.89 </td> <td align="right"> 484 </td> <td align="right"> 567759 </td> </tr>
  <tr> <td> Chicago IL </td> <td align="right"> 8.10 </td> <td align="right"> 321 </td> <td align="right"> 2830144 </td> </tr>
  <tr> <td> New York NY </td> <td align="right"> 2.02 </td> <td align="right"> 230 </td> <td align="right"> 8124427 </td> </tr>
  <tr> <td> WASHINGTON DC </td> <td align="right"> 13.55 </td> <td align="right"> 104 </td> <td align="right"> 548359 </td> </tr>
  <tr> <td> Los Angeles CA </td> <td align="right"> 1.79 </td> <td align="right">  98 </td> <td align="right"> 3911500 </td> </tr>
  <tr> <td> Oakland CA </td> <td align="right"> 14.15 </td> <td align="right">  78 </td> <td align="right"> 393632 </td> </tr>
  <tr> <td> Seattle WA </td> <td align="right"> 9.27 </td> <td align="right">  74 </td> <td align="right"> 570430 </td> </tr>
  <tr> <td> Jacksonville FL </td> <td align="right"> 3.62 </td> <td align="right">  41 </td> <td align="right"> 809874 </td> </tr>
  <tr> <td> Portland OR </td> <td align="right"> 3.68 </td> <td align="right">  28 </td> <td align="right"> 542751 </td> </tr>
  <tr> <td> Houston TX </td> <td align="right"> 0.84 </td> <td align="right">  24 </td> <td align="right"> 2043005 </td> </tr>
  <tr> <td> San Francisco CA </td> <td align="right"> 2.37 </td> <td align="right">  24 </td> <td align="right"> 723724 </td> </tr>
  <tr> <td> Fort Worth TX </td> <td align="right"> 2.70 </td> <td align="right">  24 </td> <td align="right"> 633849 </td> </tr>
  <tr> <td> Arlington TX </td> <td align="right"> 4.57 </td> <td align="right">  24 </td> <td align="right"> 374729 </td> </tr>
  <tr> <td> Las Vegas NV </td> <td align="right"> 2.97 </td> <td align="right">  23 </td> <td align="right"> 553807 </td> </tr>
  <tr> <td> Philadelphia PA </td> <td align="right"> 1.04 </td> <td align="right">  21 </td> <td align="right"> 1439814 </td> </tr>
   </table>

# Summary  

Using `#rstats` tweets, we find Boston leads in overal tweets, followed by Chicago and NYC. Tweet flux shows a different behavior with Boston still leading, but less populous cities moving up the ranks in social discussions about __R__. This says little, directly, about overall 'data science', but it does indicate that heavy usage of a powerful data science tool is localized to a handful of US cities.   
Results show short term instablity - even within a period of hours, results can change. While problematic for this particular analysis, it does suggest the methodology may potentially be used to address other questions of timely reactions.      
Normalizing the data for flux measurement is a key challenge. For instance it's likely many of the same tweets are captured for both Newark and Jersey City (since they are in close proximity) representing a double-counting that would alter the tweet flux measurement. Including things like metropolitain areas, "likely" users, numbers of startups and academic institutions, etc could possibly improve the methodology.     
> "twipermipeds" == definitely a thing.    
  




