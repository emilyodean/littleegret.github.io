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


  charts['dbh-vs-crown-cover'] = dc.scatterPlot('#dbh-vs-crown-cover')

  dbhVsCrownDimension = facts.dimension((d) -> [d.DBH, d['Crown Cover']])

  charts['dbh-vs-crown-cover']
  .width(300)
  .height(300)
  .x(d3.scale.linear().domain([0, 100]))
  .yAxisLabel("DBH")
  .xAxisLabel("Crown Cover")
  .symbolSize(8)
  .clipPadding(10)
  .dimension(dbhVsCrownDimension)
  .group(dbhVsCrownDimension.group())


  dc.dataCount(".dc-data-count")
  .dimension(facts)
  .group(all)

  dc.renderAll()
)
