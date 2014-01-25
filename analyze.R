require(XML)


urls  <- read.csv("urls.csv", header=F)

for (i in urls) {
  html  <- htmlParse(i)
}