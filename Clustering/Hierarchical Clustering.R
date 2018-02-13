####### Online Retail Hierarchical Clustering ##########

### Data Preparation ###

# 1. Recency - How recently did the customer purchase ?
# 2. Freqency - How often do they purchase ?
# 3. Monetary Value - How much do they spend ?

# Loading the dataset
Online.Retail <- read.csv("Online Retail.csv",stringsAsFactors = F)

# Veiw
View(Online.Retail)

# Remove the entries row with the missing values
# Because it would be very difficult to predict the individual missing details of individual orders
order_wise <- na.omit(Online.Retail)
View(order_wise)

# Monetary: It measures how much the customer spent on purchases he/she made
Amount <- order_wise$Quantity * order_wise$UnitPrice
order_wise <- cbind(order_wise,Amount)

# Sort the data set in order of CustomerID. Next, create a new vector - monetary
# Which gives the aggregated purchase amount for each customer
library(dplyr)
order_wise <- order_wise[order(order_wise$CustomerID),]
monetary <- aggregate(Amount~CustomerID, order_wise, sum)
View(monetary) # Monetary is the M of the RFM framework

# Frequency: It measures the frequency of the transactions the customers made
frequency <- order_wise[,c(7,1)] # Seperating Customer ID and Invoice number
View(frequency)

# Converting into factor & counting the no. of invoices for each customer
temp <- table(as.factor(frequency$CustomerID)) 
View(temp)
temp <- data.frame(temp) # Converting them into DF
colnames(temp)[1] <- c("CustomerID") # Assigning colum name

# Merge this data frame with the "Frequency" of each customer 
# Into your earlier data set containing the "Monetary" value
RFM <- merge(monetary,temp,by="CustomerID")
View(RFM)

# Recency: It measures how recently you visited the store or made a purchase
recency <- order_wise[,c(7,5)] # Seperating Customer ID and Invoice Date

# Converting the dates into standart format
recency$InvoiceDate <- as.Date(recency$InvoiceDate,"%d-%m-%Y %H:%M")

# finding the latest "Invoice Date" which forms the reference point for the calculation of the "Recency" of each customer.
# For each order corresponding to each customer, we find the difference from the latest "Invoice Date" 
# and then find the minimum "Recency" value for each customer

maximum <- data.frame(max_date = rep(max(recency$InvoiceDate)+1, length(recency$InvoiceDate)))
maximum$diff <- maximum$max_date - recency$InvoiceDate
recency$diff <- maximum$diff
recency <- aggregate(recency$diff,by=list(recency$CustomerID),FUN="min")
colnames(recency)[1]<- "CustomerID"
colnames(recency)[2]<- "Recency"
View(recency)

# Merge it to the RFM data set and change the format to the required form
RFM <- merge(RFM, recency, by = ("CustomerID"))
RFM$Recency <- as.numeric(RFM$Recency)

# Eliminating all the data points which fall outside the whiskers of the box plot plotted
box <- boxplot.stats(RFM$Amount)
out <- box$out
RFM1 <- RFM[ !RFM$Amount %in% out, ]
RFM <- RFM1
box <- boxplot.stats(RFM$Freq)
out <- box$out
RFM1 <- RFM[ !RFM$Freq %in% out, ]
RFM <- RFM1
box <- boxplot.stats(RFM$Recency)
out <- box$out
RFM1 <- RFM[ !RFM$Recency %in% out, ]
RFM <- RFM1

### View the data
View(RFM)

### Summary
summary(RFM$Amount)
summary(RFM$Freq)
summary(RFM$Recency)

### Scaling ###

RFM_norma1 <- RFM[,-1]

RFM_norma1$Amount <- scale(RFM_norma1$Amount)
RFM_norma1$Freq <- scale(RFM_norma1$Freq)
RFM_norma1$Recency <- scale(RFM_norma1$Recency)

### Model Building ###

RFM_dist <- dist(RFM_norma1)

RFM_hclust1 <- hclust(RFM_dist, method = "single")
plot(RFM_hclust1)

RFM_hclust2 <- hclust(RFM_dist, method = "complete")
plot(RFM_hclust2)

# Cutting the Dendrogram & Analyzing the Clusters
rect.hclust(RFM_hclust2,k=5,border = "red") # To see the cut point & k stands for no. of clusters
rect.hclust(RFM_hclust2,h=1,border = "red") # To see the cut point & h stands height level

clusterCut <- cutree(RFM_hclust2, h = 5) # Cutting the Dendrogram
RFM_hc <- cbind(RFM,clusterCut)
colnames(RFM_hc)[5] <- "ClusterID"
View(RFM_hc)

# Group by cluster ID
hc_clusters <- group_by(RFM_hc,ClusterID)
tab2 <- summarise(hc_clusters, Mean_amount = mean(Amount),
                  Mean_freq = mean(Freq), Mean_recency = mean(Recency))
tab2
