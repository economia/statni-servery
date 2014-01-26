require(XML)

urls  <- read.csv("urls.csv", header=F)

for (i in urls$V1) {
  xml  <- xmlParse(paste(i, "/rss", sep=""), encoding="cp1250")
  print(i)
  browser()
}



