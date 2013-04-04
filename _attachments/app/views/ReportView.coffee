class ReportView extends Backbone.View
  initialize: ->
    $("html").append "

      <style>
        .cases{
          display: none;
        }
      </style>
    "

  el: '#content'

  events:
    "change #reportOptions": "update"
    "change #summaryField1": "summarySelectorChanged"
    "change #summaryField2": "summarySelector2Changed"
    "change #cluster": "update"
    "click .toggleDisaggregation": "toggleDisaggregation"
    "click .same-cell-disaggregatable": "toggleDisaggregationSameCell"

  hideSublocations: ->
    hide=false
    _.each @locationTypes, (location) ->
      if hide
        $("#row-#{location}").hide()
      if $("##{location}").val() is "ALL"
        hide = true

  update: =>
    reportOptions =
      startDate: $('#start').val()
      endDate: $('#end').val()
      reportType: $('#report-type :selected').text()
      cluster: $("#cluster").val()
      summaryField1: $("#summaryField1").val()

    _.each @locationTypes, (location) ->
      reportOptions[location] = $("##{location} :selected").text()

    url = "reports/" + _.map(reportOptions, (value, key) ->
      "#{key}/#{escape(value)}"
    ).join("/")

    Coconut.router.navigate(url,true)

  render: (options) =>
    @locationTypes = "region, district, constituan, shehia".split(/, /)

    _.each (@locationTypes), (option) ->
      if options[option] is undefined
        this[option] = "ALL"
      else
        this[option] = unescape(options[option])
    @reportType = options.reportType || "dashboard"
    @startDate = options.startDate || moment(new Date).subtract('days',7).format("YYYY-MM-DD")
    @endDate = options.endDate || moment(new Date).format("YYYY-MM-DD")
    @cluster = options.cluster || "off"
    @summaryField1 = options.summaryField1
    @alertEmail = options.alertEmail || "false"

    @$el.html "
      <style>
        table.results th.header, table.results td{
          font-size:150%;
        }
        .malaria-positive{
          background-color: pink;
        }

      </style>

      <table id='reportOptions'></table>
      <div id='reportContents'></div>
      "

    $("#reportOptions").append @formFilterTemplate(
      id: "start"
      label: "Start Date"
      form: "<input id='start' class='date' type='text' value='#{@startDate}'/>"
    )

    $("#reportOptions").append @formFilterTemplate(
      id: "end"
      label: "End Date"
      form: "<input id='end' class='date' type='text' value='#{@endDate}'/>"
    )

   
    selectedLocations = {}
    _.each @locationTypes, (locationType) ->
      selectedLocations[locationType] = this[locationType]

    _.each @locationTypes, (locationType,index) =>

      $("#reportOptions").append @formFilterTemplate(
        type: "location"
        id: locationType
        label: locationType.capitalize()
        form: "
          <select data-role='selector' id='#{locationType}'>
            #{
              locationSelectedOneLevelHigher = selectedLocations[@locationTypes[index-1]]
              _.map( ["ALL"].concat(@hierarchyOptions(locationType,locationSelectedOneLevelHigher)), (hierarchyOption) ->
                "<option #{"selected='true'" if hierarchyOption is selectedLocations[locationType]}>#{hierarchyOption}</option>"
              ).join("")
            }
          </select>
        "
      )

    @hideSublocations()


    $("#reportOptions").append @formFilterTemplate(
      id: "report-type"
      label: "Report Type"
      form: "
      <select data-role='selector' id='report-type'>
        #{
          _.map(["dashboard","locations","spreadsheet","summarytables","analysis","alerts","incidence"], (type) =>
            "<option #{"selected='true'" if type is @reportType}>#{type}</option>"
          ).join("")
        }
      </select>
      "
    )

    this[@reportType]()

    $('div[data-role=fieldcontain]').fieldcontain()
    $('select[data-role=selector]').selectmenu()
    $('input.date').datebox
      mode: "calbox"
      dateFormat: "%Y-%m-%d"


  hierarchyOptions: (locationType, location) ->
    if locationType is "region"
      return _.keys WardHierarchy.hierarchy
    _.chain(WardHierarchy.hierarchy)
      .map (value,key) ->
        if locationType is "district" and location is key
          return _.keys value
        _.map value, (value,key) ->
          if locationType is "constituan" and location is key
            return _.keys value
          _.map value, (value,key) ->
            if locationType is "shehia" and location is key
              return value
      .flatten()
      .compact()
      .value()

  mostSpecificLocationSelected: ->
    mostSpecificLocationType = "region"
    mostSpecificLocationValue = "ALL"
    _.each @locationTypes, (locationType) ->
      unless this[locationType] is "ALL"
        mostSpecificLocationType = locationType
        mostSpecificLocationValue = this[locationType]
    return {
      type: mostSpecificLocationType
      name: mostSpecificLocationValue
    }

  formFilterTemplate: (options) ->
    "
        <tr id='row-#{options.id}' class='#{options.type}'>
          <td>
            <label style='display:inline' for='#{options.id}'>#{options.label}</label> 
          </td>
          <td style='width:150%'>
            #{options.form}
          </td>
        </tr>
    "

  getCases: (options) ->
    $.couch.db(Coconut.config.database_name()).view "#{Coconut.config.design_doc_name()}/caseIDsByDate",
      # Note that these seem reversed due to descending order
      startkey: moment(@endDate).endOf("day").format(Coconut.config.get "date_format")
      endkey: @startDate
      descending: true
      include_docs: false
      success: (result) =>

        caseIDs = _.unique(_.pluck result.rows, "value")

        cases = _.map caseIDs, (caseID) =>
          malariaCase = new Case
            caseID: caseID
          malariaCase.fetch
            success: =>
              afterAllCasesDownloaded()
          return malariaCase

        afterAllCasesDownloaded = _.after caseIDs.length, =>
          cases = _.chain(cases)
          .map (malariaCase) =>
            mostSpecificLocationSelected = @mostSpecificLocationSelected()
            if mostSpecificLocationSelected.name is "ALL" or malariaCase.withinLocation(mostSpecificLocationSelected)
              return malariaCase
          .compact()
          .value()

          options.success(cases)



  locations: ->

    $("#reportOptions").append @formFilterTemplate(
      id: "cluster"
      label: "Cluster"
      form: "
        <select name='cluster' id='cluster' data-role='slider'>
          <option value='off'>Off</option>
          <option value='on' #{if @cluster is "on" then "selected='true'" else ''}'>On</option>
        </select> 
      "
    )

    $("#reportContents").html "
      Use + - buttons to zoom map. Click and drag to reposition the map. Circles with a darker have multiple cases. Red cases show households with additional positive malaria cases.<br/>
      <div id='map' style='width:100%; height:600px;'></div>
    "

    $("#cluster").slider()

    @getCases
      # map notificatoin location too
      success: (results) =>

        locations = _.compact(_.map results, (caseResult) ->
          if caseResult.Household?["HouseholdLocation-latitude"]
            return {
              MalariaCaseID: caseResult.caseID
              latitude: caseResult.Household?["HouseholdLocation-latitude"]
              longitude: caseResult.Household?["HouseholdLocation-longitude"]
              hasAdditionalPositiveCasesAtHousehold: caseResult.hasAdditionalPositiveCasesAtHousehold()
              date: caseResult.Household?.lastModifiedAt
            }
        )

        if locations.length is 0
          $("#map").html "
            <h2>No location information for the range specified.</h2>
          "
          return

        latitudeSum = _.reduce locations, (memo,location) ->
          memo + Number(location.latitude)
        , 0

        longitudeSum = _.reduce locations, (memo,location) ->
          memo + Number(location.longitude)
        , 0

        # Use the average to center the map
        map = new L.Map('map', {
          center: new L.LatLng(
            latitudeSum/locations.length,
            longitudeSum/locations.length
          )
          zoom: 9
        })



#        map.addLayer(
#          new L.TileLayer(
#            'http://{s}.tile.cloudmade.com/4eb20961f7db4d93b9280e8df9b33d3f/997/256/{z}/{x}/{y}.png',
#            {maxZoom: 18}
#          )
#        )
#


        osm = new L.TileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png')
        bing = new L.BingLayer("Anqm0F_JjIZvT0P3abS6KONpaBaKuTnITRrnYuiJCE0WOhH6ZbE4DzeT6brvKVR5")
        map.addLayer(bing)
        map.addControl(new L.Control.Layers({'OSM':osm, "Bing":bing}, {}))

        L.Icon.Default.imagePath = 'js-libraries/Leaflet/images'
        
        if @cluster is "on"
          clusterGroup = new L.MarkerClusterGroup()
          _.each locations, (location) =>
            L.marker([location.latitude, location.longitude])
              .addTo(clusterGroup)
              .bindPopup "#{location.date}: <a href='#show/case/#{location.MalariaCaseID}'>#{location.MalariaCaseID}</a>"
          map.addLayer(clusterGroup)
        else
          _.each locations, (location) =>
            L.circleMarker([location.latitude, location.longitude],
              "fillColor": if location.hasAdditionalPositiveCasesAtHousehold then "red" else ""
              )
              .addTo(map)
              .bindPopup "
                 #{location.date}: <a href='#show/case/#{location.MalariaCaseID}'>#{location.MalariaCaseID}</a>
               "

  spreadsheetXLSXCrashing: ->
    #["Case Notification", "Facility","Household","Household Members"]
#    questions = ["Household Members"]
    questions = null
    @getCases
      success: (cases) =>

        fields = {}
        csv = {}
        allCasesFlattened = _.map cases, (malariaCase) ->

          malariaCaseFlattened = malariaCase.flatten(questions)
          _.each _.keys(malariaCaseFlattened), (field) ->
            fields[field] = true
          return malariaCaseFlattened



        spreadsheetData = "
<?xml version='1.0'?>
<ss:Workbook xmlns:ss='urn:schemas-microsoft-com:office:spreadsheet'>
    <ss:Worksheet ss:Name='Sheet1'>
        <ss:Table>
            <ss:Column ss:Width='80'/>
            <ss:Column ss:Width='80'/>
            <ss:Column ss:Width='80'/>
            <ss:Row>
              #{
                _.map(_.keys(fields), (header) ->
                  "
                  <ss:Cell>
                     <ss:Data ss:Type='String'>#{header}</ss:Data>
                  </ss:Cell>
                  "
                ).join("\n")
              }
            </ss:Row>
              #{
                _.map(allCasesFlattened, (malariaCaseFlattened) ->
                  "
                  <ss:Row>
                    #{
                      _.map(fields, (value,key) ->
                        #csv[key] = [] unless csv[key]
                        #csv[key].push malariaCaseFlattened[key] || null
                        #return malariaCaseFlattened[key] || null
                        return "
                        <ss:Cell>
                           <ss:Data ss:Type='String'>#{malariaCaseFlattened[key]}</ss:Data>
                        </ss:Cell>
                        "
                      ).join(",")
                    }
                  </ss:Row>
                  "
                ).join("\n")
              }
        </ss:Table>
    </ss:Worksheet>
</ss:Workbook>
        "

        console.log spreadsheetData

        $("#reportContents").html "
          <a id='csv' href='data:text/octet-stream;base64,#{Base64.encode(spreadsheetData)}' download='#{@startDate+"-"+@endDate}.xml'>Download spreadsheet</a>
        "
        $("a#csv").button()

  spreadsheet: ->
    #["Case Notification", "Facility","Household","Household Members"]
#    questions = ["Household Members"]
    questions = null
    @getCases
      success: (cases) =>

        fields = {}
        csv = {}
        allCasesFlattened = _.map cases, (malariaCase) ->

          malariaCaseFlattened = malariaCase.flatten(questions)
          _.each _.keys(malariaCaseFlattened), (field) ->
            fields[field] = true
          return malariaCaseFlattened

        csvHeaders = (_.keys(fields)).join(",")

        csvData = _.map(allCasesFlattened, (malariaCaseFlattened) ->
          _.map(fields, (value,key) ->
            csv[key] = [] unless csv[key]
            csv[key].push malariaCaseFlattened[key] || null
            return malariaCaseFlattened[key] || null
          ).join(",")
        ).join("\n")

        $("#reportContents").html "
          <a id='csv' href='data:text/octet-stream;base64,#{Base64.encode(csvHeaders + "\n" + csvData)}' download='#{@startDate+"-"+@endDate}.csv'>Download spreadsheet</a>
        "
        $("a#csv").button()

  results: ->
    $("#reportContents").html "
      <table id='results' class='tablesorter'>
        <thead>
          <tr>
          </tr>
        </thead>
        <tbody>
        </tbody>
      </table>
    "

    @getCases
      success: (cases) =>
        fields = "MalariaCaseID,LastModifiedAt,Questions".split(",")

        tableData = _.chain(cases)
        .sortBy  (caseResult) ->
          caseResult.LastModifiedAt()
        .value()
        .reverse()
        .map (caseResult) ->
          _.map fields, (field) ->
            caseResult[field]()

        $("table#results thead tr").append "
          #{ _.map(fields, (field) ->
            "<th>#{field}</th>"
          ).join("")
          }
        "

        $("table#results tbody").append _.map(tableData, (row) ->  "
          <tr>
            #{_.map(row, (element,index) -> "
              <td>#{
                if index is 0
                  "<a href='#show/case/#{element}'>#{element}</a>"
                else
                  element
              }</td>
            ").join("")
            }
          </tr>
        ").join("")

  getFieldListSelector: (resultCollection, selectorId) ->

        fields = _.chain(resultCollection.toJSON())
        .map (result) ->
          _.keys(result)
        .flatten()
        .uniq()
        .sort()
        .value()

        fields = _.without(fields, "_id", "_rev")
    
        return "
          <br/>
          Choose a field to summarize:<br/>
          <select data-role='selector' class='summarySelector' id='#{selectorId}'>
            <option></option>
            #{
              _.map(fields, (field) ->
                "<option id='#{field}'>#{field}</option>"
              ).join("")
            }
          </select>
        "

  summarytables: ->
    Coconut.resultCollection.fetch
      include_docs: true
      success: =>

        # TODO don't use Coconut.resultCollection - too BIG!!
        $("#reportContents").html @getFieldListSelector(Coconut.resultCollection, "summaryField1")
        $('#summaryField1').selectmenu()
        if @summaryField1?
          $('#summaryField1').val @summaryField1
          $('#summaryField1').selectmenu("refresh")
          @summarize @summaryField1

  summarySelectorChanged: (event) ->
    @summarize $(event.target).find("option:selected").text()
    @update()

  summarize: (field) ->

    @getCases
      success: (cases) =>
        results = {}

        _.each cases, (caseData) ->

          _.each caseData.toJSON(), (value,key) ->
            valuesToCheck = []
            if key is "Household Members"
              valuesToCheck = value
            else
              valuesToCheck.push value

            _.each valuesToCheck, (value,key) ->
              if value[field]?
                unless results[value[field]]?
                  results[value[field]] = {}
                  results[value[field]]["sums"] = 0
                  results[value[field]]["resultData"] = []
                results[value[field]]["sums"] += 1
                results[value[field]]["resultData"].push
                  caseID: caseData.caseID
                  resultID: value._id
                
        @$el.append  "<div id='summaryTables'></div>" unless $("#summaryTables").length is 1

        $("#summaryTables").html  "
          <h2>#{field}</h2>
          <table id='summaryTable' class='tablesorter'>
            <thead>
              <tr>
                <th>Value</th>
                <th>Total</th>
                <th class='cases'>Cases</th>
              </tr>
            </thead>
            <tbody>
              #{
                _.map( results, (aggregates,value) ->
                  "
                  <tr data-row-value='#{value}'>
                    <td>#{value}</td>
                    <td>
                      <button class='toggleDisaggregation'>#{aggregates["sums"]}</button>
                    </td>
                    <td class='cases'>
                      #{
                        _.map(aggregates.resultData, (resultData) ->
                          "<a data-result-id='#{resultData.resultID}' data-case-id='#{resultData.caseID}' data-row-value='#{value}' class='case' href='#show/case/#{resultData.caseID}/#{resultData.resultID}'>#{resultData.caseID}</a>"
                        ).join("")
                      }
                    </td>
                  </tr>
                  "
                ).join("")
              }
            </tbody>
          </table>
          <h3>
          Disaggregate summary based on another variable
          </h3>
        "
        $("#summaryTables").append $("#summaryField1").clone().attr("id", "summaryField2")
        $("#summaryField2").selectmenu()

        $("button").button()
        $("a").button()

        _.each $('table tr'), (row, index) ->
          $(row).addClass("odd") if index%2 is 1


  toggleDisaggregation: (event) ->
    $(event.target).parents("td").siblings(".cases").toggle()

  toggleDisaggregationSameCell: (event) ->
    $(event.target).siblings(".cases").toggle()

  summarySelector2Changed: (event) ->
    @disaggregateSummary $(event.target).find("option:selected").text()

  disaggregateSummary:(field) ->
    data = {}
    disaggregatedSummaryTable = $("#summaryTable").clone().attr("id","disaggregatedSummaryTable")
    cases  = disaggregatedSummaryTable.find("a.case")
    _.each cases, (caseElement) ->
      caseElement = $(caseElement)
      rowValue = caseElement.attr("data-row-value")
      data[rowValue] = {} unless data[rowValue]
      resultID =  caseElement.attr("data-result-id")
      result = new Result
        _id: resultID
      result.fetch
        success: ->
          fieldValue = result.get field
          if fieldValue?
            unless data[rowValue][fieldValue]
              data[rowValue][fieldValue] = 0
            data[rowValue][fieldValue] += 1
            afterLookups()
          else
            caseID =  caseElement.attr("data-case-id")
            caseData = new Case
              caseID: caseID
            caseData.fetch
              success: ->
                fieldValue = caseData.flatten()[field]
                unless data[rowValue][fieldValue]
                  data[rowValue][fieldValue] = 0
                data[rowValue][fieldValue] += 1
                afterLookups()
    afterLookups = _.after cases.length, ->
      console.log data
      columns = _.uniq(_.flatten(_.map(data, (row) ->
        _.keys row
      )).sort())
      console.log columns
      disaggregatedSummaryTable.find("thead tr").append(_.map(columns, (column)->
          "<th>#{column}</th>"
        ).join("")
      )
      _.each data, (value, rowValue) ->
        row = disaggregatedSummaryTable.find("tbody tr[data-row-value='#{rowValue}']")
        _.each columns, (column) ->
          if value[column]
            row.append "<td>#{value[column]}</td>"
          else
            row.append "<td>0</td>"

      $("#summaryTables").append disaggregatedSummaryTable
  

  createTable: (headerValues, rows) ->
   "
      <table class='tablesorter'>
        <thead>
          <tr>
            #{
              _.map(headerValues, (header) ->
                "<th>#{header}</th>"
              ).join("")
            }
          </tr>
        </thead>
        <tbody>
          #{rows}
        </tbody>
      </table>
    "

  incidence: ->
    $("#reportContents").html "<div id='analysis'></div>"

    $("#analysis").append "
      <style>
      #chart_container {
        position: relative;
        font-family: Arial, Helvetica, sans-serif;
      }
      #chart {
        position: relative;
        left: 40px;
      }
      #y_axis {
        position: absolute;
        top: 0;
        bottom: 0;
        width: 40px;
      }
      </style>
      <div id='chart_container'>
        <div id='y_axis'></div>
        <div id='chart'></div>
      </div>
    "
    $.couch.db(Coconut.config.database_name()).view "#{Coconut.config.design_doc_name()}/positiveCases",
      startkey: "2012"
      include_docs: false
      success: (result) ->
        casesPerAggregationPeriod = {}

        _.each result.rows, (row) ->
          date = moment(row.key.substr(0,10))
          if row.key.substr(0,2) is "20" and date?.isValid() and date > moment.utc("2012-07-01") and date < new moment()
            aggregationKey = date.unix()
            casesPerAggregationPeriod[aggregationKey] = 0 unless casesPerAggregationPeriod[aggregationKey]
            casesPerAggregationPeriod[aggregationKey] += 1
        dataForGraph = _.map casesPerAggregationPeriod, (numberOfCases, date) ->
          x: parseInt(date)
          y: numberOfCases

        graph = new Rickshaw.Graph
          element: document.querySelector("#chart"),
          width: 580,
          height: 250,
          series: [
                color: 'steelblue',
                data: dataForGraph
          ]

        x_axis = new Rickshaw.Graph.Axis.Time
          graph: graph

        y_axis = new Rickshaw.Graph.Axis.Y
          graph: graph,
          orientation: 'left',
          tickFormat: Rickshaw.Fixtures.Number.formatKMBT,
          element: document.getElementById('y_axis'),

        graph.render()

  alerts: ->

    # Cases that have NOT been followed up
    # Under 5 cases
    # # household interviews < X
    # # of new cases < X
    # increase in cases from MCN > X
    # Under a net change
    # Travel change

    @getCases
      success: (cases) =>
        IRSThresholdInMonths = 6
  
        followupsByDistrict = {}
        passiveCasesByDistrict = {}
        agesByDistrict = {}
        netsAndIRSByDistrict = {}
        travelByDistrict = {}
        totalPositiveCasesByDistrict = {}

        # Setup hashes for each table
        districts = ["ALL"]
        _.each districts, (district) ->
          followupsByDistrict[district] =
            meedsCases: []
            casesFollowedUp: []
          passiveCasesByDistrict[district] =
            indexCases: []
            householdMembers: []
            passiveCases: []
          agesByDistrict[district] =
            underFive: []
            fiveToFifteen: []
            fifteenToTwentyFive: []
            overTwentyFive: []
            unknown: []
          netsAndIRSByDistrict[district] =
            sleptUnderNet: []
            recentIRS: []
          travelByDistrict[district] =
            travelReported: []
          totalPositiveCasesByDistrict[district] = []

        _.each cases, (malariaCase) ->
          followupsByDistrict["ALL"].meedsCases.push malariaCase if malariaCase["USSD Notification"]?
          followupsByDistrict["ALL"].casesFollowedUp.push malariaCase if malariaCase["Household Members"]?.length is 0

          passiveCasesByDistrict["ALL"].indexCases.push malariaCase if malariaCase["Case Notification"]?

          passiveCasesByDistrict["ALL"].householdMembers =  passiveCasesByDistrict["ALL"].householdMembers.concat(malariaCase["Household Members"]) if malariaCase["Household Members"]?

          passiveCasesByDistrict["ALL"].passiveCases = passiveCasesByDistrict["ALL"].passiveCases.concat malariaCase.positiveCasesAtHousehold()

          _.each malariaCase.positiveCasesIncludingIndex(), (positiveCase) ->
            totalPositiveCasesByDistrict["ALL"].push positiveCase

            if positiveCase.Age?
              age = parseInt(positiveCase.Age)
              if age < 5
                agesByDistrict["ALL"].underFive.push positiveCase
            else
              agesByDistrict["ALL"].unknown.push positiveCase unless positiveCase.age

            if (positiveCase.SleptunderLLINlastnight is "Yes" || positiveCase.IndexcaseSleptunderLLINlastnight is "Yes")
              netsAndIRSByDistrict["ALL"].sleptUnderNet.push positiveCase

            if (positiveCase.LastdateofIRS and positiveCase.LastdateofIRS.match(/\d\d\d\d-\d\d-\d\d/))
              # if date of spraying is less than X months
              if (new moment).subtract('months',IRSThresholdInMonths) < (new moment(positiveCase.LastdateofIRS))
                netsAndIRSByDistrict["ALL"].recentIRS.push positiveCase
              
            if (positiveCase.TravelledOvernightinpastmonth is "Yes" || positiveCase.OvernightTravelinpastmonth is "Yes")
              travelByDistrict["ALL"].travelReported.push positiveCase

        _.each followupsByDistrict, (values, district) ->
          followupsByDistrict[district].meedsCasesFollowedUp = _.intersection(followupsByDistrict[district].meedsCases, followupsByDistrict[district].casesFollowedUp)

        $("#reportContents").html "<div id='analysis'></div>"

        $("#analysis").append "
          <table id='alertsTable' class='tablesorter'>
            <tbody>
              #{
                _.map(followupsByDistrict, (values,district) =>
                  "
                    <tr>
                      <td>
                        No. of MEEDS cases reported
                      </td>
                      <td>#{@createDisaggregatableCaseGroup(values.meedsCases.length,values.meedsCases)}</td>
                    </tr>
                    <tr>
                      <td>
                         No. of MEEDS cases not followed up
                      </td>
                      <td>#{@createDisaggregatableCaseGroup(values.meedsCasesFollowedUp.length,values.meedsCasesFollowedUp)}</td>
                    </tr>
                    <tr>
                      <td>
                         % of MEEDS cases followed up
                      </td>
                      <td>#{@formattedPercent(1 - (values.meedsCasesFollowedUp.length/values.meedsCases.length))}</td>
                    </tr>
                    <tr>
                      <td>
                         Total No. of cases followed up
                      </td>
                      <td>#{@createDisaggregatableCaseGroup(values.casesFollowedUp.length,values.casesFollowedUp)}</td>
                    </tr>
                  "
                ).join("") +
                _.map(passiveCasesByDistrict, (values,district) =>
                  "
                    <tr>
                      <td>
                      No. of case notifications
                      </td>
                      <td>#{@createDisaggregatableCaseGroup(values.indexCases.length,values.indexCases)}</td>
                    </tr>
                    <tr>
                      <td>
                        No. of additional household members tested
                      </td>
                      <td>#{@createDisaggregatableDocGroup(values.householdMembers.length,values.householdMembers)}</td>
                    </tr>
                    <tr>
                      <td>
                        No. of additional household members tested positive
                      </td>
                      <td>#{@createDisaggregatableDocGroup(values.passiveCases.length,values.passiveCases)}</td>
                    </tr>
                    <tr>
                      <td>
                        % of household members tested positive
                      </td>
                      <td>#{@formattedPercent(values.passiveCases.length / values.householdMembers.length)}</td>
                    </tr>
                    <tr>
                      <td>
                          % increase in cases found using MCN
                      </td>
                      <td>#{@formattedPercent(values.passiveCases.length / values.indexCases.length)}</td>
                    </tr>
                 "
                ).join("") +
                _.map(agesByDistrict, (values,district) =>
                  "
                    <tr>
                      <td>
                        No. of positive cases in persons under 5
                      </td>
                      <td>#{@createDisaggregatableDocGroup(values.underFive.length,values.underFive)}</td>
                    </tr>
                    <tr>
                      <td>
                        Percent of positive cases in persons under 5
                      </td>
                      <td>#{@formattedPercent(values.underFive.length / totalPositiveCasesByDistrict[district].length)}</td>
                    </tr>
                  "
                ).join("") +
                _.map(netsAndIRSByDistrict, (values,district) =>
                  "
                    <tr>
                      <td>
                        Positive Cases
                      </td>
                      <td>#{@createDisaggregatableDocGroup(totalPositiveCasesByDistrict[district].length,totalPositiveCasesByDistrict[district])}</td>
                    </tr>
                    <tr>
                      <td>
                        Positive Cases (index & household) that slept under a net night before diagnosis (percent)
                      </td>
                      <td>
                      #{@createDisaggregatableDocGroup(values.sleptUnderNet.length,values.sleptUnderNet)}
                      (#{@formattedPercent(values.sleptUnderNet.length / totalPositiveCasesByDistrict[district].length)})
                      </td>
                    </tr>
                    <tr>
                      <td>
                        Positive Cases from a household that has been sprayed within last #{IRSThresholdInMonths} months
                      </td>
                      <td>
                        #{@createDisaggregatableDocGroup(values.recentIRS.length,values.recentIRS)}
                        (#{@formattedPercent(values.recentIRS.length / totalPositiveCasesByDistrict[district].length)})
                      </td>
                    </tr>
                  "
                ).join("") +
                _.map(travelByDistrict, (values,district) =>
                  "
                    <tr>
                      <td>
                        Positive Cases (index & household) that traveled within last month (percent)
                      </td>
                      <td>
                        #{@createDisaggregatableDocGroup(values.travelReported.length,values.travelReported)}
                        (#{@formattedPercent(values.travelReported.length / totalPositiveCasesByDistrict[district].length)})
                      </td>
                    </tr>
                  "
                ).join("")
              }
            </tbody>
          </table>
        "

        index = 0
        _.each $("#alertsTable tr"), (row) ->
          $(row).addClass "odd" if (index+=1)%2 is 0

        if @alertEmail is "true"
          $(".ui-datebox-container").remove()
          $("#navbar").remove()
          $("#reportOptions").remove()
          $("[data-role=footer]").remove()
          $(".cases").remove()

        $("#analysis").append "<span id='#done'/>"

        ###
        $.ajax
          type: "POST"
          url: "https://api.mailgun.net/v2/samples.mailgun.org/messages"
          username: "api:key-8h-nx3dvfxktuajc008y8092gkvsv500"
          dataType: "json"
          data:
            from: "mikeymckay@gmail.com"
            to: "mikeymckay@gmail.com"
            subject: "test"
            text: "YO"
        ###
        
  analysis: ->

    @getCases
      success: (cases) =>
        IRSThresholdInMonths = 6
  
        followupsByDistrict = {}
        passiveCasesByDistrict = {}
        agesByDistrict = {}
        netsAndIRSByDistrict = {}
        travelByDistrict = {}
        totalPositiveCasesByDistrict = {}

        # Setup hashes for each table
        districts = WardHierarchy.allDistricts()
        districts.push("UNKNOWN")
        districts.push("ALL")
        _.each districts, (district) ->
          followupsByDistrict[district] =
            meedsCases: []
            casesFollowedUp: []
          passiveCasesByDistrict[district] =
            indexCases: []
            householdMembers: []
            passiveCases: []
          agesByDistrict[district] =
            underFive: []
            fiveToFifteen: []
            fifteenToTwentyFive: []
            overTwentyFive: []
            unknown: []
          netsAndIRSByDistrict[district] =
            sleptUnderNet: []
            recentIRS: []
          travelByDistrict[district] =
            travelReported: []
          totalPositiveCasesByDistrict[district] = []

        tmp = 0
        _.each cases, (malariaCase) ->
          district = malariaCase.district() || "UNKNOWN"
          followupsByDistrict[district].meedsCases.push malariaCase if malariaCase["USSD Notification"]?
          followupsByDistrict["ALL"].meedsCases.push malariaCase if malariaCase["USSD Notification"]?
          followupsByDistrict[district].casesFollowedUp.push malariaCase if malariaCase["Household Members"]?.length > 0
          followupsByDistrict["ALL"].casesFollowedUp.push malariaCase if malariaCase["Household Members"]?.length > 0

          passiveCasesByDistrict[district].indexCases.push malariaCase if malariaCase["Case Notification"]?
          passiveCasesByDistrict["ALL"].indexCases.push malariaCase if malariaCase["Case Notification"]?

          passiveCasesByDistrict[district].householdMembers =  passiveCasesByDistrict[district].householdMembers.concat(malariaCase["Household Members"]) if malariaCase["Household Members"]?
          passiveCasesByDistrict["ALL"].householdMembers =  passiveCasesByDistrict["ALL"].householdMembers.concat(malariaCase["Household Members"]) if malariaCase["Household Members"]?

          passiveCasesByDistrict[district].passiveCases = passiveCasesByDistrict[district].passiveCases.concat malariaCase.positiveCasesAtHousehold()
          passiveCasesByDistrict["ALL"].passiveCases = passiveCasesByDistrict["ALL"].passiveCases.concat malariaCase.positiveCasesAtHousehold()

          _.each malariaCase.positiveCasesIncludingIndex(), (positiveCase) ->
            totalPositiveCasesByDistrict[district].push positiveCase
            totalPositiveCasesByDistrict["ALL"].push positiveCase

            if positiveCase.Age?
              age = parseInt(positiveCase.Age)
              if age < 5
                agesByDistrict[district].underFive.push positiveCase
                agesByDistrict["ALL"].underFive.push positiveCase
              else if age < 15
                agesByDistrict[district].fiveToFifteen.push positiveCase
                agesByDistrict["ALL"].fiveToFifteen.push positiveCase
              else if age < 25
                agesByDistrict[district].fifteenToTwentyFive.push positiveCase
                agesByDistrict["ALL"].fifteenToTwentyFive.push positiveCase
              else if age >= 25
                agesByDistrict[district].overTwentyFive.push positiveCase
                agesByDistrict["ALL"].overTwentyFive.push positiveCase
            else
              agesByDistrict[district].unknown.push positiveCase unless positiveCase.age
              agesByDistrict["ALL"].unknown.push positiveCase unless positiveCase.age

            if (positiveCase.SleptunderLLINlastnight is "Yes" || positiveCase.IndexcaseSleptunderLLINlastnight is "Yes")
              netsAndIRSByDistrict[district].sleptUnderNet.push positiveCase
              netsAndIRSByDistrict["ALL"].sleptUnderNet.push positiveCase

            if (positiveCase.LastdateofIRS and positiveCase.LastdateofIRS.match(/\d\d\d\d-\d\d-\d\d/))
              # if date of spraying is less than X months
              if (new moment).subtract('months',IRSThresholdInMonths) < (new moment(positiveCase.LastdateofIRS))
                netsAndIRSByDistrict[district].recentIRS.push positiveCase
                netsAndIRSByDistrict["ALL"].recentIRS.push positiveCase
              
            if (positiveCase.TravelledOvernightinpastmonth is "Yes" || positiveCase.OvernightTravelinpastmonth is "Yes")
              travelByDistrict[district].travelReported.push positiveCase
              travelByDistrict["ALL"].travelReported.push positiveCase

        _.each followupsByDistrict, (values, district) ->
          followupsByDistrict[district].meedsCasesFollowedUp = _.intersection(followupsByDistrict[district].meedsCases, followupsByDistrict[district].casesFollowedUp)

        $("#reportContents").html "<div id='analysis'><hr/><div style='font-style:italic'>Click on a column heading to sort.</div><hr/></div>"

        $("#analysis").append @createTable "District, No. of MEEDS cases reported, No. of MEEDS cases followed up, % of MEEDS cases followed up, Total No. of cases followed up".split(/, */), "
          #{
            _.map(followupsByDistrict, (values,district) =>
              "
                <tr>
                  <td>#{district}</td>
                  <td>#{@createDisaggregatableCaseGroup(values.meedsCases.length,values.meedsCases)}</td>
                  <td>#{@createDisaggregatableCaseGroup(values.meedsCasesFollowedUp.length,values.meedsCasesFollowedUp)}</td>
                  <td>#{@formattedPercent(values.meedsCasesFollowedUp.length/values.meedsCases.length)}</td>
                  <td>#{@createDisaggregatableCaseGroup(values.casesFollowedUp.length,values.casesFollowedUp)}</td>
                </tr>
              "
            ).join("")
          }
        "

        $("#analysis").append "<hr>"
        $("#analysis").append @createTable "District, No. of case notifications, No. of additional household members tested, No. of additional household members tested positive, % of household members tested positive, % increase in cases found using MCN".split(/, */), "
          #{
            _.map(passiveCasesByDistrict, (values,district) =>
              "
                <tr>
                  <td>#{district}</td>
                  <td>#{@createDisaggregatableCaseGroup(values.indexCases.length,values.indexCases)}</td>
                  <td>#{@createDisaggregatableDocGroup(values.householdMembers.length,values.householdMembers)}</td>
                  <td>#{@createDisaggregatableDocGroup(values.passiveCases.length,values.passiveCases)}</td>
                  <td>#{@formattedPercent(values.passiveCases.length / values.householdMembers.length)}</td>
                  <td>#{@formattedPercent(values.passiveCases.length / values.indexCases.length)}</td>
                </tr>
              "
            ).join("")
          }
        "

        $("#analysis").append "<hr>"
        $("#analysis").append @createTable "District, <5, 5<15, 15<25, >=25, Unknown, Total, %<5, %5<15, %15<25, %>=25, Unknown".split(/, */), "
          #{
            _.map(agesByDistrict, (values,district) =>
              "
                <tr>
                  <td>#{district}</td>
                  <td>#{@createDisaggregatableDocGroup(values.underFive.length,values.underFive)}</td>
                  <td>#{@createDisaggregatableDocGroup(values.fiveToFifteen.length,values.fiveToFifteen)}</td>
                  <td>#{@createDisaggregatableDocGroup(values.fifteenToTwentyFive.length,values.fifteenToTwentyFive)}</td>
                  <td>#{@createDisaggregatableDocGroup(values.overTwentyFive.length,values.overTwentyFive)}</td>
                  <td>#{@createDisaggregatableDocGroup(values.unknown.length,values.overTwentyFive)}</td>
                  <td>#{@createDisaggregatableDocGroup(totalPositiveCasesByDistrict[district].length,totalPositiveCasesByDistrict[district])}</td>

                  <td>#{@formattedPercent(values.underFive.length / totalPositiveCasesByDistrict[district].length)}</td>
                  <td>#{@formattedPercent(values.fiveToFifteen.length / totalPositiveCasesByDistrict[district].length)}</td>
                  <td>#{@formattedPercent(values.fifteenToTwentyFive.length / totalPositiveCasesByDistrict[district].length)}</td>
                  <td>#{@formattedPercent(values.overTwentyFive.length / totalPositiveCasesByDistrict[district].length)}</td>
                  <td>#{@formattedPercent(values.unknown.length / totalPositiveCasesByDistrict[district].length)}</td>
                </tr>
              "
            ).join("")
          }
        "

        $("#analysis").append "<hr>"
        $("#analysis").append @createTable "District, Positive Cases, Positive Cases (index & household) that slept under a net night before diagnosis, %, Positive Cases from a household that has been sprayed within last #{IRSThresholdInMonths} months, %".split(/, */), "
          #{
            _.map(netsAndIRSByDistrict, (values,district) =>
              "
                <tr>
                  <td>#{district}</td>
                  <td>#{@createDisaggregatableDocGroup(totalPositiveCasesByDistrict[district].length,totalPositiveCasesByDistrict[district])}</td>
                  <td>#{@createDisaggregatableDocGroup(values.sleptUnderNet.length,values.sleptUnderNet)}</td>
                  <td>#{@formattedPercent(values.sleptUnderNet.length / totalPositiveCasesByDistrict[district].length)}</td>
                  <td>#{@createDisaggregatableDocGroup(values.recentIRS.length,values.recentIRS)}</td>
                  <td>#{@formattedPercent(values.recentIRS.length / totalPositiveCasesByDistrict[district].length)}</td>
                </tr>
              "
            ).join("")
          }
        "

        $("#analysis").append "<hr>"
        $("#analysis").append @createTable "District, Positive Cases, Positive Cases (index & household) that traveled within last month, %".split(/, */), "
          #{
            _.map(travelByDistrict, (values,district) =>
              "
                <tr>
                  <td>#{district}</td>
                  <td>#{@createDisaggregatableDocGroup(totalPositiveCasesByDistrict[district].length,totalPositiveCasesByDistrict[district])}</td>
                  <td>#{@createDisaggregatableDocGroup(values.travelReported.length,values.travelReported)}</td>
                  <td>#{@formattedPercent(values.travelReported.length / totalPositiveCasesByDistrict[district].length)}</td>
                </tr>
              "
            ).join("")
          }
        "

        $("#analysis table").tablesorter
          widgets: ['zebra']
          sortList: [[0,0]]
          textExtraction: (node) ->
            sortValue = $(node).find(".sort-value").text()
            if sortValue != ""
              sortValue
            else
              if $(node).text() is "--"
                "-1"
              else
                $(node).text()

  formattedPercent: (number) ->
    percent = (number  * 100).toFixed(0)
    if isNaN(percent) then "--" else "#{percent}%"

  dashboard: ->
    $("tr.location").hide()
          
    $("#reportContents").html "
      <!--
      Reported/Facility Followup/Household Followup/#Tested/ (Show for Same period last year)
      For completed cases, average time between notification and household followup
      Last seven days
      Last 30 days
      Last 365 days
      Current month
      Current year
      Total
      -->
      <h2>Alerts</h2>
      <div id='alerts'></div>
      <h1>
        Cases
      </h2>
      For the selected period:<br/>
      <table>
        <tr>
          <td>Cases Reported at Facility</td>
          <td id='Cases-Reported-at-Facility'></td>
        </tr>
        <tr>
          <td>Additional People Tested</td>
          <td id='Additional-People-Tested'></td>
        </tr>
        <tr>
          <td>Additional People Tested Positive</td>
          <td id='Additional-People-Tested-Positive'></td>
        </tr>
      </table>
      <br/>

      Click on a button for more details about the case. Pink buttons are for <span style='background-color:pink'> positive malaria results.</span>
      <table class='summary tablesorter'>
        <thead><tr>
        </tr></thead>
        <tbody>
        </tbody>
      </table>
      <style>
        table a, table a:link, table a:visited {color: blue; font-size: 150%}
      </style>
    "

    tableColumns = ["Case ID","Diagnosis Date","Health Facility District","USSD Notification"]
    Coconut.questions.fetch
      success: ->
        tableColumns = tableColumns.concat Coconut.questions.map (question) ->
          question.label()
        _.each tableColumns, (text) ->
          $("table.summary thead tr").append "<th>#{text} (<span id='th-#{text.replace(/\s/,"")}-count'></span>)</th>"

    @getCases
      success: (cases) =>
        _.each cases, (malariaCase) =>

          malariaCase.fetch
            success: =>

              $("table.summary tbody").append "
                <tr id='case-#{malariaCase.caseID}'>
                  <td class='CaseID'>
                    <a href='#show/case/#{malariaCase.caseID}'><button>#{malariaCase.caseID}</button></a>
                  </td>
                  <td class='IndexCaseDiagnosisDate'>
                    #{malariaCase.indexCaseDiagnosisDate()}
                  </td>
                  <td class='HealthFacilityDistrict'>
                    #{
                      if malariaCase["USSD Notification"]?
                        FacilityHierarchy.getDistrict(malariaCase["USSD Notification"].hf)
                      else
                        ""
                    }
                  </td>
                  <td class='USSDNotification'>
                    #{@createDashboardLinkForResult(malariaCase,"USSD Notification", "<img src='images/ussd.png'/>")}
                  </td>
                  <td class='CaseNotification'>
                    #{@createDashboardLinkForResult(malariaCase,"Case Notification","<img src='images/caseNotification.png'/>")}
                  </td>
                  <td class='Facility'>
                    #{@createDashboardLinkForResult(malariaCase,"Facility", "<img src='images/facility.png'/>")}
                  </td>
                  <td class='Household'>
                    #{@createDashboardLinkForResult(malariaCase,"Household", "<img src='images/household.png'/>")}
                  </td>
                  <td class='HouseholdMembers'>
                    #{
                      _.map(malariaCase["Household Members"], (householdMember) =>
                        buttonText = "<img src='images/householdMember.png'/>"
                        unless householdMember.complete?
                          unless householdMember.complete
                            buttonText = buttonText.replace(".png","Incomplete.png")
                        @createCaseLink
                          caseID: malariaCase.caseID
                          docId: householdMember._id
                          buttonClass: if householdMember.MalariaTestResult? and (householdMember.MalariaTestResult is "PF" or householdMember.MalariaTestResult is "Mixed") then "malaria-positive" else ""
                          buttonText: buttonText
                      ).join("")
                    }
                  </td>
                </tr>
              "
              afterRowsAreInserted()

        afterRowsAreInserted = _.after cases.length, ->
          _.each tableColumns, (text) ->
            columnId = text.replace(/\s/,"")
            $("#th-#{columnId}-count").html $("td.#{columnId} button").length

          $("#Cases-Reported-at-Facility").html $("td.CaseID button").length
          $("#Additional-People-Tested").html $("td.HouseholdMembers button").length
          $("#Additional-People-Tested-Positive").html $("td.HouseholdMembers button.malaria-positive").length

          if $("table.summary tr").length > 1
            $("table.summary").tablesorter
              widgets: ['zebra']
              sortList: [[1,1]]

          districtsWithFollowup = {}
          _.each $("table.summary tr"), (row) ->
              row = $(row)
              if row.find("td.USSDNotification button").length > 0
                if row.find("td.CaseNotification button").length is 0
                  if moment().diff(row.find("td.IndexCaseDiagnosisDate").html(),"days") > 2
                    districtsWithFollowup[row.find("td.HealthFacilityDistrict").html()] = 0 unless districtsWithFollowup[row.find("td.HealthFacilityDistrict").html()]?
                    districtsWithFollowup[row.find("td.HealthFacilityDistrict").html()] += 1
          $("#alerts").append "
          <style>
            #alerts,table.alerts{
              font-size: 80% 
            }

          </style>
          The following districts have USSD Notifications that have not been followed up after two days. Recommendation call the DMSO:
            <table class='alerts'>
              <thead>
                <tr>
                  <th>District</th><th>Number of cases</th>
                </tr>
              </thead>
              <tbody>
                #{
                  _.map(districtsWithFollowup, (numberOfCases,district) -> "
                    <tr>
                      <td>#{district}</td>
                      <td>#{numberOfCases}</td>
                    </tr>
                  ").join("")
                }
              </tbody>
            </table>
          "

  createDashboardLinkForResult: (malariaCase,resultType,buttonText = "") ->
    if malariaCase[resultType]?
      unless malariaCase[resultType].complete?
        unless malariaCase[resultType].complete
          buttonText = buttonText.replace(".png","Incomplete.png") unless resultType is "USSD Notification"
      @createCaseLink
        caseID: malariaCase.caseID
        docId: malariaCase[resultType]._id
        buttonText: buttonText
    else ""

  createCaseLink: (options) ->
    options.buttonText ?= options.caseID
    "<a href='#show/case/#{options.caseID}#{if options.docId? then "/" + options.docId else ""}'><button class='#{options.buttonClass}'>#{options.buttonText}</button></a>"


  createCasesLinks: (cases) ->
    _.map(cases, (malariaCase) =>
      @createCaseLink  caseID: malariaCase.caseID
    ).join("")

  createDisaggregatableCaseGroup: (text,cases) ->
    "
      <button class='sort-value same-cell-disaggregatable'>#{text}</button>
      <div class='cases' style='display:none'>
        #{@createCasesLinks cases}
      </div>
    "

  createDocLinks: (docs) ->
    _.map(docs, (doc) =>
      @createCaseLink
        caseID: doc.MalariaCaseID
        docId: doc._id
    ).join("")

  createDisaggregatableDocGroup: (text,docs) ->
    "
      <button class='sort-value same-cell-disaggregatable'>#{text}</button>
      <div class='cases' style='display:none'>
        #{@createDocLinks docs}
      </div>
    "

