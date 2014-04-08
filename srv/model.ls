require! {fs, async, request, xml2js}
(err, data) <~ fs.readFile "#__dirname/../urls.csv"
lines = data.toString!split "\r"
ids = for line in lines => line.split "/" .pop! |> parseInt _, 10
servers = ids.map (id) -> {id}
# servers.length = 1
re = new RegExp "<td>(.*?)</td>"
<~ async.each servers, (server, cb) ->
    (err, file) <~ fs.readFile "#__dirname/../data/scrape_names/#{server.id}"
    file .= toString!
    name = file.match re .1
    server.name = name
    server.vypadky = {}
    (err, xml) <~ fs.readFile "#__dirname/../data/scrape_xml/#{server.id}"
    (err, d) <~ xml2js.parseString xml
    for den in d.statistiky.den
        datum = den.$.isodate
        vypadky = den.vypadku.0 |> parseInt _, 10
        if vypadky > 0
            server.vypadky[datum] = vypadky
    console.log server
    cb!

<~ fs.writeFile "#__dirname/../data/servers.json", JSON.stringify servers
