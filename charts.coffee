transformData = (data) ->
  data.forEach((d) ->
    d.Height = +d.Height
    d.DBH = +d.DBH
    d['Crown Cover'] = +d['Crown Cover']
  )

d3.csv('/data.csv', (data) ->
  transformData(data)
  console.log(data)
)
