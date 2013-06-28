// Generated by CoffeeScript 1.6.2
var Sync, _ref,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Sync = (function(_super) {
  __extends(Sync, _super);

  function Sync() {
    this.replicateApplicationDocs = __bind(this.replicateApplicationDocs, this);
    this.replicateDesignDoc = __bind(this.replicateDesignDoc, this);
    this.sendAndGetFromCloud = __bind(this.sendAndGetFromCloud, this);
    this.getFromCloud = __bind(this.getFromCloud, this);
    this.log = __bind(this.log, this);
    this.last_get_time = __bind(this.last_get_time, this);
    this.last_get = __bind(this.last_get, this);
    this.last_send_time = __bind(this.last_send_time, this);
    this.last_send = __bind(this.last_send, this);    _ref = Sync.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  Sync.prototype.initialize = function() {
    return this.set({
      _id: "SyncLog"
    });
  };

  Sync.prototype.url = "/sync";

  Sync.prototype.last_send = function() {
    var _ref1;

    return (_ref1 = this.get("last_send_result")) != null ? _ref1.history[0] : void 0;
  };

  Sync.prototype.last_send_time = function() {
    var result, _ref1;

    result = this.get("last_send_time") || ((_ref1 = this.last_send) != null ? _ref1.start_time : void 0);
    if (result) {
      return moment(result).fromNow();
    } else {
      return "never";
    }
  };

  Sync.prototype.last_get = function() {
    return this.get("last_get_log");
  };

  Sync.prototype.last_get_time = function() {
    var result;

    result = this.get("last_get_time");
    if (result) {
      return moment(this.get("last_get_time")).fromNow();
    } else {
      return "never";
    }
  };

  Sync.prototype.sendToCloud = function(options) {
    var _this = this;

    return this.fetch({
      success: function() {
        var resultCollection;

        _this.log("Sending data to " + (Coconut.config.database_name()));
        switch (Coconut.config.get("sync_mode")) {
          case "couchdb-sync":
            console.log(Coconut.config.cloud_url_with_credentials());
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
          case "http-post":
            resultCollection = new ResultCollection();
            return resultCollection.fetch({
              success: function() {
                var httpPostTarget, notSentResults, saveSyncLog;

                notSentResults = resultCollection.notSent();
                saveSyncLog = _.after(notSentResults.length, function() {
                  return _this.save({
                    last_send_time: new Date()
                  }, Coconut.menuView.update(), $(".sync-sent-status").html("a few seconds ago"));
                });
                httpPostTarget = Coconut.config.local.httpPostTarget();
                return _.each(resultCollection.notSent(), function(result) {
                  return $.ajax({
                    type: "POST",
                    url: httpPostTarget,
                    data: result.toJSON(),
                    success: function() {
                      result.set("sentTo", httpPostTarget);
                      if (Coconut.config.get("completion_mode") === "on-send") {
                        result.set("complete", "true");
                      }
                      result.save();
                      return saveSyncLog();
                    },
                    error: function(error) {
                      return $(".sync-sent-status").html("Error saving to " + httpPostTarget + ": " + (JSON.stringify(error)));
                    }
                  });
                });
              }
            });
        }
      }
    });
  };

  Sync.prototype.log = function(message) {
    Coconut.debug(message);
    $(".sync-get-status").html(message);
    return $("#message").append(message + "<br/>");
  };

  Sync.prototype.getFromCloud = function(options) {
    var _this = this;

    return this.fetch({
      success: function() {
        return $.couch.login({
          name: Coconut.config.get("local_couchdb_admin_username"),
          password: Coconut.config.get("local_couchdb_admin_password"),
          complete: function() {
            _this.log("Updating application design document...");
            return _this.replicateDesignDoc({
              success: function() {
                _this.log("Updating user accounts and question sets...");
                return _this.replicateApplicationDocs({
                  success: function() {
                    _this.log("Finished");
                    _this.save({
                      last_get_time: new Date().getTime()
                    });
                    if (options != null) {
                      if (typeof options.success === "function") {
                        options.success();
                      }
                    }
                    return document.location.reload();
                  },
                  error: function(error) {
                    $.couch.logout();
                    return _this.log("Error updating application: " + error);
                  }
                });
              },
              error: function(error) {
                $.couch.logout();
                return _this.log("Error updating design document");
              }
            });
          },
          error: function(error) {
            return _this.log("Error logging in as local admin: " + error + ", trying to proceed anyway in case we are in admin party");
          }
        });
      }
    });
  };

  Sync.prototype.sendAndGetFromCloud = function(options) {
    var _this = this;

    this.log("Checking for internet. (Is " + (Coconut.config.cloud_url()) + " is reachable?) Please wait.");
    return $.ajax({
      url: Coconut.config.cloud_url(),
      error: function() {
        _this.log("ERROR! " + (Coconut.config.cloud_url()) + " is not reachable. Either the internet is not working or the site is down.");
        options.error();
        return _this.save({
          last_send_error: true
        });
      },
      success: function() {
        _this.log("" + (Coconut.config.cloud_url()) + " is reachable, so internet is available.");
        return _this.sendToCloud({
          success: function() {
            return _this.replicate({
              success: function() {
                _this.log("Sync complete");
                _this.save({
                  last_get_time: new Date().getTime()
                });
                return options != null ? typeof options.success === "function" ? options.success() : void 0 : void 0;
              },
              error: function() {
                _this.log("Sync fail during get");
                return options != null ? typeof options.error === "function" ? options.error() : void 0 : void 0;
              }
            });
          },
          error: function(error) {
            return _this.log("Synchronization fail during send: " + error);
          }
        });
      }
    });
  };

  Sync.prototype.getNewNotifications = function(options) {
    return $.couch.db(Coconut.config.database_name()).view(("" + (Coconut.config.design_doc_name()) + "/rawNotificationsConvertedToCaseNotifications")({
      descending: true,
      include_docs: true,
      limit: 1,
      success: function(result) {
        var healthFacilities, mostRecentNotification, url, _ref1, _ref2;

        mostRecentNotification = (_ref1 = result.rows) != null ? (_ref2 = _ref1[0]) != null ? _ref2.doc.date : void 0 : void 0;
        url = "" + (Coconut.config.cloud_url_with_credentials()) + "/_design/" + (Coconut.config.database_name()) + "/_view/notifications?&ascending=true&include_docs=true&skip=1";
        if (mostRecentNotification) {
          url += "&startkey=\"" + mostRecentNotification + "\"";
        }
        healthFacilities = WardHierarchy.allWards({
          district: User.currentUser.get("district")
        });
        if (User.currentUser.get("district") == null) {
          healthFacilities = [];
        }
        return $.ajax({
          url: url,
          dataType: "jsonp",
          success: function(result) {
            _.each(result.rows, function(row) {
              var notification;

              notification = row.doc;
              if (_.include(healthFacilities, notification.hf)) {
                result = new Result({
                  question: "Case Notification",
                  MalariaCaseID: notification.caseid,
                  FacilityName: notification.hf,
                  Shehia: notification.shehia,
                  Name: notification.name
                });
                result.save();
                notification.hasCaseNotification = true;
                return $.couch.db(Coconut.config.database_name()).saveDoc(notification);
              }
            });
            return typeof options.success === "function" ? options.success() : void 0;
          }
        });
      }
    }));
  };

  Sync.prototype.replicate = function(options) {
    var _this = this;

    this.log("Preparing to receive data");
    return $.couch.login({
      name: Coconut.config.get("local_couchdb_admin_username"),
      password: Coconut.config.get("local_couchdb_admin_password"),
      complete: function() {
        _this.log("Receiving data from " + (Coconut.config.database_name()));
        return $.couch.replicate(Coconut.config.cloud_url_with_credentials(), Coconut.config.database_name(), {
          success: function() {
            _this.save({
              last_get_time: new Date().getTime()
            });
            _this.log("Data received");
            return options.success();
          },
          error: function() {
            _this.log("Error receiving data from " + (Coconut.config.database_name()));
            return options.error();
          }
        }, options.replicationArguments);
      },
      error: function() {
        return console.log("Unable to login as local admin for replicating the design document (main application),  trying to proceed anyway in case we are in admin party.");
      }
    });
  };

  Sync.prototype.replicateDesignDoc = function(options) {
    return this.replicate(_.extend(options, {
      replicationArguments: {
        doc_ids: ["_design/" + Backbone.couch_connector.config.ddoc_name]
      }
    }));
  };

  Sync.prototype.replicateApplicationDocs = function(options) {
    var _this = this;

    return $.couch.db(Coconut.config.database_name()).view("" + (Coconut.config.design_doc_name()) + "/docIDsForUpdating", {
      include_docs: false,
      success: function(result) {
        var doc_ids;

        doc_ids = _.pluck(result.rows, "id");
        doc_ids.push("_design/" + (Coconut.config.design_doc_name()));
        doc_ids.push("coconut.config");
        _this.log("Updating " + doc_ids.length + " docs (users, forms, configuration and the design document). Please wait.");
        return _this.replicate(_.extend(options, {
          replicationArguments: {
            doc_ids: doc_ids
          }
        }));
      }
    });
  };

  return Sync;

})(Backbone.Model);

/*
//@ sourceMappingURL=Sync.map
*/
