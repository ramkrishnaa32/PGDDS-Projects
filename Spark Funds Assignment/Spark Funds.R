# Load all libraries
library(stringr)
library(tidyr)
library(dplyr)

#Load files
options(scipen = 50) # printing issue
rounds2.df <- read.csv(("rounds2.csv"),check.names=FALSE,stringsAsFactors=FALSE)                   
companies.df <- read.delim("companies.txt",sep="\t",stringsAsFactors=FALSE)
mapping.df <- read.csv(("mapping.csv"),check.names=FALSE,stringsAsFactors=FALSE)


## functions
empty_as_na <- function(x){
  if("factor" %in% class(x)) x <- as.character(x) ## Function to convert empty to NA
  ifelse(as.character(x)!="", x, NA)
}
# Clean up data - Change case to lower for merging keys
rounds2.df$company_permalink <- tolower(rounds2.df$company_permalink)                
companies.df$permalink <- tolower(companies.df$permalink)     

# Checkpoint 1 -  Table 1.1
Uni_round2_company <- unique(rounds2.df$company_permalink)
Uni_company_company <- unique(companies.df$permalink)
Diff_company <- setdiff(Uni_round2_company,Uni_company_company)

#### Merge rounds2 with data from companies. Clean up data to replace empty with NA
master_frame <- merge(rounds2.df, companies.df, by.x=c("company_permalink"), by.y=c("permalink"))
master_frame <- master_frame %>% mutate_all(funs(empty_as_na))

## Checkpoint 2 -  Fund Type Analysis - Table 2.1
#  2.1 group funding type and average amount per funding type, identify target type 
fund_type <-aggregate(master_frame$raised_amount_usd, by=list(master_frame$funding_round_type), function(x) c(mean = round(mean(x, na.rm=TRUE),0)))
names(fund_type) <- c("Type", "Invest_amt")
funding_type <-subset(fund_type, Invest_amt >5000000 & Invest_amt < 15000000)

# Extract data for some funding types as per business requirement
FT <- c("venture","angel","seed","private_equity")
fund_type_4 <- filter(fund_type, Type %in% FT)


# Checkpoint 3 - Country analysis
# 3.1 - Extract targeted funding type data from main data frame and group by country
master_frame_selected <- subset(master_frame, funding_round_type == funding_type[,1])
Fund_groups <- group_by(master_frame_selected,country_code)

# 3.2 - Top 9 countries receiving the highest funding for target funding type 
Fund_mean <- setNames(summarise(Fund_groups,sum(raised_amount_usd, na.rm = T)),c("Country","Total_Invest"))
top9 <- Fund_mean %>%
          filter(!is.na(Country)) %>%
          arrange(desc(Total_Invest)) %>%
          slice(1:9)

# 3.3 - Select english speaking countries
ENG <- c("USA","GBR","IND","CAN","PAK","NIG","ZIM","IRE")
top_eng <- filter(top9, Country %in% ENG)

## - Checkpoint 4 - Sector Analysis
# 4.1 - gathering category columns into one column is_primary
cat_list <- gather(mapping.df, key=category, value=is_primary, 2:10)

# removing rows where is_primary = 0 : remove is_primary column : cleanup
cat_list <- cat_list[-which(cat_list$is_primary == 0), ]
cat_list <- cat_list[, -3]     
cat_list <- cat_list %>% mutate_all(funs(empty_as_na))

# Cleanup - some categories list primary key had "0" instead of "na"
cat_list$category_list <- gsub("0", "na", cat_list$category_list)
cat_list$category_list <- tolower(cat_list$category_list) 

# master_frame for selected type cleanup to select data before pipe : change to lower case
master_frame_selected <- separate(master_frame_selected, category_list, c("primary_category", "secondary_category"), sep = "\\|")
master_frame_selected$primary_category <- tolower(master_frame_selected$primary_category)

# merge category list on masterframe from category list on mapping sheet
master_frame_selected <- merge(master_frame_selected,cat_list ,by.x = "primary_category", by.y = "category_list" ,all.x = TRUE)
master_frame_selected =  master_frame_selected %>% rename(primary_sector = primary_category, main_sector = category)  #rename column names
master_frame_selected <- within(master_frame_selected, rm(secondary_category))   #remove unwanted secondary category

# Create country dataframes
D1_USA <- filter(master_frame_selected, country_code == "USA", raised_amount_usd >= 5000000 & raised_amount_usd <= 15000000)
D1_GBR <- filter(master_frame_selected, country_code == "GBR", raised_amount_usd >= 5000000 & raised_amount_usd <= 15000000)
D1_IND <- filter(master_frame_selected, country_code == "IND", raised_amount_usd >= 5000000 & raised_amount_usd <= 15000000)

# Country totals
USA_TOT <- summarise(D1_USA,Total_amt = sum(raised_amount_usd, na.rm = T),Total_cnt = n())
GBR_TOT <- summarise(D1_GBR,Total_amt = sum(raised_amount_usd, na.rm = T),Total_cnt = n())
IND_TOT <- summarise(D1_IND,Total_amt = sum(raised_amount_usd, na.rm = T),Total_cnt = n())

# Sector wise grouping
D2_USA_groupby <- group_by(D1_USA,main_sector)
D2_GBR_groupby <- group_by(D1_GBR,main_sector)
D2_IND_groupby <- group_by(D1_IND,main_sector)
# For each country : count of investment & total amount of investment per sector :select top3 sectors
D2_USA <- summarise(D2_USA_groupby,Count_investment=n())
D2_USA <- D2_USA %>%
  filter(!is.na(main_sector)) %>%
  arrange(desc(Count_investment)) %>%
  slice(1:3)
D3_USA <- summarise(D2_USA_groupby,Total_Investment = sum(raised_amount_usd, na.rm = T))
D3_USA <- D3_USA %>%
  filter(!is.na(main_sector)) %>%
  arrange(desc(Total_Investment)) %>%
  slice(1:3)

#---GBR
D2_GBR <- summarise(D2_GBR_groupby,Count_investment=n())
D2_GBR <- D2_GBR %>%
  filter(!is.na(main_sector)) %>%
  arrange(desc(Count_investment)) %>%
  slice(1:3)
D3_GBR <- summarise(D2_GBR_groupby,Total_Investment = sum(raised_amount_usd, na.rm = T))
D3_GBR <- D3_GBR %>%
  filter(!is.na(main_sector)) %>%
  arrange(desc(Total_Investment)) %>%
  slice(1:3)
#---IND
D2_IND <- summarise(D2_IND_groupby,Count_investment=n())
D2_IND <- D2_IND %>%
  filter(!is.na(main_sector)) %>%
  arrange(desc(Count_investment)) %>%
  slice(1:3)
D3_IND <- summarise(D2_IND_groupby,Total_Investment = sum(raised_amount_usd, na.rm = T))
D3_IND <- D3_IND %>%
  filter(!is.na(main_sector)) %>%
  arrange(desc(Total_Investment)) %>%
  slice(1:3)

## Company filter - Group by sector and customer name
D1_groupby <- group_by(D1_USA,main_sector,name)
D2_groupby <- group_by(D1_GBR,main_sector,name)
D3_groupby <- group_by(D1_IND,main_sector,name)

# Per country : For top sector ,total investment and  count of investments : Company with highest invesment
D1_company <- summarise(D1_groupby,Total_Investment = sum(raised_amount_usd, na.rm = T),Count_investment=n())
D1_company <- D1_company %>%
  filter(main_sector == D2_USA[1,1]) %>%
  arrange(desc(Total_Investment)) %>%
  slice(1:1)
D2_company <- summarise(D2_groupby,Total_Investment = sum(raised_amount_usd, na.rm = T),Count_investment=n())
D2_company <- D2_company %>%
  filter(main_sector == D2_GBR[1,1]) %>%
  arrange(desc(Total_Investment)) %>%
  slice(1:1)
D3_company <- summarise(D3_groupby,Total_Investment = sum(raised_amount_usd, na.rm = T),Count_investment=n())
D3_company <- D3_company %>%
  filter(main_sector == D2_IND[1,1]) %>%
  arrange(desc(Total_Investment)) %>%
  slice(1:1)

# Per country : For second top sector ,total investment and  count of investments : Company with highest invesment
D1_company2 <- summarise(D1_groupby,Total_Investment = sum(raised_amount_usd, na.rm = T),Count_investment=n())
D1_company2 <- D1_company2 %>%
  filter(main_sector == D2_USA[2,1]) %>%
  arrange(desc(Total_Investment)) %>%
  slice(1:1)
D2_company2 <- summarise(D2_groupby,Total_Investment = sum(raised_amount_usd, na.rm = T),Count_investment=n())
D2_company2 <- D2_company2 %>%
  filter(main_sector == D2_GBR[2,1]) %>%
  arrange(desc(Total_Investment)) %>%
  slice(1:1)
D3_company2 <- summarise(D3_groupby,Total_Investment = sum(raised_amount_usd, na.rm = T),Count_investment=n())
D3_company2 <- D3_company2 %>%
  filter(main_sector == D2_IND[2,1]) %>%
  arrange(desc(Total_Investment)) %>%
  slice(1:1)
### end of processing ###

