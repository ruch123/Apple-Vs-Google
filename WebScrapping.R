library(rvest)
library(purrr)


url_base <- "https://www.indeed.com/cmp/Paypal/reviews?fcountry=ALL"

map_df(1:100, function(i) {
  
  # simple but effective progress indicator
  cat(".")
  
  pg <- read_html(sprintf(url_base, i))
  
 
  
  data.frame(pros=html_text(html_nodes(pg, ".cmp-review-pro-text")),
             cons=html_text(html_nodes(pg, ".cmp-review-con-text")),
             #rating=gsub(" Points", "", html_text(html_nodes(pg, "span.rating"))),
             #appellation=html_text(html_nodes(pg, "span.appellation")),
             #price=gsub("\\$", "", html_text(html_nodes(pg, "span.price"))),
             stringsAsFactors=FALSE)
  
})->paypal

write.csv(paypal, "C:/Users/i037805/Desktop/paypal.csv")
head(paypal)
