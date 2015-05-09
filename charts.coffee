transformData = (data) ->
  data.forEach((d) ->
    d.Height = +d.Height
    d.DBH = +d.DBH
    d['Crown Cover'] = +d['Crown Cover']
  )

d3.csv('/data.csv', (data) ->
  transformData(data)
  console.log(data)

  window.facts = crossfilter(data)
  window.all = facts.groupAll()

  window.charts = {}

  charts['health'] = dc.pieChart('#health')
  healthDimension = facts.dimension((d) -> d.Health)
  healthGroup = healthDimension.group()

  charts['health']
  .height(360)
  .radius(140)
  .dimension(healthDimension)
  .group(healthGroup)
  .minAngleForLabel(0)


  dc.dataCount(".dc-data-count")
  .dimension(facts)
  .group(all)

  dc.renderAll()
)
