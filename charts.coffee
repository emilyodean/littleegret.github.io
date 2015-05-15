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
  .width(270)
  .radius(130)
  .dimension(healthDimension)
  .group(healthGroup)
  .minAngleForLabel(0)
  .colors(d3.scale.ordinal().domain(['H', 'U', 'S', 'D'])
  .range(['green', '#FFD700', 'orange', 'red']))

  # Site number pie chart
  charts['site'] = dc.pieChart('#site')
  siteDimension = facts.dimension((d) -> d.Site)
  siteGroup = siteDimension.group()

  charts['site']
  .height(360)
  .width(270)
  .radius(130)
  .dimension(siteDimension)
  .group(siteGroup)
  .minAngleForLabel(0)
  .colors(d3.scale.category10())

  # Year pie chart
  charts['year'] = dc.pieChart('#year')
  yearDimension = facts.dimension((d) -> d.Year)
  yearGroup = yearDimension.group()

  charts['year']
  .height(360)
  .width(270)
  .radius(130)
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
  .width(270)
  .radius(130)
  .dimension(yearDimension)
  .group(yearGroup)
  .minAngleForLabel(0)
  .colors(d3.scale.category20())


  # Beetle Damage Chart
  #charts['beetle'] = dc.barChart('#beetle')
  #beetleDimension = facts.dimension((d) -> d.Beetle)
  #beetleGroup = beetleDimension.group()

  #charts['beetle']
  #.height(360)
  #.width(333)
  #.dimension(beetleDimension)
  #.group(beetleGroup)
  #.x(d3.scale.linear().domain([0, 4]))
  #.elasticY(true)
  #.xAxisLabel("Severity of Beetle Damage")
  #.yAxisLabel("Number of Trees")
  #.colors(d3.scale.category10())


  # DBH vs Crown Cover Chart 
  #charts['dbh-vs-crown-cover'] = dc.scatterPlot('#dbh-vs-crown-cover')

  #dbhVsCrownDimension = facts.dimension((d) -> [d.DBH, d['Crown Cover' ]])

  #charts['dbh-vs-crown-cover']
  #.width(1000)
  #.height(300)
  #.x(d3.scale.linear().domain([0, 100]))
  #.yAxisLabel("Crown Cover")
  #.xAxisLabel("DBH")
  #.symbolSize(8)
  #.clipPadding(10)
  #.dimension(dbhVsCrownDimension)
  #.group(dbhVsCrownDimension.group())
  #.colors(d3.scale.category10())

  
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
  .range(['green', '#FFD700', 'orange', 'red']))
  .colorAccessor((d) -> d.key[2])
  .dimension(dimension)
  .group(dimension.group())
  .xAxis().tickFormat(d3.format("d"))

  # Health Histogram
  charts['histogram'] = dc.barChart('#histogram')
  yearHistogramDimension = facts.dimension((d) -> [d.Year])

  hGroup = yearHistogramDimension.group().reduceSum((d) -> if d.Health == 'H' then 1 else 0)
  uGroup = yearHistogramDimension.group().reduceSum((d) -> if d.Health == 'U' then 1 else 0)
  sGroup = yearHistogramDimension.group().reduceSum((d) -> if d.Health == 'S' then 1 else 0)
  dGroup = yearHistogramDimension.group().reduceSum((d) -> if d.Health == 'D' then 1 else 0)

  charts['histogram']
  .height(400)
  .width(350)
  .dimension(yearHistogramDimension)
  #.group(yearHistogramDimension.group())
  .group(hGroup, "Heatlhy")
  .stack(uGroup, "Unhealthy")
  .stack(sGroup, "Sick")
  .stack(dGroup, "Dead")
  .ordinalColors(['green', '#FFD700', 'orange', 'red'])
  #.x(d3.time.scale().domain([new Date(2015, 0, 1), new Date(2021, 11, 31)]))
  .elasticY(true)
  .xAxisLabel("Year")
  .x(d3.scale.linear().domain([2015,2019]))
  .yAxisLabel("Trees by health categories")


  # Live Trees Histogram
  charts['livehistogram'] = dc.barChart('#livehistogram')
  liveHistogramDimension = facts.dimension((d) -> [d.Year])

  sabiGroup = liveHistogramDimension.group().reduceSum((d) -> if (d.Health == 'H' || d.Health == 'U') && d.Species == 'SABI' then 1 else 0)
  coulGroup = liveHistogramDimension.group().reduceSum((d) -> if (d.Health == 'H' || d.Health == 'U') && d.Species == 'COUL' then 1 else 0)
  atteGroup = liveHistogramDimension.group().reduceSum((d) -> if (d.Health == 'H' || d.Health == 'U') && d.Species == 'ATTE' then 1 else 0)

  charts['livehistogram']
  .height(400)
  .width(350)
  .dimension(liveHistogramDimension)
  .group(sabiGroup, "Sabiniana")
  .stack(coulGroup, "Coulter")
  .stack(atteGroup, "Attenuata")
  .ordinalColors(['#006400', '#32CD32', '#3CB371'])
  #.x(d3.time.scale().domain([new Date(2015, 0, 1), new Date(2021, 11, 31)]))
  .elasticY(true)
  .xAxisLabel("Year")
  .x(d3.scale.linear().domain([2015,2019]))
  .yAxisLabel("Number of Healthy Trees")
  .legend(dc.legend().x(200).y(10).itemHeight(13).gap(5))
  
  # Beetle Damage by Tree Species Histogram
  charts['beetlehistogram'] = dc.barChart('#beetlehistogram')
  beetleHistogramDimension = facts.dimension((d) -> d.Species)

  aGroup = beetleHistogramDimension.group().reduceSum((d) -> if (d.Frass == 'Y' && d['Pitch Tubes'] == 'Y' && d['Sap Drips'] == 'Y' && d.Holes == 'Y') then 1 else 0)
  bGroup = beetleHistogramDimension.group().reduceSum((d) -> if (d.Frass == 'N' && d['Pitch Tubes'] == 'Y' && d['Sap Drips'] == 'Y' && d.Holes == 'Y') || (d.Frass == 'Y' && d['Pitch Tubes'] == 'Y' && d['Sap Drips'] == 'Y' && d.Holes == 'N')|| (d.Frass == 'Y' && d['Pitch Tubes'] == 'N' && d['Sap Drips'] == 'Y' && d.Holes == 'Y')|| (d.Frass == 'Y' && d['Pitch Tubes'] == 'Y' && d['Sap Drips'] == 'N' && d.Holes == 'Y') then 1 else 0)
  cGroup = beetleHistogramDimension.group().reduceSum((d) -> if (d.Frass == 'N' && d['Pitch Tubes'] == 'N' && d['Sap Drips'] == 'Y' && d.Holes == 'Y') || (d.Frass == 'N' && d['Pitch Tubes'] == 'Y' && d['Sap Drips'] == 'N' && d.Holes == 'Y')|| (d.Frass == 'N' && d['Pitch Tubes'] == 'Y' && d['Sap Drips'] == 'Y' && d.Holes == 'N')|| (d.Frass == 'Y' && d['Pitch Tubes'] == 'N' && d['Sap Drips'] == 'N' && d.Holes == 'Y')|| (d.Frass == 'Y' && d['Pitch Tubes'] == 'N' && d['Sap Drips'] == 'Y' && d.Holes == 'N')|| (d.Frass == 'Y' && d['Pitch Tubes'] == 'Y' && d['Sap Drips'] == 'N' && d.Holes == 'N') then 1 else 0) 
  dGroup = beetleHistogramDimension.group().reduceSum((d) -> if (d.Frass == 'Y' && d['Pitch Tubes'] == 'N' && d['Sap Drips'] == 'N' && d.Holes == 'N' )|| (d.Frass == 'N' && d['Pitch Tubes'] == 'Y' && d['Sap Drips'] == 'N' && d.Holes == 'N')|| (d.Frass == 'N' && d['Pitch Tubes'] == 'N' && d['Sap Drips'] == 'Y' && d.Holes == 'N')|| (d.Frass == 'N' && d['Pitch Tubes'] == 'N' && d['Sap Drips'] == 'N' && d.Holes == 'Y') then 1 else 0)
  eGroup = beetleHistogramDimension.group().reduceSum((d) -> if (d.Frass == 'N' && d['Pitch Tubes'] == 'N' && d['Sap Drips'] == 'N' && d.Holes == 'N') then 1 else 0)
  
  
  charts['beetlehistogram']
  .height(400)
  .width(350)
  .dimension(beetleHistogramDimension)
  .group(beetleHistogramDimension.group())
  .group(aGroup, "Significant Beetle Damage")
  .stack(bGroup, "Lots of Beetle Damage")
  .stack(cGroup, "Some Beetle Damage")
  .stack(dGroup, "Negligable Damage")
  .stack(eGroup, "No Beetle Damage")
  .ordinalColors(['red', '#FF6347', '#FFA500', '#FFD700', 'green'])
  #.x(d3.time.scale().domain([new Date(2015, 0, 1), new Date(2021, 11, 31)]))
  .elasticY(true)
  .xAxisLabel("Species")
  .x(d3.scale.ordinal().domain(['COUL', 'SABI', 'ATTE']))
  .xUnits(dc.units.ordinal)
  .yAxisLabel("Trees with Beetle Damage")
  .legend(dc.legend().x(200).y(10).itemHeight(13).gap(5))


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
