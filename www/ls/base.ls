new Tooltip!watchElements!
container = d3.select ig.containers.base
firstDate = new Date "2013-06-10 12:00"
lastDate = new Date "2014-04-08 12:00"
weekCount = 44
fieldSize = 924 / weekCount
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
while currentDate <= lastDate
    weekDay = (currentDate.getDay! - 1) %% 7
    weekCounter++ if weekDay == 0
    rect = svg.append "rect"
        ..attr \fill \#f9f9f9
        ..attr \stroke if weekDay > 4 then \#a2cdec else \#ddd
        ..attr \x x weekCounter
        ..attr \y y weekDay
        ..attr \height fieldSize
        ..attr \width fieldSize
        ..attr \data-date "#{currentDate.toISOString!substr 0, 10}"

    currentDate.setTime currentDate.getTime! + 86400 * 1e3
svgContent = svg.html!
list = container.append \ul
ig.data.vypadky.length = 1
color = d3.scale.linear!
    ..domain [0 1 5 10 50 100 999 ]
    ..range <[#ffffff  #ffffb2 #fecc5c #fd8d3c #f03b20 #bd0026 #bd0026]>
list.selectAll \li .data ig.data.vypadky .enter!.append \li
    ..append \h2 .html (.name)
    ..append \svg .html svgContent
    ..each (d) ->
        for rect in @querySelectorAll "rect"
            date = rect.getAttribute \data-date
            vypadky = d.vypadky[date] || 0
            if vypadky
                rect.setAttribute \fill color d.vypadky[date]
            dateObj = new Date date
            tooltip = "#{dateObj.getDate!}. #{dateObj.getMonth! + 1}. #{dateObj.getFullYear!}: #vypadky "
            tooltip += switch
            | vypadky == 1 => "výpadek"
            | 0 < vypadky < 5 => "výpadky"
            | otherwise => "výpadků"
            rect.setAttribute \data-tooltip tooltip

