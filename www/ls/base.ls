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
weekCounter = 0
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
