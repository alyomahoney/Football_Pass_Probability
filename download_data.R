#########################################
# download 2018 prem events data set
#########################################
if (!"./data" %in% list.dirs())
  dir.create("data")

if (!"events_England.json" %in% list.files("data")) {
  download.file(url = "https://ndownloader.figshare.com/files/14464685",
                destfile = "data/events.zip")
  unzip(zipfile = "data/events.zip",
        files = "events_England.json",
        exdir = "data")
  file.remove("data/events.zip")
}

#########################################
# download teams data set
#########################################
if (!"teams.json" %in% list.files("data"))
  download.file(url = "https://ndownloader.figshare.com/files/15073697",
                destfile = "data/teams.json")

#########################################
# download tag identifier data set
#########################################
if (!"tags2name.csv" %in% list.files("data"))
  download.file(url = "https://ndownloader.figshare.com/files/21385239",
                destfile = "data/tags2name.csv")