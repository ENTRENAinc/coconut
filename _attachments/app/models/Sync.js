// Generated by CoffeeScript 1.3.1
var Sync,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Sync = (function(_super) {

  __extends(Sync, _super);

  Sync.name = 'Sync';

  function Sync() {
    return Sync.__super__.constructor.apply(this, arguments);
  }

  Sync.prototype.initialize = function() {
    return this.set({
      _id: "SyncLog"
    });
  };

  Sync.prototype.url = "/sync";

  Sync.prototype.target = function() {
    return Coconut.config.cloud_url();
  };

  Sync.prototype.last = function(type) {
    var _ref;
    return (_ref = this.get("last_" + type + "_result")) != null ? _ref.history[0] : void 0;
  };

  Sync.prototype.last_time = function(type) {
    var result, _ref;
    result = (_ref = this.last(type)) != null ? _ref.start_time : void 0;
    if (result) {
      return moment(result).fromNow();
    } else {
      return "never";
    }
  };

  Sync.prototype.sendToCloud = function(options) {
    var _this = this;
    return this.fetch({
      success: function() {
        $(".sync-last-time-sent").html("pending");
        return $.couch.replicate(Coconut.config.database_name(), Coconut.config.cloud_url_with_credentials(), {
          success: function(response) {
            _this.save({
              last_send_result: response
            });
            return options.success();
          },
          error: function() {
            return options.error();
          }
        });
      }
    });
  };

  Sync.prototype.getFromCloud = function(options) {
    var _this = this;
    return this.fetch({
      success: function() {
        var _ref;
        if ((_ref = _this.changes) != null) {
          _ref.stop();
        }
        _this.changes = $.couch.db(Coconut.config.database_name()).changes(null, {
          filter: Coconut.config.database_name() + "/casesByFacility",
          healthFacilities: (WardHierarchy.allWards({
            district: Coconut.config.local.get("district")
          })).join(',')
        });
        _this.changes.onChange(function(changes) {
          return _.each(changes.results, function(result) {
            return $.couch.db(Coconut.config.database_name()).openDoc(result.id, {
              success: function(doc) {
                result = new Result({
                  question: "Case Notification",
                  MalariaCaseID: doc.caseid,
                  FacilityName: doc.hf,
                  createdAt: moment(new Date()).format(Coconut.config.get("date_format")),
                  lastModifiedAt: moment(new Date()).format(Coconut.config.get("date_format"))
                });
                return result.save();
              }
            });
          });
        });
        $(".sync-last-time-got").html("pending");
        return $.couch.replicate(Coconut.config.cloud_url_with_credentials(), Coconut.config.database_name(), {
          success: function(response) {
            _this.save({
              last_get_result: response
            });
            return options.success();
          },
          error: function() {
            return options.error();
          }
        }, {
          filter: Coconut.config.database_name() + "/casesByFacility",
          query_params: {
            healthFacilities: (WardHierarchy.allWards({
              district: Coconut.config.local.get("district")
            })).join(',')
          }
        });
      }
    });
  };

  return Sync;

})(Backbone.Model);
