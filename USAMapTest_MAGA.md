# Leading Cities in #MAGA tweet flux
Winston Saunders  
September 23, 2016  

# get Tweets








```r
## set up search terms
searchString.x <- "#MAGA"    # search term
n.x <- 3000                     # number of tweets
radius <- "10mi"               # radius around selected geo-location
duration.days <- 1             # how many days
since.date <- (Sys.Date() - duration.days) %>% as.character # calculated starting date
```

looking at #MAGA for geo preference.


```
[1] "Using direct authentication"
```





 


 




To get the tweet data use the `twitteR::searchTwiter` command. 
Data collection is with the following variables. 



```r
n.cities <- 100
```

```
[1] "Rate limited .... blocking for a minute and retrying up to 119 times ..."
[1] "Rate limited .... blocking for a minute and retrying up to 118 times ..."
[1] "Rate limited .... blocking for a minute and retrying up to 117 times ..."
[1] "Rate limited .... blocking for a minute and retrying up to 116 times ..."
[1] "Rate limited .... blocking for a minute and retrying up to 115 times ..."
[1] "Rate limited .... blocking for a minute and retrying up to 114 times ..."
[1] "Rate limited .... blocking for a minute and retrying up to 113 times ..."
[1] "Rate limited .... blocking for a minute and retrying up to 112 times ..."
[1] "Rate limited .... blocking for a minute and retrying up to 111 times ..."
[1] "Rate limited .... blocking for a minute and retrying up to 110 times ..."
[1] "Rate limited .... blocking for a minute and retrying up to 119 times ..."
[1] "Rate limited .... blocking for a minute and retrying up to 118 times ..."
[1] "Rate limited .... blocking for a minute and retrying up to 117 times ..."
```

Data for the top 100 cities (by population) in the U.S. This includes cities from New York NY to Irvine CA.






# Tweet-Map for #MAGA?







```r
map.plot +
    geom_point(aes(x = lon, y = lat, fill = tweet.flux, size = n.tweets), data=analyzed_df, pch=21, color = "#33333399") +
    ggtitle(paste0(searchString.x, " tweets in ", duration.days," days since ", since.date, " r = ", radius)) +
    scale_fill_gradient(low = "#BBBBFF", high = "#EE3300", space = "Lab", na.value = "grey50", guide = "colourbar")
```

<img src="USAMapTest_MAGA_files/figure-html/unnamed-chunk-5-1.png" style="display: block; margin: auto;" />



## AMB tweet-flux

Here are the top few cities by tweet flux (in "twipermipeds").

<!-- html table generated in R 3.3.0 by xtable 1.8-2 package -->
<!--  -->
<table border=1>
<tr> <th> name </th> <th> tweet.flux </th> <th> n.tweets </th> <th> population </th>  </tr>
  <tr> <td> Jersey City NJ </td> <td align="right"> 12651.56 </td> <td align="right"> 3000 </td> <td align="right"> 237125 </td> </tr>
  <tr> <td> Newark NJ </td> <td align="right"> 10661.81 </td> <td align="right"> 3000 </td> <td align="right"> 281378 </td> </tr>
  <tr> <td> Hialeah FL </td> <td align="right"> 8279.77 </td> <td align="right"> 1860 </td> <td align="right"> 224644 </td> </tr>
  <tr> <td> Glendale CA </td> <td align="right"> 6969.58 </td> <td align="right"> 1427 </td> <td align="right"> 204747 </td> </tr>
  <tr> <td> Atlanta GA </td> <td align="right"> 4921.06 </td> <td align="right"> 2087 </td> <td align="right"> 424096 </td> </tr>
  <tr> <td> Miami FL </td> <td align="right"> 4729.28 </td> <td align="right"> 1829 </td> <td align="right"> 386740 </td> </tr>
  <tr> <td> WASHINGTON DC </td> <td align="right"> 3043.63 </td> <td align="right"> 1669 </td> <td align="right"> 548359 </td> </tr>
  <tr> <td> Paradise NV </td> <td align="right"> 2736.92 </td> <td align="right"> 605 </td> <td align="right"> 221051 </td> </tr>
  <tr> <td> Louisville KY </td> <td align="right"> 1862.51 </td> <td align="right"> 449 </td> <td align="right"> 241072 </td> </tr>
  <tr> <td> Las Vegas NV </td> <td align="right"> 980.49 </td> <td align="right"> 543 </td> <td align="right"> 553807 </td> </tr>
  <tr> <td> Chula Vista CA </td> <td align="right"> 717.07 </td> <td align="right"> 159 </td> <td align="right"> 221736 </td> </tr>
  <tr> <td> Detroit MI </td> <td align="right"> 532.24 </td> <td align="right"> 464 </td> <td align="right"> 871789 </td> </tr>
  <tr> <td> Oakland CA </td> <td align="right"> 482.68 </td> <td align="right"> 190 </td> <td align="right"> 393632 </td> </tr>
  <tr> <td> Boston MA </td> <td align="right"> 433.28 </td> <td align="right"> 246 </td> <td align="right"> 567759 </td> </tr>
  <tr> <td> Cleveland OH </td> <td align="right"> 387.43 </td> <td align="right"> 172 </td> <td align="right"> 443949 </td> </tr>
   </table>

## AMB tweet count

Here are the top few cities sorted by raw tweets, again with major metro areas leading. Note that some other cities, like Chicago, have a large number of tweets but a lower flux because of their higher population.

<!-- html table generated in R 3.3.0 by xtable 1.8-2 package -->
<!--  -->
<table border=1>
<tr> <th> name </th> <th> tweet.flux </th> <th> n.tweets </th> <th> population </th>  </tr>
  <tr> <td> New York NY </td> <td align="right"> 369.26 </td> <td align="right"> 3000 </td> <td align="right"> 8124427 </td> </tr>
  <tr> <td> Newark NJ </td> <td align="right"> 10661.81 </td> <td align="right"> 3000 </td> <td align="right"> 281378 </td> </tr>
  <tr> <td> Jersey City NJ </td> <td align="right"> 12651.56 </td> <td align="right"> 3000 </td> <td align="right"> 237125 </td> </tr>
  <tr> <td> Atlanta GA </td> <td align="right"> 4921.06 </td> <td align="right"> 2087 </td> <td align="right"> 424096 </td> </tr>
  <tr> <td> Hialeah FL </td> <td align="right"> 8279.77 </td> <td align="right"> 1860 </td> <td align="right"> 224644 </td> </tr>
  <tr> <td> Miami FL </td> <td align="right"> 4729.28 </td> <td align="right"> 1829 </td> <td align="right"> 386740 </td> </tr>
  <tr> <td> WASHINGTON DC </td> <td align="right"> 3043.63 </td> <td align="right"> 1669 </td> <td align="right"> 548359 </td> </tr>
  <tr> <td> Los Angeles CA </td> <td align="right"> 378.37 </td> <td align="right"> 1480 </td> <td align="right"> 3911500 </td> </tr>
  <tr> <td> Glendale CA </td> <td align="right"> 6969.58 </td> <td align="right"> 1427 </td> <td align="right"> 204747 </td> </tr>
  <tr> <td> Paradise NV </td> <td align="right"> 2736.92 </td> <td align="right"> 605 </td> <td align="right"> 221051 </td> </tr>
  <tr> <td> Las Vegas NV </td> <td align="right"> 980.49 </td> <td align="right"> 543 </td> <td align="right"> 553807 </td> </tr>
  <tr> <td> Detroit MI </td> <td align="right"> 532.24 </td> <td align="right"> 464 </td> <td align="right"> 871789 </td> </tr>
  <tr> <td> Louisville KY </td> <td align="right"> 1862.51 </td> <td align="right"> 449 </td> <td align="right"> 241072 </td> </tr>
  <tr> <td> Phoenix AZ </td> <td align="right"> 184.03 </td> <td align="right"> 267 </td> <td align="right"> 1450884 </td> </tr>
  <tr> <td> Boston MA </td> <td align="right"> 433.28 </td> <td align="right"> 246 </td> <td align="right"> 567759 </td> </tr>
   </table>

  
  




