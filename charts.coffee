transformData = (data) ->
  data.forEach((d) ->
    d.Height = +d.Height
    d.DBH = +d.DBH
    d.Site = +d.Site
    d.Beetle = +d.Beetle
    d['Crown Cover'] = +d['Crown Cover']
    d.Year = +d.Year
  )

d3.csv('/PineDataCorrectHypothesis.csv', (data) ->
  transformData(data)
  console.log(data)

  window.facts = crossfilter(data)
  window.all = facts.groupAll()

  window.charts = {}

# Health (HUSD) pie chart
  charts['health'] = dc.pieChart('#health')
  healthDimension = facts.dimension((d) -> d.Health)
  healthGroup = healthDimension.group()

  charts['health']
  .height(360)
  .width(333)
  .radius(140)
  .dimension(healthDimension)
  .group(healthGroup)
  .minAngleForLabel(0)
  #.label((d) ->
  #  if (d.Health == 'H')
  #    'Healthy'
  #  else if (d.Health == 'U')
  #    'Unhealthy'
  #  else if (d.Health == 'S')
  #    'Sick'
  #  else if (d.Health == 'D')
  #    'Dead'
  #)
  .colors(d3.scale.category10())

  # Site number pie chart
  charts['site'] = dc.pieChart('#site')
  siteDimension = facts.dimension((d) -> d.Site)
  siteGroup = siteDimension.group()

  charts['site']
  .height(360)
  .width(333)
  .radius(140)
  .dimension(siteDimension)
  .label((d) ->
    if (d.Site == 1)
      'Site 1'
    else 
      'Site 2'
  )
  .group(siteGroup)
  .minAngleForLabel(0)
  .colors(d3.scale.category10())

  # Year pie chart
  charts['year'] = dc.pieChart('#year')
  yearDimension = facts.dimension((d) -> d.Year)
  yearGroup = yearDimension.group()

  charts['year']
  .height(360)
  .width(333)
  .radius(140)
  .dimension(yearDimension)
  .group(yearGroup)
  .minAngleForLabel(0)
  .colors(d3.scale.category10())

  # Species
  charts['species'] = dc.pieChart('#species')
  yearDimension = facts.dimension((d) -> d.Species)
  yearGroup = yearDimension.group()

  charts['species']
  .height(360)
  .width(333)
  .radius(140)
  .dimension(yearDimension)
  .group(yearGroup)
  .minAngleForLabel(0)
  .colors(d3.scale.category20())


  # Beetle Damage Chart
  charts['beetle'] = dc.barChart('#beetle')
  beetleDimension = facts.dimension((d) -> d.Beetle)
  beetleGroup = beetleDimension.group()

  charts['beetle']
  .height(360)
  .width(333)
  .dimension(beetleDimension)
  .group(beetleGroup)
  .x(d3.scale.linear().domain([0, 4]))
  .elasticY(true)
  .xAxisLabel("Severity of Beetle Damage")
  .yAxisLabel("Number of Trees")
  .colors(d3.scale.category10())


  # DBH vs Crown Cover Chart 
  charts['dbh-vs-crown-cover'] = dc.scatterPlot('#dbh-vs-crown-cover')

  dbhVsCrownDimension = facts.dimension((d) -> [d.DBH, d['Crown Cover']])

  charts['dbh-vs-crown-cover']
  .width(1000)
  .height(300)
  .x(d3.scale.linear().domain([0, 100]))
  .yAxisLabel("Crown Cover")
  .xAxisLabel("DBH")
  .symbolSize(8)
  .clipPadding(10)
  .dimension(dbhVsCrownDimension)
  .group(dbhVsCrownDimension.group())
  .colors(d3.scale.category10())

  
  #Year vs DBH vs Health
  charts['scatter'] = dc.scatterPlot('#scatter')

  dimension = facts.dimension((d) -> [d.Year, d.DBH, d.Health, d.Species])

  symbolScale = d3.scale.ordinal().range(d3.svg.symbolTypes)

  charts['scatter']
  .width(900)
  .height(600)
  .symbolSize(14)
  .symbol((d) -> symbolScale(d.key[3]))
  .x(d3.scale.linear())
  .x(d3.time.scale().domain([new Date(2015, 0, 1), new Date(2021, 11, 31)]))
  .y(d3.scale.linear())
  .xAxisLabel("Year")
  .yAxisLabel("DBH")
  .elasticX(true)
  .elasticY(true)
  .clipPadding(10)
  .colors(d3.scale.ordinal().domain(['H', 'U', 'S', 'D'])
  .range(['green', 'yellow', 'orange', 'red']))
  .colorAccessor((d) -> d.key[2])
  .dimension(dimension)
  .group(dimension.group())
  .xAxis().tickFormat(d3.format("d"))
  
  # General Data

  charts['pinedata'] = dc.dataTable('#pinedata')
  pineDataDimension = facts.dimension((d) -> d['Tree Number'])
  
  charts['pinedata']
  .width(1000)
  .height(300)
  .dimension(pineDataDimension)
  .group((d) -> '')
  .order(d3.ascending)
  .sortBy((d) -> d['Tree Number'])
  .size(100)
  .columns([
    ((d) -> d.Species),
    ((d) -> d.Height),
    ((d) -> d.DBH),
    ((d) -> d['Male Cones']),
    ((d) -> d['Female Cones'])
    ((d) -> d['Pitch Tubes'])
    ((d) -> d.Frass)
    ((d) -> d['Sap Drips'])
    ((d) -> d.Holes)
  ])


  dc.dataCount(".dc-data-count")
  .dimension(facts)
  .group(all)

  dc.renderAll()
)
