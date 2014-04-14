new Tooltip!watchElements!
container = d3.select ig.containers.base
firstDate = new Date
    ..setTime 1370865600000 # "2013-06-10 12:00"
lastDate = new Date
    ..setTime 1396958400000 # "2014-04-08 12:00"
weekCount = 44
fieldSize = 660 / weekCount
maxWidth = fieldSize * weekCount
maxHeight = fieldSize * 6
x = d3.scale.linear!
    ..domain [0 weekCount]
    ..range [0 maxWidth]
y = d3.scale.linear!
    ..domain [0 6]
    ..range [0 maxHeight]
svg = container.append \svg
    ..attr \width 704
    ..attr \height 105
    ..attr \id \svgParent
monthChanges = []
weekCounter = -1
currentDate = new Date firstDate.getTime!
while currentDate <= lastDate
    weekDay = (currentDate.getDay! - 1) %% 7
    weekCounter++ if weekDay == 0
    if currentDate.getMonth! != lastMonth
        if lastMonth != null
            monthChanges.push [(x weekCounter), (y weekDay), currentDate.getMonth!]
        lastMonth = currentDate.getMonth!
    currentDate.setTime currentDate.getTime! + 86400 * 1e3
svg.selectAll \path .data monthChanges .enter!append \path
    ..attr \d ([x, y]) -> "M#x #{maxHeight+fieldSize} V #y H #{x + fieldSize} V 0"
svg.append \path .attr \d "M 0 1 H #maxWidth"
svg.append \path .attr \d "M 0 #{maxHeight+fieldSize} H #{maxWidth - fieldSize}"

list = container.append \ul
# ig.data.vypadky.length = 2
for vypadek in ig.data.vypadky
    vypadek.firstDate = new Date vypadek.firstDate
color = d3.scale.linear!
    ..domain [0 1 5 10 50 100 999 ]
    ..range <[#ffffff  #ffffb2 #fecc5c #fd8d3c #f03b20 #bd0026 #bd0026]>
list.selectAll \li .data ig.data.vypadky .enter!.append \li
    ..append \h2 .append \a
        ..attr \href -> "http://statistiky.monitoring-serveru.cz/#{it.id}"
        ..attr \target \_blank
        ..html -> "#{it.name} &ndash; #{it.dostupnost}%"
    ..append \svg
        ..attr \width 704
        ..attr \height 105
        ..each (d) ->
            svg = d3.select @
            currentDate = new Date firstDate.getTime!
            weekCounter = -1
            while currentDate <= lastDate
                weekDay = (currentDate.getDay! - 1) %% 7
                weekCounter++ if weekDay == 0
                dateStr = currentDate.toISOString!substr 0, 10
                vypadky = d.vypadky[dateStr] || 0

                tooltip = "#{currentDate.getDate!}. #{currentDate.getMonth! + 1}. #{currentDate.getFullYear!}: "
                tooltip += switch
                | currentDate < d.firstDate => "neměřeno"
                | vypadky == 1 => "1 výpadek (cca 5 minut nedostupnost)"
                | vypadky < 5 => "#vypadky výpadky (cca #{vypadky * 5} minut nedostupnost)"
                | vypadky <= 24 => "#vypadky výpadků (cca #{vypadky * 5} minut nedostupnost)"
                | vypadky < 54 => "#vypadky výpadků (cca #{Math.round vypadky / 12} hodiny nedostupnost)"
                | otherwise => "#vypadky výpadků (cca #{Math.round vypadky / 12} hodin nedostupnost)"
                fill =
                    | currentDate < d.firstDate => \#f3f3f3
                    | vypadky == 0 => \#f9f9f9
                    | otherwise => color vypadky
                stroke =
                    | currentDate < d.firstDate => \#f3f3f3
                    | weekDay > 4 => \#bbb
                    | otherwise => \#ddd
                rect = svg.append "rect"
                    ..attr \fill fill
                    ..attr \stroke stroke
                    ..attr \x x weekCounter
                    ..attr \y y weekDay
                    ..attr \height fieldSize
                    ..attr \width fieldSize
                    ..attr \data-tooltip tooltip
                currentDate.setTime currentDate.getTime! + 86400 * 1e3

        ..append \use .attr \xlink:href \#svgParent


list.select "li:first-child" .selectAll \span.day
    .data <[Po Út St Čt Pá So Ne]>
    .enter!append \span
        ..attr \class \day
        ..html -> it
        ..style \top (d, i) -> "#{y i}px"

months = <[leden únor březen duben květen červen červenec srpen září říjen listopad prosinec]>
monthLengths = [5 4 5 4 4 5 4 4 5 0]
monthMargins = [0 1 1 1 1 1 1 1 1 1]
list.select "li:first-child" .selectAll \span.month .data monthChanges .enter!append \span
    ..attr \class \month
    ..html ([x, y, index]) -> months[index]
    ..style \left ([x, y], i) -> "#{x + monthMargins[i] * fieldSize}px"
    ..style \width (d, i) -> "#{monthLengths[i] * fieldSize}px"
