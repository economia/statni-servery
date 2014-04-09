new Tooltip!watchElements!
container = d3.select ig.containers.base
firstDate = new Date "2013-06-10 12:00"
lastDate = new Date "2014-04-08 12:00"
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

svg = d3.select document.createElement \svg
currentDate = new Date firstDate.getTime!
weekCounter = -1
lastMonth = null
monthChanges = []
while currentDate <= lastDate
    weekDay = (currentDate.getDay! - 1) %% 7
    weekCounter++ if weekDay == 0
    if currentDate.getMonth! != lastMonth
        if lastMonth != null
            monthChanges.push [(x weekCounter), (y weekDay), currentDate.getMonth!]
        lastMonth = currentDate.getMonth!
    rect = svg.append "rect"
        ..attr \fill \#f9f9f9
        ..attr \stroke if weekDay > 4 then \#bbb else \#ddd
        ..attr \x x weekCounter
        ..attr \y y weekDay
        ..attr \height fieldSize
        ..attr \width fieldSize
        ..attr \data-date "#{currentDate.toISOString!substr 0, 10}"

    currentDate.setTime currentDate.getTime! + 86400 * 1e3
svg.selectAll \path .data monthChanges .enter!append \path
    ..attr \d ([x, y]) -> "M#x #{maxHeight+fieldSize} V #y H #{x + fieldSize} V 0"
svg.append \path .attr \d "M 0 1 H #maxWidth"
svg.append \path .attr \d "M 0 #{maxHeight+fieldSize} H #{maxWidth - fieldSize}"
svgContent = svg.html!
list = container.append \ul
# ig.data.vypadky.length = 2
for vypadek in ig.data.vypadky
    vypadek.firstDate = new Date vypadek.firstDate
color = d3.scale.linear!
    ..domain [0 1 5 10 50 100 999 ]
    ..range <[#ffffff  #ffffb2 #fecc5c #fd8d3c #f03b20 #bd0026 #bd0026]>
list.selectAll \li .data ig.data.vypadky .enter!.append \li
    ..append \h2 .html -> "#{it.name} &ndash; #{it.dostupnost}%"
    ..append \svg .html svgContent
    ..each (d) ->
        for rect in @querySelectorAll "rect"
            date = rect.getAttribute \data-date
            vypadky = d.vypadky[date] || 0
            if vypadky
                rect.setAttribute \fill color d.vypadky[date]
            dateObj = new Date date
            if dateObj < d.firstDate
                rect.setAttribute \class \prior
            tooltip = "#{dateObj.getDate!}. #{dateObj.getMonth! + 1}. #{dateObj.getFullYear!}: "
            tooltip += switch
            | dateObj < d.firstDate => "neměřeno"
            | vypadky == 0 => "žádný výpadek"
            | vypadky == 1 => "1 výpadek (cca 5 minut nedostupnost)"
            | vypadky < 5 => "#vypadky výpadky (cca #{vypadky * 5} minut nedostupnost)"
            | vypadky <= 24 => "#vypadky výpadků (cca #{vypadky * 5} minut nedostupnost)"
            | vypadky < 54 => "#vypadky výpadků (cca #{Math.round vypadky / 12} hodiny nedostupnost)"
            | otherwise => "#vypadky výpadků (cca #{Math.round vypadky / 12} hodin nedostupnost)"
            rect.setAttribute \data-tooltip tooltip

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
