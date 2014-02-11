require(XML)
require(stringr)

# load csv
urls  <- read.csv("urls.csv", header=F)

# remove whitespace
urls  <- str_trim(urls$V1)

# initialize dataframe
serverId  <- vector("numeric")
serverName  <- vector("character")
vsechnyVypadky  <- list()

# get data
for (i in urls) {
  
  xml  <- xmlParse(paste(i, "/rss", sep=""), encoding="cp1250")
    
  casy  <- sapply(xpathSApply(xml, "//item/title"), xmlValue)
  casy  <- str_split(casy, " - ")
  casy  <- lapply(casy, function(x) c( zacatek = str_sub(x[1], str_locate(x[1], ": " )[1]+2 ), konec = str_sub(x[2], 1L, str_locate(x[2], " \\(" )[1]-1 ) ) )  
  
  if (length(casy)>0) {
  casy  <- data.frame(zacatek=matrix(unlist(casy), ncol=2, byrow=T)[,1], konec=matrix(unlist(casy), ncol=2, byrow=T)[,2])
  } else {casy  <- data.frame(zacatek=character(), konec=character(), vypadek=character())}
  
  vypadekId  <- sapply(xpathSApply(xml, "//item/link"), xmlValue)
  vypadekId  <- as.numeric(str_sub(vypadekId, str_locate(vypadekId, "vypadky/")[,2]+1))
    
  server  <- as.numeric(str_sub(i, str_locate(i, ".cz/")[1]+4))
    
  nazev  <- sapply(xpathSApply(xml, "//title"), xmlValue)[1]
  nazev  <- str_sub(nazev, 1L, str_locate(nazev, "\\ \\[Monitoring-serverů.cz\\]")-1)[1]
  

  # save data
    
  vsechnyVypadky  <- c(vsechnyVypadky, list(cbind(casy, vypadekId)))
  serverId  <- append(serverId, server)
  serverName  <- append(serverName, nazev)
  
}

result  <- data.frame(serverId=serverId, serverName=serverName)
result$vypadky  <- vsechnyVypadky

result  <- toJSON(result, pretty=TRUE)