
# File Impoting
hr_analytics <- read.csv("hr_analytics.csv")
str(hr_analytics)

# baseline accuracy
prop.table(table(hr_analytics$salary))

# divide into train and test set
set.seed(123)
split.indices <- sample(nrow(hr_analytics), nrow(hr_analytics)*0.8, replace = F)
train <- hr_analytics[split.indices, ]
test <- hr_analytics[-split.indices, ]

# Classification Trees
library(rpart)
library(rpart.plot)
library(caret)

#1 build tree model- default hyperparameters
tree.model <- rpart(salary ~ .,                     # formula
                    data = train,                   # training data
                    method = "class")               # classification or regression

# display decision tree
prp(tree.model)

# make predictions on the test set
tree.predict <- predict(tree.model, test, type = "class")

# evaluate the results
confusionMatrix(tree.predict, test$salary)

#2 Changing the algorithm to "information gain" instead of default "gini"
tree.model <- rpart(salary ~ .,                     # formula
                    data = train,                   # training data
                    method = "class",               # classification or regression
                    parms = list(split = "information")
                    )

# display decision tree
prp(tree.model)

# make predictions on the test set
tree.predict <- predict(tree.model, test, type = "class")

# evaluate the results
confusionMatrix(tree.predict, test$salary)

#3 Tune the hyperparameters ----------------------------------------------------------
tree.model <- rpart(salary ~ .,                                # formula
                     data = train,                             # training data
                     method = "class",                         # classification or regression
                     control = rpart.control(minsplit = 1000,  # min observations for node
                                             minbucket = 1000, # min observations for leaf node
                                             cp = 0.05))       # complexity parameter

# display decision tree
prp(tree.model)

# make predictions on the test set
tree.predict <- predict(tree.model, test, type = "class")

# evaluate the results
confusionMatrix(tree.predict, test$salary)

#4 A more complex tree -----------------------------------------------------------------
tree.model <- rpart(salary ~ .,                                # formula
                     data = train,                             # training data
                     method = "class",                         # classification or regression
                     control = rpart.control(minsplit = 1,     # min observations for node
                                             minbucket = 1,    # min observations for leaf node
                                             cp = 0.001))      # complexity parameter

# display decision tree
prp(tree.model)

# make predictions on the test set
tree.predict <- predict(tree.model, test, type = "class")

# evaluate the results
confusionMatrix(tree.predict, test$salary) 

#5 Cross test to choose CP ------------------------------------------------------------
library(caret)

# set the number of folds in cross test to 5
tree.control = trainControl(method = "cv", number = 5)

# set the search space for CP
tree.grid = expand.grid(cp = seq(0, 0.02, 0.0025))

# train model
tree.model <- train(salary ~ .,
                     data = train,
                     method = "rpart",
                     metric = "Accuracy",
                     trControl = tree.control,
                     tuneGrid = tree.grid,
                     control = rpart.control(minsplit = 50,
                                             minbucket = 20))

# cross validated model results
tree.model

# look at best value of hyperparameter
tree.model$bestTune

# make predictions on test set
tree.predict <- predict.train(tree.model, test)

# accuracy
confusionMatrix(tree.predict, test$salary)  

# plot CP vs Accuracy
library(ggplot2)
accuracy_graph <- data.frame(tree.model$results)
ggplot(data = accuracy_graph, aes(x = cp, y = Accuracy*100)) +
        geom_line() +
        geom_point() +
        labs(x = "Complexity Parameter (CP)", y = "Accuracy", title = "CP vs Accuracy")



