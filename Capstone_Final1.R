
# Print the structure of amzn
str(amzn)
amzn<-amzn[complete.cases(amzn),]

# Create amzn_pros
amzn_pros<-amzn$pros

# Create amzn_cons
amzn_cons<-amzn$cons

# Print the structure of goog
str(goog)

# Create goog_pros
goog_pros<-goog$pros

# Create goog_cons
goog_cons<-goog$cons


library(qdap)
# Alter amzn_pros
amzn_pros<-qdap_clean(amzn_pros)

# Alter amzn_cons
amzn_cons<-qdap_clean(amzn_cons)

library(tm)
# Create az_p_corp 
az_p_corp<-VCorpus(VectorSource(amzn_pros))

# Create az_c_corp
az_c_corp<-VCorpus(VectorSource(amzn_cons))

# Print the content of the 15th tweet in az_p_corp
az_p_corp[[15]][1]

tm_clean <- function(corpus){
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removeWords, 
                   c(stopwords("en")))
  return(corpus)
}

# Create amzn_pros_corp
amzn_pros_corp<-tm_clean(az_p_corp)


# Create amzn_cons_corp
amzn_cons_corp<-tm_clean(az_c_corp)

# Alter goog_pros
goog_pros<-qdap_clean(goog_pros)
goog_pros<-as.character(goog_pros)
str(goog_pros1)
# Alter goog_cons
goog_cons<-qdap_clean(goog_cons)
goog_cons<-as.character(goog_cons)
# Create az_p_corp 
goog_p_corp<-VCorpus(VectorSource(goog_pros))

# Create az_c_corp
goog_c_corp<-VCorpus(VectorSource(goog_cons))

# Create goog_pros_corp
goog_pros_corp<-tm_clean(goog_p_corp)
str(goog_pros)

# Create goog_cons_corp
goog_cons_corp<-tm_clean(goog_c_corp)

library(RWeka)

tokenizer <- function(x) 
  NGramTokenizer(x, Weka_control(min = 2, max = 2))

# Create amzn_p_tdm
amzn_p_tdm <-TermDocumentMatrix(amzn_pros_corp, control = list(tokenize = tokenizer))

# Create amzn_p_tdm_m
amzn_p_tdm_m<-as.matrix(amzn_p_tdm)


# Create amzn_p_freq
amzn_p_freq<-rowSums(amzn_p_tdm_m)
amzn_p_freq1<-as.matrix(amzn_p_freq)
amzn_p_freq1
library(wordcloud)


pal2 <- brewer.pal(8,"Dark2")
#png("wordcloud_packages.png", width=12,height=8, units='in', res=300)
# Plot a wordcloud using amzn_p_freq values
wordcloud(names(amzn_p_freq), amzn_p_freq, max.words=50,scale=c(2,.2),rot.per=.5,  colors=pal2)
warnings()

# Create amzn_c_tdm
amzn_c_tdm<-TermDocumentMatrix(amzn_cons_corp,control = list(tokenize = tokenizer))

# Create amzn_c_tdm_m
amzn_c_tdm_m<-as.matrix(amzn_c_tdm)

# Create amzn_c_freq
amzn_c_freq<-rowSums(amzn_c_tdm_m)

# Plot a wordcloud of negative Amazon bigrams
wordcloud(names(amzn_c_freq) ,amzn_c_freq, max.words=30,scale=c(2,.2),rot.per=.5,color=brewer.pal(10, "PuOr"))
names(amzn_c_freq)
warnings()

install.packages("dendextend")
library(dendextend)

# Create amzn_c_tdm2 by removing sparse terms 
amzn_c_tdm2<-removeSparseTerms(amzn_c_tdm,sparse=.96)

# Create hcd as a dendogram having cluster of distance values
hcd<-as.dendrogram(hclust(dist(amzn_c_tdm2, method = "euclidean"),method="complete"))
labels(hcd)
hcd<- branches_attr_by_labels(hcd, c("commuting elk", "salary lower"),color="red")
# Produce a plot of hc
plot(hcd, main= "Dendogram showing negative bigram clusters" )
rect.dendrogram(hcd, k=3, border="blue")

# Create amzn_p_tdm
#amzn_p_tdm<-TermDocumentMatrix(amzn_pros_corp, control=list(tokenize = tokenizer))

# Create amzn_p_m
amzn_p_m<-as.matrix(amzn_p_tdm)

# Create amzn_p_freq
amzn_p_freq<-rowSums(amzn_p_m)

# Create term_frequency
term_frequency<-sort(amzn_p_freq,decreasing=TRUE)

# Print the 5 most common terms
term_frequency[1:5]

# Find associations with great pay
associations<-findAssocs(amzn_p_tdm ,"great pay", 0.2)

# View the venti associations
associations

# Create associations_df
associations_df<- list_vect2df(associations)[, 2:3]

require(ggplot2)
install.packages("ggthemes")
library(ggthemes)

# Plot the associations_df values (don't change this)
ggplot(associations_df, aes(y = associations_df[, 1])) + 
  geom_point(aes(x = associations_df[, 2]), 
             data = associations_df, size = 3) + 
  theme_gdocs()




# Create all_coffee
all_coffee<-paste(amzn_pros$text,collapse=" ")

# Create all_chardonnay
all_chardonnay<-paste(chardonnay_tweets$text, collapse=" ")

# Create all_tweets
all_tweets<-c(all_coffee, all_chardonnay)

# Convert to a vector source
all_tweets<-VectorSource(all_tweets)

# Create all_corpus
all_corpus<-VCorpus(all_tweets)

total_goog = rbind(goog_pros , goog_cons)
goog_source = DataframeSource(total_goog)
all_goog_corpus = VCorpus(goog_source)

# Create all_goog_corp
all_goog_corp<-tm_clean(all_goog_corpus)


# Create all_tdm
all_tdm<- TermDocumentMatrix(all_goog_corp)


# Name the columns of all_tdm
colnames(all_tdm) <- c("Goog_Pros", "Goog_Cons")

# Create all_m
all_m<-as.matrix(all_tdm)



# Build a comparison cloud
comparison.cloud(all_m, colors=c("#F44336", "#2196f3") ,max.words = 100,scale=c(2,.2))


#Pros_pyramid plot

amzn_pros<-as.character(amzn_pros)
goog_pros<-as.character(goog_pros)
total_pros=rbind(goog_pros , amzn_pros)
total_source = DataframeSource(total_pros)
total_pros_corpus = VCorpus(total_source)
total_pros_corp<-tm_clean(total_pros_corpus)
str(total_pros_corp)


#Create pros_tdm
library(tm)
library(RWeka)
pros_tdm <-TermDocumentMatrix(total_pros_corp, control = list(tokenize = tokenizer))

# Name the columns of pros_tdm
colnames(pros_tdm) <- c("Goog_Pros", "Amzn_Pros")
# Create all_m
#all_m<-as.matrix(all_tdm)
all_tdm_m<-as.matrix(pros_tdm)


# Create common_words
common_words <- subset(all_tdm_m, all_tdm_m[, 1] > 0 & all_tdm_m[, 2] > 0)

# Create difference
difference <- abs(common_words[, 1] - common_words[, 2])


# Add difference to common_words
common_words <- cbind(common_words, difference)

# Order the data frame from most differences to least
common_words <- common_words[order(common_words[, 3], decreasing = TRUE), ]
common_words

# Create top15_df
top15_df <- data.frame(x = common_words[1:15, 1], 
                       y = common_words[1:15, 2], 
                       labels = rownames(common_words[1:15, ]))
install.packages("plotrix")
library(plotrix)
# Create the pyramid plot
pyramid.plot(top15_df$x, top15_df$y, 
             labels = top15_df$labels, gap = 12, 
             top.labels = c("Amzn", "Pro Words", "Google"), 
             main = "Words in Common", unit = NULL)


#Cons pyramid plot
goog_cons<-as.character(goog_cons)
amzn_cons<-as.character(amzn_cons)
#amzn_cons<-as.factor(amzn_cons)
#goog_cons<-as.factor(goog_cons)
total_cons=rbind(goog_cons , amzn_cons)
total_source = DataframeSource(total_cons)
total_cons_corpus = VCorpus(total_source)

#total_cons_corpus<-as.factor(total_cons_corpus)
total_cons_corp<-tm_clean(total_cons_corpus)
is.na(total_cons_corp)
#Create pros_tdm
library(tm)
library(RWeka)

cons_tdm <-TermDocumentMatrix(total_cons_corp,  control = list(tokenize = tokenizer))
str(total_cons_corp)


# Name the columns of pros_tdm
colnames(cons_tdm) <- c("Goog_Cons", "Amzn_Cons")
# Create all_tdm_m
all_tdm_m<-as.matrix(cons_tdm)

# Create common_words
common_words <- subset(all_tdm_m, all_tdm_m[, 1] > 0 & all_tdm_m[, 2] > 0)

# Create difference
difference<- abs(common_words[, 1] - common_words[, 2])

# Bind difference to common_words
common_words <- cbind(common_words, difference)

# Order the data frame from most differences to least
common_words <- common_words[order(common_words[, 3], decreasing = TRUE), ]

# Create top15_df
top15_df <- data.frame(x = common_words1[1:15, 1], 
                       y = common_words1[1:15, 2], 
                       labels = rownames(common_words1[1:15, ]))

# Create the pyramid plot
pyramid.plot(top15_df1$x, top15_df1$y, 
             labels = top15_df1$labels, gap = 12, 
             top.labels = c("Amzn", "Cons Words", "Google"), 
             main = "Words in Common", unit = NULL)
str(total_pros_corpus)
