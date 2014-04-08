require! {fs, async, request, iconv.Iconv}
iconv = new Iconv "cp1250" "utf-8"
(err, data) <~ fs.readFile "#__dirname/../urls.csv"
lines = data.toString!split "\r"
ids = for line in lines
    line.split "/" .pop! |> parseInt _, 10
# ids.length = 1
<~ async.eachLimit ids, 5, (id, cb) ->
    (err, res, body) <~ request.get do
        uri: "http://data.monitoring-serveru.cz/#id/vystup.xml"
        encoding: null
    body = iconv.convert body
    <~ fs.writeFile "#__dirname/../data/scrape_xml/#id", body
    cb!
