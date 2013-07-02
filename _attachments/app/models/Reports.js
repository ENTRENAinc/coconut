// Generated by CoffeeScript 1.6.2
var Reports,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Reports = (function() {
  function Reports(options) {
    if (options == null) {
      options = {};
    }
    this.getCases = __bind(this.getCases, this);
    this.startDate = options.startDate || moment(new Date).subtract('days', 7).format("YYYY-MM-DD");
    this.endDate = options.endDate || moment(new Date).format("YYYY-MM-DD");
    this.cluster = options.cluster || "off";
    this.summaryField1 = options.summaryField1;
    this.alertEmail = options.alertEmail || "false";
    this.locationTypes = "region, district, constituan, shehia".split(/, /);
    this.mostSpecificLocation = options.mostSpecificLocation || {
      type: "region",
      name: "ALL"
    };
  }

  Reports.prototype.positiveCaseLocations = function(options) {
    return $.couch.db(Coconut.config.database_name()).view("" + (Coconut.config.design_doc_name()) + "/positiveCaseLocations", {
      success: function(result) {
        var currentLocation, currentLocationIndex, distanceInMeters, loc, locIndex, locations, _i, _j, _len, _len1, _ref, _ref1;

        locations = [];
        _ref = result.rows;
        for (currentLocationIndex = _i = 0, _len = _ref.length; _i < _len; currentLocationIndex = ++_i) {
          currentLocation = _ref[currentLocationIndex];
          currentLocation = currentLocation.value;
          locations[currentLocation] = {
            100: [],
            1000: [],
            5000: [],
            10000: []
          };
          _ref1 = result.rows;
          for (locIndex = _j = 0, _len1 = _ref1.length; _j < _len1; locIndex = ++_j) {
            loc = _ref1[locIndex];
            if (locIndex === currentLocationIndex) {
              continue;
            }
            loc = loc.value;
            distanceInMeters = (new LatLon(currentLocation[0], currentLocation[1])).distanceTo(new LatLon(loc[0], loc[1])) * 1000;
            if (distanceInMeters < 100) {
              locations[currentLocation][100].push(loc);
            } else if (distanceInMeters < 1000) {
              locations[currentLocation][1000].push(loc);
            } else if (distanceInMeters < 5000) {
              locations[currentLocation][5000].push(loc);
            } else if (distanceInMeters < 10000) {
              locations[currentLocation][10000].push(loc);
            }
          }
        }
        return options.success(locations);
      }
    });
  };

  Reports.prototype.positiveCaseClusters = function() {
    return this.positiveCaseLocations({
      success: function(positiveCases) {
        var cluster, positiveCase, _results;

        _results = [];
        for (positiveCase in positiveCases) {
          cluster = positiveCases[positiveCase];
          if (cluster[100].length > 4) {
            _results.push(console.log("" + cluster[100].length + " cases within 100 meters of one another"));
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      }
    });
  };

  Reports.prototype.getCases = function(options) {
    var _this = this;

    return $.couch.db(Coconut.config.database_name()).view("" + (Coconut.config.design_doc_name()) + "/caseIDsByDate", {
      startkey: moment(this.endDate).endOf("day").format(Coconut.config.get("date_format")),
      endkey: this.startDate,
      descending: true,
      include_docs: false,
      success: function(result) {
        var caseIDs;

        caseIDs = _.unique(_.pluck(result.rows, "value"));
        return $.couch.db(Coconut.config.database_name()).view("" + (Coconut.config.design_doc_name()) + "/cases", {
          keys: caseIDs,
          include_docs: true,
          success: function(result) {
            return options.success(_.chain(result.rows).groupBy(function(row) {
              return row.key;
            }).map(function(resultsByCaseID) {
              var malariaCase;

              malariaCase = new Case({
                results: resultsByCaseID.doc
              });
              console.log(malariaCase);
              if (_this.mostSpecificLocation.name === "ALL" || malariaCase.withinLocation(_this.mostSpecificLocation)) {
                return malariaCase;
              }
            }).compact().value());
          },
          error: function() {
            return options != null ? options.error() : void 0;
          }
        });
      }
    });
  };

  Reports.prototype.alerts = function(callback) {
    var data,
      _this = this;

    data = {};
    return this.getCases({
      success: function(cases) {
        var IRSThresholdInMonths, districts;

        IRSThresholdInMonths = 6;
        data.followupsByDistrict = {};
        data.passiveCasesByDistrict = {};
        data.agesByDistrict = {};
        data.genderByDistrict = {};
        data.netsAndIRSByDistrict = {};
        data.travelByDistrict = {};
        data.totalPositiveCasesByDistrict = {};
        districts = WardHierarchy.allDistricts();
        districts.push("UNKNOWN");
        districts.push("ALL");
        _.each(districts, function(district) {
          data.followupsByDistrict[district] = {
            allCases: [],
            casesFollowedUp: [],
            casesNotFollowedUp: [],
            missingUssdNotification: [],
            missingCaseNotification: []
          };
          data.passiveCasesByDistrict[district] = {
            indexCases: [],
            householdMembers: [],
            passiveCases: []
          };
          data.agesByDistrict[district] = {
            underFive: [],
            fiveToFifteen: [],
            fifteenToTwentyFive: [],
            overTwentyFive: [],
            unknown: []
          };
          data.genderByDistrict[district] = {
            male: [],
            female: [],
            unknown: []
          };
          data.netsAndIRSByDistrict[district] = {
            sleptUnderNet: [],
            recentIRS: []
          };
          data.travelByDistrict[district] = {
            travelReported: []
          };
          return data.totalPositiveCasesByDistrict[district] = [];
        });
        _.each(cases, function(malariaCase) {
          var completedHouseholdMembers, district, positiveCasesAtHousehold, _ref, _ref1;

          district = malariaCase.district() || "UNKNOWN";
          data.followupsByDistrict[district].allCases.push(malariaCase);
          data.followupsByDistrict["ALL"].allCases.push(malariaCase);
          if (((_ref = malariaCase["Household"]) != null ? _ref.complete : void 0) === "true") {
            data.followupsByDistrict[district].casesFollowedUp.push(malariaCase);
            data.followupsByDistrict["ALL"].casesFollowedUp.push(malariaCase);
          } else {
            data.followupsByDistrict[district].casesNotFollowedUp.push(malariaCase);
            data.followupsByDistrict["ALL"].casesNotFollowedUp.push(malariaCase);
          }
          if (malariaCase["USSD Notification"] == null) {
            data.followupsByDistrict[district].missingUssdNotification.push(malariaCase);
            data.followupsByDistrict["ALL"].missingUssdNotification.push(malariaCase);
          }
          if (malariaCase["Case Notification"] == null) {
            data.followupsByDistrict[district].missingCaseNotification.push(malariaCase);
            data.followupsByDistrict["ALL"].missingCaseNotification.push(malariaCase);
          }
          if (((_ref1 = malariaCase["Household"]) != null ? _ref1.complete : void 0) === "true") {
            data.passiveCasesByDistrict[district].indexCases.push(malariaCase);
            data.passiveCasesByDistrict["ALL"].indexCases.push(malariaCase);
            if (malariaCase["Household Members"] != null) {
              completedHouseholdMembers = _.where(malariaCase["Household Members"], {
                complete: "true"
              });
              data.passiveCasesByDistrict[district].householdMembers = data.passiveCasesByDistrict[district].householdMembers.concat(completedHouseholdMembers);
              data.passiveCasesByDistrict["ALL"].householdMembers = data.passiveCasesByDistrict["ALL"].householdMembers.concat(completedHouseholdMembers);
            }
            positiveCasesAtHousehold = malariaCase.positiveCasesAtHousehold();
            data.passiveCasesByDistrict[district].passiveCases = data.passiveCasesByDistrict[district].passiveCases.concat(positiveCasesAtHousehold);
            data.passiveCasesByDistrict["ALL"].passiveCases = data.passiveCasesByDistrict["ALL"].passiveCases.concat(positiveCasesAtHousehold);
            return _.each(malariaCase.positiveCasesIncludingIndex(), function(positiveCase) {
              var age;

              data.totalPositiveCasesByDistrict[district].push(positiveCase);
              data.totalPositiveCasesByDistrict["ALL"].push(positiveCase);
              if (positiveCase.Age != null) {
                age = parseInt(positiveCase.Age);
                if (age < 5) {
                  data.agesByDistrict[district].underFive.push(positiveCase);
                  data.agesByDistrict["ALL"].underFive.push(positiveCase);
                } else if (age < 15) {
                  data.agesByDistrict[district].fiveToFifteen.push(positiveCase);
                  data.agesByDistrict["ALL"].fiveToFifteen.push(positiveCase);
                } else if (age < 25) {
                  data.agesByDistrict[district].fifteenToTwentyFive.push(positiveCase);
                  data.agesByDistrict["ALL"].fifteenToTwentyFive.push(positiveCase);
                } else if (age >= 25) {
                  data.agesByDistrict[district].overTwentyFive.push(positiveCase);
                  data.agesByDistrict["ALL"].overTwentyFive.push(positiveCase);
                }
              } else {
                if (!positiveCase.age) {
                  data.agesByDistrict[district].unknown.push(positiveCase);
                }
                if (!positiveCase.age) {
                  data.agesByDistrict["ALL"].unknown.push(positiveCase);
                }
              }
              if (positiveCase.Sex === "Male") {
                data.genderByDistrict[district].male.push(positiveCase);
                data.genderByDistrict["ALL"].male.push(positiveCase);
              } else if (positiveCase.Sex === "Female") {
                data.genderByDistrict[district].female.push(positiveCase);
                data.genderByDistrict["ALL"].female.push(positiveCase);
              } else {
                data.genderByDistrict[district].unknown.push(positiveCase);
                data.genderByDistrict["ALL"].unknown.push(positiveCase);
              }
              if (positiveCase.SleptunderLLINlastnight === "Yes" || positiveCase.IndexcaseSleptunderLLINlastnight === "Yes") {
                data.netsAndIRSByDistrict[district].sleptUnderNet.push(positiveCase);
                data.netsAndIRSByDistrict["ALL"].sleptUnderNet.push(positiveCase);
              }
              if (positiveCase.LastdateofIRS && positiveCase.LastdateofIRS.match(/\d\d\d\d-\d\d-\d\d/)) {
                if ((new moment).subtract('months', Coconut.IRSThresholdInMonths) < (new moment(positiveCase.LastdateofIRS))) {
                  data.netsAndIRSByDistrict[district].recentIRS.push(positiveCase);
                  data.netsAndIRSByDistrict["ALL"].recentIRS.push(positiveCase);
                }
              }
              if (positiveCase.TravelledOvernightinpastmonth === "Yes" || positiveCase.OvernightTravelinpastmonth === "Yes") {
                data.travelByDistrict[district].travelReported.push(positiveCase);
                return data.travelByDistrict["ALL"].travelReported.push(positiveCase);
              }
            });
          }
        });
        return callback(data);
      }
    });
  };

  return Reports;

})();

/*
//@ sourceMappingURL=Reports.map
*/
