### Loading the Dataset
Cricket <- read.csv("Cricket.csv",stringsAsFactors = F)
View(Cricket)

## Strike rate and average
st_avg <- Cricket[,c(8,10)]
View(st_avg)

## Scaling
st_avg$Ave <- scale(st_avg$Ave)
st_avg$SR <- scale(st_avg$SR)

### Modeling ###

cric <- Cricket[,c("Ave","SR")]
cric <- as.data.frame(scale(cric, center = TRUE, scale = TRUE))
r_sq <- vector(mode="numeric", length=10)
for (i in 1:10)
 {
  cric.km <- kmeans(cric, center = i, iter.max = 50, nstart = 50) 
  r_sq[i] <- cric.km$betweenss/cric.km$totss
}
r_sq

### clus 4

cric.km <- kmeans(cric, center = 4, iter.max = 50, nstart = 50)
Cricket <- cbind(Cricket, cric.km$cluster)
ggplot(Cricket, aes(x = SR, y = Ave, colour = as.factor(cric.km$cluster), label= Player)) + 
         geom_point() + geom_text(size = 3)

### Hiararchical Clustering
hc = hclust(dist(cric), method = "complete")
cluster <- cutree(hc, k = 4)
ggplot(Cricket, aes(x = SR, y = Ave, colour = as.factor(Cricket$cluster), label = Player)) + geom_point() + geom_text(size = 3)



### Swirl()
library(swirl)
install_course()
swirl()
Ram
1
1
View(species)
2
plot(r_sq)
cluster_1 <- kmeans(species, centers = 3, nstart = 20)
ggplot(species,aes(Petal.Length,Petal.Width, color = factor(cluster_1$cluster))) + geom_point()

cluster_2 <- hclust(dist(species), method = "single")
plot(cluster_2)                  
rect.hclust(cluster_2, k = 3, border="red")

cluster <- cutree(cluster_2,3)
species <- cbind(species,cluster)
ggplot(species,
aes(Petal.Length, Petal.Width, color = factor(species$cluster))) + geom_point()
cluster_3 <- hclust(dist(species), method = "complete")
plot(cluster_3)
rect.hclust(cluster_3, k = 3, border="red")
clusterid <- cutree(cluster_3,3)
species <- cbind(species,clusterid)
ggplot(species, aes(Petal.Length,Petal.Width, color = factor(species$clusterid))) + geom_point()
View(species_1)
table(cluster_1$cluster, species_1$Species)
table(clusterid, species_1$Species)
0
exit()
0
