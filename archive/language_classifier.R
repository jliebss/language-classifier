# library(dplyr)
english_words <- readLines("./data/english.txt")
german_words  <- readLines("./data/german.txt")
spanish_words <- readLines("./data/spanish.txt")

english_words <- english_words[english_words != "" & nchar(english_words) == 5]
german_words  <- german_words[german_words   != "" & nchar(german_words) == 5]
spanish_words <- spanish_words[spanish_words != "" & nchar(spanish_words) == 5]

head(english_words)
head(german_words)
head(spanish_words)

words_text <- c(english_words, german_words, spanish_words)
words_df   <- as.data.frame(matrix(nrow=0, ncol=5))

lapply(words_text, function(x) {
  letters <- strsplit(x, "")[[1]]
  words_df[nrow(words_df)+1, ] <<- lapply(letters, utf8ToInt)
})

words_df["language"] <- c(rep(0, length(english_words)),
                          rep(1, length(german_words)),
                          rep(2, length(spanish_words)))
words_df <- words_df[complete.cases(words_df),]


set.seed(1)
sample_split <- sample(c(rep(0, 0.8*nrow(words_df)),
                         rep(1, 0.2*nrow(words_df))))

words_train <- words_df[sample_split == 0, ]
words_test  <- words_df[sample_split == 1, ]

# KNN
library(class)
knn_predicted <- knn(train = words_train[, -6],
                     test  = words_test[, -6],
                     cl    = words_train[, 6])
knn_confusion <- confusionMatrix(as.factor(knn_predicted),
                                 as.factor(words_test[, 6]))
knn_confusion$overall[1]

# SVM
library(e1071)
svm_classifier = svm(formula = language ~ .,
                 data        = words_train,
                 type        = 'C-classification',
                 kernel      = 'linear')
svm_predicted <- predict(svm_classifier, words_test[, -6])
svm_confusion <- confusionMatrix(svm_predicted,
                                 as.factor(words_test[, 6]))
svm_confusion$overall[1]

# MLP/NN
# library(caret)
library(neuralnet)

words_train$language <- as.factor(words_train$language)
words_test$language <- as.factor(words_test$language)

nn_classifier <- neuralnet(language ~ ., data = words_train, linear.output = F)
nn_classifier$net.result
plot(nn_classifier)

nn_pred <- compute(nn_classifier, words_test[, -6])
nn_predictions <- nn_pred$net.result
nn_predictions <- data.frame("predictions" = factor(ifelse(max.col(nn_predictions) == 1, 0,
                                                    ifelse(max.col(nn_predictions) == 2, 1,
                                                                                         2)),
                                                    levels = c("0", "1", "2")
                                                    )
                             )

nn_confusion <- confusionMatrix(nn_predictions$predictions,
                                words_test$language)

nn_confusion$overall[1]


# Accuracy Comparisons
accuracy_df <- data.frame(KNN = knn_confusion$overall[1],
                          SVM = svm_confusion$overall[1],
                          NN  = nn_confusion$overall[1])

library(reshape2)
accuracy_df <- melt(accuracy_df)

ggplot(accuracy_df, aes(variable, value)) +
  geom_col() +
  theme_classic() +
  coord_cartesian(expand = 0) +
  labs(x = "", y = "Accuracy", title = "Accuracy Comparison")+
  geom_text(aes(label = round(value, 2)), vjust = 1.5, colour = "white")
```


performance( prediction( z, y ), "auc" )@y.values[[1]]










