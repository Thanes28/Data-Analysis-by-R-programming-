library(ggplot2)
library(tidyverse)
library(dplyr)

myData <- read.csv("C:\\Users\\User\\OneDrive\\Data analysis\\Assignment\\hackingData.csv")
head(myData)
View(myData)

# Count NA values for each column
colSums(is.na(myData))

data.frame(
  Column = names(myData),
  NA_Count = colSums(is.na(myData)),
  Empty_String_Count = sapply(myData, function(x) sum(x == "", na.rm = TRUE)),
  Null_String_Count = sapply(myData, function(x) sum(x == "NULL", na.rm = TRUE))
)

#Replace the empty Values with NULL 

myData$Notify[myData$Notify == ""] <- "NULL"
myData$URL[myData$URL == ""] <- "NULL"
myData$IP[myData$IP == ""] <- "NULL"
myData$Country[myData$Country == ""] <- "NULL"
myData$OS[myData$OS == ""] <- "NULL"
myData$WebServer[myData$WebServer == ""] <- "NULL"
myData$Encoding[myData$Encoding == ""] <- "NULL"
myData$Lang[myData$Lang == ""] <- "NULL"

#Recheck wether the NULL values already replace or not. 
data.frame(
  Column = names(myData),
  NA_Count = colSums(is.na(myData)),
  Empty_String_Count = sapply(myData, function(x) sum(x == "", na.rm = TRUE)),
  Null_String_Count = sapply(myData, function(x) sum(x == "NULL", na.rm = TRUE))
)

#Remove the NA values which is missing values from dataset
myData <- myData[!is.na(myData$Ransom) & !is.na(myData$Loss), ]

#Recheck wether the NA values removed or not 
data.frame(
  Column = names(myData),
  NA_Count = colSums(is.na(myData)),
  Empty_String_Count = sapply(myData, function(x) sum(x == "", na.rm = TRUE)),
  Null_String_Count = sapply(myData, function(x) sum(x == "NULL", na.rm = TRUE))
)

write.csv(myData, "DataCleaned.csv", row.names = FALSE)

# Thaneswaran, TP070624

# 1 Objective = Trend Analysis of Hacking Incidents Over Time
# Analysis 1.1 = Yearly Trend of Hacking Incidents

library(ggplot2)
library(dplyr)
library(scales)
myData$Date <- as.Date(myData$Date, format="%d/%m/%Y")
myData$Year <- format(myData$Date, "%Y")

yearly_attacks <- myData %>%
  group_by(Year) %>%
  summarise(Count = n())

ggplot(yearly_attacks, aes(x = Year, y = Count)) +
  geom_line(group=1, color="blue") +
  theme_minimal() +
  labs(title="Yearly Trend of Hacking Incidents", x="Year", y="Number of Attacks")

# Analysis 1.2 = Monthly Pattern of Attacks
myData$Month <- format(myData$Date, "%m")

monthly_attacks <- myData %>%
  group_by(Month) %>%
  summarise(Count = n())

ggplot(monthly_attacks, aes(x = Month, y = Count)) +
  geom_bar(stat="identity", fill="red") +
  theme_minimal() +
  labs(title="Monthly Distribution of Hacking Incidents", x="Month", y="Number of Attacks")



# Analysis 1.3 = Correlation Between Downtime and Loss
correlation <- cor(myData$DownTime, myData$Loss, use="complete.obs")
print(paste("Correlation between downtime and loss:", correlation))

ggplot(myData, aes(x = DownTime, y = Loss)) +
  geom_point(alpha=0.5) +
  geom_smooth(method="lm", col="blue") +
  theme_minimal() +
  labs(title="Correlation Between Downtime and Loss", x="Downtime (hours)", y="Loss ($)")

# Analysis 1.4 = Peak Years for Cyberattacks
top_years <- yearly_attacks %>%
  arrange(desc(Count)) %>%
  head(5)

print(top_years)

#Extra Feature for Analysis 1.2 (TP070624)
# Can see the proper months name accordingly, and can identify the case number more easily with each month 

myData$Month <- format(as.Date(myData$Date, format="%d-%m-%Y"), "%B")  # Convert numbers to full month names
myData$Month <- factor(myData$Month, levels = month.name)  # Order months correctly

str(myData$Month)

# Summarize number of attacks per month
monthly_attacks <- myData %>%
  group_by(Month) %>%
  summarise(Count = n())

# Plot the enhanced bar chart
ggplot(monthly_attacks, aes(x = Month, y = Count, fill = Count)) +
  geom_bar(stat="identity") +
  geom_text(aes(label=Count), vjust=-0.5, size=4, fontface="bold") +  # Add data labels
  scale_fill_gradient(low = "yellow", high = "red") +  # Gradient color based on attack frequency
  theme_minimal() +
  labs(title="Monthly Distribution of Hacking Incidents", 
       x="Month", 
       y="Number of Attacks") +
  theme(axis.text.x = element_text(angle=45, hjust=1))  # Rotate x-axis labels for readability


# 2 Objective = Geographic Analysis of Attacks
# Analysis 2.1 = Top Countries with Most Attacks

country_attacks <- myData %>%
  group_by(country_summary) %>%
  summarise(Count = n()) %>%
  arrange(desc(Count))

ggplot(country_attacks[1:10,], aes(x = reorder(Country, -Count), y = Count)) +
  geom_bar(stat="identity", fill="purple") +
  coord_flip() +
  theme_minimal() +
  labs(title="Top 10 Countries with Most Attacks", x="Country", y="Number of Attacks")

# Analysis 2.2 =  Financial Loss by Country
options(scipen = 999)

country_loss <- myData %>%
  group_by(country_summary) %>%
  summarise(Total_Loss = sum(Loss, na.rm=TRUE)) %>% 
  arrange(desc(Total_Loss))

ggplot(country_summary[1:10,], aes(x = reorder(Country, -Total_Loss), y = Total_Loss, fill = Total_Loss)) +
  geom_bar(stat="identity") +
  coord_flip() +
  theme_minimal() +
  scale_fill_gradient(low = "yellow", high = "red") +  # Gradient color for impact
  scale_y_continuous(labels = scales::comma) +  # Convert to readable format
  labs(title="Top 10 Countries by Financial Loss", x="Country", y="Total Loss ($)")

# Analysis 2.3 =  Most Targeted Countries
targeted_countries <- myData %>%
  group_by(country_summary) %>%
  summarise(Targeted_Sites = n_distinct(URL)) %>%
  arrange(desc(Targeted_Sites))

ggplot(targeted_countries[1:10,], aes(x = reorder(country_summary, -Targeted_Sites), y = Targeted_Sites)) +
  geom_bar(stat="identity", fill="green") +
  coord_flip() +
  theme_minimal() +
  labs(title="Top 10 Most Targeted Countries", x="Country", y="Number of Unique Sites Attacked")

# Analysis 2.4 =   Average Financial Loss Per Attack by Country

myData$Industry <- ifelse(grepl(".gov", myData$URL), "Government",
                          ifelse(grepl(".edu", myData$URL), "Education",
                                 ifelse(grepl(".org", myData$URL), "Non-Profit",
                                        ifelse(grepl(".com", myData$URL), "Commercial",
                                               "Other"))))


industry_country_count <- aggregate(myData$Industry, by=list(myData$country_summary, myData$Industry), FUN=length)
colnames(industry_country_count) <- c("Country", "Industry", "Count")

industry_country_count <- industry_country_count[order(-industry_country_count$Count), ]

head(industry_country_count, 10)

#Extra Feature for 2.2 Analysis (TP070581)
#To view the Country in world map specifically

library(ggplot2)
library(dplyr)
library(maps)
library(ggthemes)

# Ensure country_summary is in myData
myData <- myData %>%
  mutate(country_summary = as.character(Country))  # Standardize country names

# Summarize financial loss by country
country_loss <- myData %>%
  group_by(country_summary) %>%
  summarise(Total_Loss = sum(Loss, na.rm=TRUE)) %>%
  arrange(desc(Total_Loss))

# Load world map data
world_map <- map_data("world")

# Merge financial loss data with world map data
map_data_loss <- world_map %>%
  left_join(country_loss, by = c("region" = "country_summary"))

# Get country centroids for labeling
country_labels <- map_data_loss %>%
  group_by(region) %>%
  summarise(long = mean(long, na.rm=TRUE), lat = mean(lat, na.rm=TRUE), Total_Loss = max(Total_Loss, na.rm=TRUE))

# Plot the world map with financial loss and country labels
ggplot(map_data_loss, aes(map_id = region, fill = Total_Loss)) +
  geom_map(map = world_map, color = "black", size = 0.2) +  # Draw country borders
  expand_limits(x = world_map$long, y = world_map$lat) +
  scale_fill_gradient(low = "lightblue", high = "darkred", na.value = "grey") +  # Color intensity based on loss
  theme_void() +  # Remove background
  labs(title="Global Financial Loss Due to Web Hacking", fill="Total Loss ($)") +
  
  # Add country labels
  geom_text(data = country_labels, aes(x = long, y = lat, label = region), size = 3, color = "black", check_overlap = TRUE)


# 3 Objective = Hacker Group Activities
# Analysis 3.1 = Top 10 Most Active Hacker Groups
hacker_groups <- myData %>%
  group_by(Notify) %>%
  summarise(Count = n()) %>%
  arrange(desc(Count))

ggplot(hacker_groups[1:10,], aes(x = reorder(Notify, -Count), y = Count)) +
  geom_bar(stat="identity", fill="blue") +
  coord_flip() +
  theme_minimal() +
  labs(title="Top 10 Most Active Hacker Groups", x="Hacker Group", y="Number of Attacks")

# Analysis 3.2 = Financial Impact by Hacker Groups

options(scipen = 999)

group_loss <- myData %>%
  group_by(Notify) %>%
  summarise(Total_Loss = sum(Loss, na.rm=TRUE)) %>%
  arrange(desc(Total_Loss))

ggplot(group_loss[1:10,], aes(x = reorder(Notify, -Total_Loss), y = Total_Loss)) +
  geom_bar(stat="identity", fill="red") +
  coord_flip() +
  theme_minimal() +
  scale_y_continuous(labels = function(x) format(x, big.mark = "", scientific = FALSE)) +  # Removes commas
  labs(title="Top 10 Hacker Groups by Financial Loss", 
       x="Hacker Group", 
       y="Total Loss ($)")

# Analysis 3.3 = Most Common Web Server Targeted by Hackers
library(ggplot2)
library(dplyr)
server_count <- myData %>%
  group_by(WebServer) %>%
  summarise(Attack_Count = n()) %>%
  arrange(desc(Attack_Count))
ggplot(server_count[1:10,], aes(x = reorder(WebServer, -Attack_Count), y = Attack_Count)) +
  geom_bar(stat="identity", fill="purple") +
  coord_flip() +
  theme_minimal() +
  labs(title="Top 10 Most Targeted Web Servers by Hackers", 
       x="Web Server", 
       y="Number of Attacks")

# Analysis 3.4 =  Most Active Hacker Groups Over Time

hacker_trend <- myData %>%
  group_by(Year, Notify) %>%
  summarise(Attack_Count = n(), .groups="drop") %>%
  arrange(Year, desc(Attack_Count))

top_hackers <- myData %>%
  group_by(Notify) %>%
  summarise(Total_Attacks = n(), .groups="drop") %>%
  arrange(desc(Total_Attacks)) %>%
  head(5) %>%
  pull(Notify)


filtered_data <- hacker_trend %>% filter(Notify %in% top_hackers)


ggplot(filtered_data, aes(x = Year, y = Attack_Count, color = Notify, group = Notify)) +
  geom_line(size=1) +
  geom_point(size=2) +
  theme_minimal() +
  labs(title="Hacker Group Activities Over Time", 
       x="Year", 
       y="Number of Attacks",
       color="Hacker Group") +
  theme(legend.position="bottom")



#Extra feature for Analysis 3.3
library(ggplot2)
library(dplyr)

# Summarize attack count per Web Server
server_count <- myData %>%
  group_by(WebServer) %>%
  summarise(Attack_Count = n()) %>%
  arrange(desc(Attack_Count)) 

# Calculate percentages
total_attacks <- sum(server_count$Attack_Count)
server_count <- server_count %>%
  mutate(Percentage = (Attack_Count / total_attacks) * 100)

# Get the top 3 web servers attacked
top_webservers <- paste(server_count$WebServer[1:3], collapse = ", ")

# Plot with extra features
ggplot(server_count[1:10,], aes(x = reorder(WebServer, -Attack_Count), y = Attack_Count, fill = Attack_Count)) +
  geom_bar(stat="identity", width=0.6, show.legend = FALSE) +  # Adjust bar width
  geom_text(aes(label = paste0(Attack_Count, " (", round(Percentage, 1), "%)")), 
            hjust = -0.2, size = 5, color = "black", fontface="bold") +  # Show count & percentage
  coord_flip() +
  theme_minimal() +
  scale_fill_gradient(low = "lightblue", high = "darkblue") +  # Gradient color for impact
  labs(title = paste("💻 Top 10 Most Targeted Web Servers by Hackers | Most Attacked:", top_webservers),
       x = "Web Server", 
       y = "Number of Attacks") +
  theme(
    plot.title = element_text(hjust = 0.5, face="bold", size=14),  # Center & bold title
    axis.text.y = element_text(size=12, face="bold"),  # Bold Web Server names
    axis.text.x = element_text(size=10),  # Improve readability of attack numbers
    panel.grid.major = element_line(color="grey80", linetype="dashed"),  # Soft grid lines
    panel.grid.minor = element_blank()  # Remove minor grid lines
  ) +
  geom_hline(yintercept=mean(server_count$Attack_Count), linetype="dashed", color="red") +  # Add average attack line
  annotate("text", x=2, y=mean(server_count$Attack_Count) + 50, 
           label="Avg Attack Level", color="red", fontface="italic", size=4)  # Label for avg attack line






















