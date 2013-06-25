// Generated by CoffeeScript 1.6.2
var CsvView, _ref,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

CsvView = (function(_super) {
  __extends(CsvView, _super);

  function CsvView() {
    this.render = __bind(this.render, this);    _ref = CsvView.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  CsvView.prototype.el = '#content';

  CsvView.prototype.viewQuery = function(options) {
    var results;

    results = new ResultCollection();
    return results.fetch({
      question: this.question,
      isComplete: true,
      include_docs: true,
      startTime: this.startDate,
      endTime: this.endDate,
      success: function() {
        results.fields = {};
        results.each(function(result) {
          return _.each(_.keys(result.attributes), function(key) {
            if (!_.contains(["_id", "_rev", "question"], key)) {
              return results.fields[key] = true;
            }
          });
        });
        results.fields = _.keys(results.fields);
        return options.success(results);
      }
    });
  };

  CsvView.prototype.render = function() {
    var _this = this;

    this.$el.html("Compiling CSV file.");
    return this.viewQuery({
      success: function(results) {
        var csvData;

        csvData = results.map(function(result) {
          return _.map(results.fields, function(field) {
            var value;

            value = result.get(field);
            if (value != null ? value.indexOf("\"") : void 0) {
              return "\"" + (value.replace(/"/, "\"\"")) + "\"";
            } else if (value != null ? value.indexOf(",") : void 0) {
              return "\"" + value + "\"";
            } else {
              return value;
            }
          }).join(",");
        }).join("\n");
        _this.$el.html("          <a id='csv' href='data:text/octet-stream;base64," + (Base64.encode(results.fields.join(",") + "\n" + csvData)) + "' download='" + _this.question + "-" + _this.startDate + "-" + _this.endDate + ".csv'>Download spreadsheet</a>        ");
        return $("a#csv").button();
      }
    });
  };

  return CsvView;

})(Backbone.View);

/*
//@ sourceMappingURL=CsvView.map
*/
