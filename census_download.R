#######
wd <- "C:/Users/gdsut/Documents/Data/Census"
setwd(wd)


table_list <- read.csv("census_table_download.csv")
str(table_list)

# example download link
# "http://www.nomisweb.co.uk/output/census/2011/ks101ew_2011_oa.zip"


tables_to_download <- table_list$Table.number[table_list$Download == 'Yes']
tables_to_download <- tolower(tables_to_download)


# download files using table names from csv
for (i in tables_to_download) {
  file_url <- paste("http://www.nomisweb.co.uk/output/census/2011/",i,"_2011_oa.zip",sep = "")
  saved_name <- paste(wd,"/",i,".zip",sep = "")
  download.file(file_url,saved_name)
}


file_info <- file.info(dir(wd,pattern = ".zip"))

# some didnt download, try those again
retry_tables <- tables_to_download %in% substr(rownames(file_info[file_info$size > 100000,]),1,7)
retry_tables <- tables_to_download[!retry_tables]


for (i in retry_tables) {
  file_url <- paste("http://www.nomisweb.co.uk/output/census/2011/",i,"_2011_oa.zip",sep = "")
  saved_name <- paste(wd,"/",i,".zip",sep = "")
  download.file(file_url,saved_name)
}

# once dowloaded unzip
for (i in tables_to_download) {
  saved_name <- paste(wd,"/",i,".zip",sep = "")
  unzip(saved_name,exdir = paste(wd,"/zip_output",sep = ""))
}

# list subfolders
folders_to_check <- list.dirs()[-1]
dir.create(paste(wd,"/data_extracts",sep = ""))

# find data csvs and combine into one folder
for (i in folders_to_check) {
  file_paths <- list.files(i, pattern = "DATA.CSV", full.names = TRUE)
  file_names <- list.files(i, pattern = "DATA.CSV")
  
  for (j in file_paths) {
    file.copy(file_paths,paste(wd,"/data_extracts/",file_names,sep = ""))
  }
}


#gather file names and read data into list
data_files <- list.files(paste(wd,"/data_extracts",sep = ""))

dat <- list()

for (i in data_files) {
  dat[[i]] <- read.csv(paste(wd,"/data_extracts/",i,sep = ""))
}

# merge list elements into single data frame
complete <- Reduce(function(x,y){merge(x,y,all=TRUE)},dat)

rm(dat)

head(complete)
