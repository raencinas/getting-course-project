## Course Project - Getting and Cleaning Data

## Download and unzip the dataset.
temp <- tempfile()
fileUrl <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = temp, mode = "wb")
unzip(temp, exdir = ".")
unlink(temp)

## Reading data into [R]
features <- read.table("./UCI HAR Dataset/features.txt")
activity_type <- read.table("./UCI HAR Dataset/activity_labels.txt")
x_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/Y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
x_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/Y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

## Assigin column names to the data
colnames(activity_type) <- c('activityId','activityType');
colnames(subject_train) <- "subjectId";
colnames(x_train) <- features[,2]; 
colnames(y_train) <- "activityId";
colnames(subject_test) <- "subjectId";
colnames(x_test) <- features[,2]; 
colnames(y_test) <- "activityId";

#############################################################################

## 1 Merges the training and the test sets to create one data set.
## 1.1 Merges the test data
test_data <- cbind(y_test, subject_test, x_test)

## 1.2 Merges the train data
train_data <- cbind(y_train, subject_train, x_train)

## 1.3 Merges the test and train data
full_data <- rbind(test_data, train_data)

#############################################################################

## 2. Extracts only the measurements on the mean and standard deviation for 
## each measurement.

## 2.1 Creates a data.frame with columns and if they have "mean" or "std"
colnames <- names(full_data) # vector with colnames
mean <- grepl("mean", colnames) # vector with TRUE for "mean" in colnames
std <- grepl("std", colnames) # vector with TRUE for "std" in colnames 
mean_std <- as.data.frame(cbind(colnames, mean, std)) # creating data.frame 
rownames(mean_std) <- 1:563 


## 2.2 Now select the number of the columns that have "mean" or "std"
ms <- as.numeric(rownames(mean_std[which(mean_std$"mean" == "TRUE" | 
                                      mean_std$"std" == "TRUE"),])) 

## 2.3 Extract the columns with "mean" or "std", and columns "activityId" and
## "subjectId
full_data_ms <- full_data[,c(1,2,ms)]

############################################################################

## 3. Use descriptive activity names to name the activities in the data set

## 3.1 Merge full_data_ms with the acitivity_type table to include 
## descriptive activity names

full_data_ms <- merge(full_data_ms,activity_type,by='activityId',all.x=TRUE)

#############################################################################

## 4. Appropriately labels the data set with descriptive variable names. 

## 4.1 Assign the name of the columns to a vector
colNames <- colnames(full_data_ms)

## 4.2 Clarify the column names
for (i in 1:length(colNames)) {
        colNames[i] = gsub("\\()","",colNames[i])
        colNames[i] = gsub("-std$","StdDev",colNames[i])
        colNames[i] = gsub("-mean","Mean",colNames[i])
        colNames[i] = gsub("^(t)","time",colNames[i])
        colNames[i] = gsub("^(f)","freq",colNames[i])
        colNames[i] = gsub("([Gg]ravity)","Gravity",colNames[i])
        colNames[i] = gsub("([Bb]ody[Bb]ody|[Bb]ody)","Body",colNames[i])
        colNames[i] = gsub("[Gg]yro","Gyro",colNames[i])
        colNames[i] = gsub("AccMag","AccMagnitude",colNames[i])
        colNames[i] = gsub("([Bb]odyaccjerkmag)","BodyAccJerkMagnitude",colNames[i])
        colNames[i] = gsub("JerkMag","JerkMagnitude",colNames[i])
        colNames[i] = gsub("GyroMag","GyroMagnitude",colNames[i])
        }

## Assign the new column names to the dataset
colnames(full_data_ms) <- colNames

#############################################################################

## 5. From the data set in step 4, creates a second, independent tidy data set 
## with the average of each variable for each activity and each subject.

## 5.1 Melt the full data set to create a tall table
library(reshape2)
full_data_melt <- melt(full_data_ms, id=c("activityId","activityType","subjectId"))

## 5.2 Creates a new data set with the average of each variable for each 
## activity and each subject. I had problems with the function dcast qhen I
## "mean" as the aggregate function, with this message: "Error in 
## vaggregate(.value = value, .group = overall, .fun = fun.aggregate,  : 
## could not find function ".fun"". So I created another function for mean.
mean_2 <- function(x){
        mean(x)
        }
new_data <- dcast(full_data_melt, activityType + subjectId ~ variable,mean_2)

## 5.3 Export the new tidy dataset
write.table(new_data, './new_data.txt',row.names=FALSE)

