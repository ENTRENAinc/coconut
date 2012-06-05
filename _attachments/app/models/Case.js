// Generated by CoffeeScript 1.3.1
var Case,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Case = (function() {

  Case.name = 'Case';

  function Case(options) {
    this.toJSON = __bind(this.toJSON, this);
    this.caseID = options != null ? options.caseID : void 0;
    if (options != null ? options.results : void 0) {
      this.loadFromResultArray(options.results);
    }
  }

  Case.prototype.loadFromResultArray = function(results) {
    var _this = this;
    this.caseResults = results;
    this.questions = [];
    this["Household Members"] = [];
    this.caseID = results[0].get("MalariaCaseID");
    return _.each(results, function(result) {
      if (_this.caseID === !result.get("MalariaCaseID")) {
        throw new Exception("Inconsistent Case ID");
      }
      _this.questions.push(result.get("question"));
      if (result.get("question") === "Household Members") {
        return _this["Household Members"].push(result.toJSON());
      } else {
        return _this[result.get("question")] = result.toJSON();
      }
    });
  };

  Case.prototype.fetch = function(options) {
    var _this = this;
    if (Coconut.ResultCollection == null) {
      Coconut.ResultCollection = new ResultCollection();
    }
    return Coconut.ResultCollection.fetch({
      success: function() {
        _this.loadFromResultArray(Coconut.ResultCollection.where({
          MalariaCaseID: _this.caseID
        }));
        return options.success();
      }
    });
  };

  Case.prototype.toJSON = function() {
    var returnVal,
      _this = this;
    returnVal = {};
    _.each(this.questions, function(question) {
      return returnVal[question] = _this[question];
    });
    return returnVal;
  };

  Case.prototype.flatten = function() {
    var returnVal;
    returnVal = {};
    _.each(this.toJSON(), function(object, type) {
      return _.each(object, function(value, field) {
        if (_.isObject(value)) {
          return _.each(value, function(arrayValue, arrayField) {
            return returnVal["" + type + "-" + field + ": " + arrayField] = arrayValue;
          });
        } else {
          return returnVal["" + type + ":" + field] = value;
        }
      });
    });
    return returnVal;
  };

  Case.prototype.LastModifiedAt = function() {
    return _.chain(this.toJSON()).map(function(question) {
      return question.lastModifiedAt;
    }).max(function(lastModifiedAt) {
      return lastModifiedAt != null ? lastModifiedAt.replace(/[- :]/g, "") : void 0;
    }).value();
  };

  Case.prototype.Questions = function() {
    return _.keys(this.toJSON()).join(", ");
  };

  Case.prototype.MalariaCaseID = function() {
    return this.caseID;
  };

  Case.prototype.region = function() {
    return WardHierarchy.region(this.questions["Case Notification"]["FacilityName"]);
  };

  return Case;

})();
