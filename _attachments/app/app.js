// Generated by CoffeeScript 1.6.2
var Coconut, Router, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Router = (function(_super) {
  __extends(Router, _super);

  function Router() {
    _ref = Router.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  Router.prototype.routes = {
    "login": "login",
    "logout": "logout",
    "design": "design",
    "select": "select",
    "show/results/:question_id": "showResults",
    "new/result/:question_id": "newResult",
    "edit/result/:result_id": "editResult",
    "delete/result/:result_id": "deleteResult",
    "delete/result/:result_id/:confirmed": "deleteResult",
    "edit/resultSummary/:question_id": "editResultSummary",
    "analyze/:form_id": "analyze",
    "delete/:question_id": "deleteQuestion",
    "edit/hierarchy": "editHierarchy",
    "edit/:question_id": "editQuestion",
    "manage": "manage",
    "sync": "sync",
    "sync/send": "syncSend",
    "sync/get": "syncGet",
    "configure": "configure",
    "map": "map",
    "reports": "reports",
    "reports/*options": "reports",
    "alerts": "alerts",
    "show/case/:caseID": "showCase",
    "show/case/:caseID/:docID": "showCase",
    "users": "users",
    "messaging": "messaging",
    "help": "help",
    "clean": "clean",
    "clean/:applyTarget": "clean",
    "csv/:question/startDate/:startDate/endDate/:endDate": "csv",
    "": "default"
  };

  Router.prototype.route = function(route, name, callback) {
    var _this = this;

    Backbone.history || (Backbone.history = new Backbone.History);
    if (!_.isRegExp(route)) {
      route = this._routeToRegExp(route);
    }
    return Backbone.history.route(route, function(fragment) {
      var args;

      args = _this._extractParameters(route, fragment);
      callback.apply(_this, args);
      $('#loading').slideDown();
      _this.trigger.apply(_this, ['route:' + name].concat(args));
      return $('#loading').fadeOut();
    }, this);
  };

  Router.prototype.userLoggedIn = function(callback) {
    return User.isAuthenticated({
      success: function(user) {
        return callback.success(user);
      },
      error: function() {
        Coconut.loginView.callback = callback;
        return Coconut.loginView.render();
      }
    });
  };

  Router.prototype.csv = function(question, startDate, endDate) {
    return this.userLoggedIn({
      success: function() {
        var csvView;

        if (User.currentUser.hasRole("reports")) {
          csvView = new CsvView;
          csvView.question = question;
          csvView.startDate = endDate;
          csvView.endDate = startDate;
          return csvView.render();
        }
      }
    });
  };

  Router.prototype.editHierarchy = function() {
    return this.adminLoggedIn({
      success: function() {
        Coconut.wardHierarchyView = new WardHierarchyView();
        return Coconut.wardHierarchyView.render();
      },
      error: function() {
        return alert("" + User.currentUser + " is not anadmin");
      }
    });
  };

  Router.prototype.clean = function(applyTarget) {
    return this.userLoggedIn({
      success: function() {
        var _ref1;

        if ((_ref1 = Coconut.cleanView) == null) {
          Coconut.cleanView = new CleanView();
        }
        return Coconut.cleanView.render(applyTarget);
      }
    });
  };

  Router.prototype.help = function() {
    return this.userLoggedIn({
      success: function() {
        var _ref1;

        if ((_ref1 = Coconut.helpView) == null) {
          Coconut.helpView = new HelpView();
        }
        return Coconut.helpView.render();
      }
    });
  };

  Router.prototype.users = function() {
    return this.adminLoggedIn({
      success: function() {
        var _ref1;

        if ((_ref1 = Coconut.usersView) == null) {
          Coconut.usersView = new UsersView();
        }
        return Coconut.usersView.render();
      }
    });
  };

  Router.prototype.messaging = function() {
    return this.adminLoggedIn({
      success: function() {
        var _ref1;

        if ((_ref1 = Coconut.messagingView) == null) {
          Coconut.messagingView = new MessagingView();
        }
        return Coconut.messagingView.render();
      }
    });
  };

  Router.prototype.login = function() {
    Coconut.loginView.callback = {
      success: function() {
        return Coconut.router.navigate("", true);
      }
    };
    return Coconut.loginView.render();
  };

  Router.prototype.userWithRoleLoggedIn = function(role, callback) {
    return this.userLoggedIn({
      success: function(user) {
        if (user.hasRole(role)) {
          return callback.success(user);
        } else {
          return $("#content").html("<h2>User '" + (user.username()) + "' must have role: '" + role + "'</h2>");
        }
      },
      error: function() {
        return $("#content").html("<h2>User '" + (user.username()) + "' must have role: '" + role + "'</h2>");
      }
    });
  };

  Router.prototype.adminLoggedIn = function(callback) {
    return this.userLoggedIn({
      success: function(user) {
        if (user.isAdmin()) {
          return callback.success(user);
        }
      },
      error: function() {
        return $("#content").html("<h2>Must be an admin user</h2>");
      }
    });
  };

  Router.prototype.logout = function() {
    User.logout();
    Coconut.router.navigate("", true);
    return document.location.reload();
  };

  Router.prototype["default"] = function() {
    return this.userLoggedIn({
      success: function() {
        if (User.currentUser.hasRole("reports")) {
          Coconut.router.navigate("reports", true);
        }
        return $("#content").html("");
      }
    });
  };

  Router.prototype.reports = function(options) {
    var showReports,
      _this = this;

    showReports = function() {
      var reportViewOptions, _ref1;

      options = options != null ? options.split(/\//) : void 0;
      reportViewOptions = {};
      _.each(options, function(option, index) {
        if (!(index % 2)) {
          return reportViewOptions[option] = options[index + 1];
        }
      });
      if ((_ref1 = Coconut.reportView) == null) {
        Coconut.reportView = new ReportView();
      }
      return Coconut.reportView.render(reportViewOptions);
    };
    if (document.location.hash === "#reports/reportType/periodSummary/alertEmail/true") {
      return showReports();
    } else {
      return this.userWithRoleLoggedIn("reports", {
        success: function() {
          return showReports();
        }
      });
    }
  };

  Router.prototype.showCase = function(caseID, docID) {
    return this.userLoggedIn({
      success: function() {
        var _ref1;

        if ((_ref1 = Coconut.caseView) == null) {
          Coconut.caseView = new CaseView();
        }
        Coconut.caseView["case"] = new Case({
          caseID: caseID
        });
        return Coconut.caseView["case"].fetch({
          success: function() {
            return Coconut.caseView.render(docID);
          }
        });
      }
    });
  };

  Router.prototype.configure = function() {
    return this.userLoggedIn({
      success: function() {
        var _ref1;

        if ((_ref1 = Coconut.localConfigView) == null) {
          Coconut.localConfigView = new LocalConfigView();
        }
        return Coconut.localConfigView.render();
      }
    });
  };

  Router.prototype.editResultSummary = function(question_id) {
    return this.userLoggedIn({
      success: function() {
        var _ref1;

        if ((_ref1 = Coconut.resultSummaryEditor) == null) {
          Coconut.resultSummaryEditor = new ResultSummaryEditorView();
        }
        Coconut.resultSummaryEditor.question = new Question({
          id: unescape(question_id)
        });
        return Coconut.resultSummaryEditor.question.fetch({
          success: function() {
            return Coconut.resultSummaryEditor.render();
          }
        });
      }
    });
  };

  Router.prototype.editQuestion = function(question_id) {
    return this.userLoggedIn({
      success: function() {
        var _ref1;

        if ((_ref1 = Coconut.designView) == null) {
          Coconut.designView = new DesignView();
        }
        Coconut.designView.render();
        return Coconut.designView.loadQuestion(unescape(question_id));
      }
    });
  };

  Router.prototype.deleteQuestion = function(question_id) {
    return this.userLoggedIn({
      success: function() {
        return Coconut.questions.get(unescape(question_id)).destroy({
          success: function() {
            Coconut.menuView.render();
            return Coconut.router.navigate("manage", true);
          }
        });
      }
    });
  };

  Router.prototype.sync = function(action) {
    return this.userLoggedIn({
      success: function() {
        var _ref1;

        if ((_ref1 = Coconut.syncView) == null) {
          Coconut.syncView = new SyncView();
        }
        return Coconut.syncView.render();
      }
    });
  };

  Router.prototype.syncSend = function(action) {
    Coconut.router.navigate("", false);
    return this.userLoggedIn({
      success: function() {
        var _ref1;

        if ((_ref1 = Coconut.syncView) == null) {
          Coconut.syncView = new SyncView();
        }
        Coconut.syncView.render();
        return Coconut.syncView.sync.sendToCloud({
          success: function() {
            return Coconut.syncView.update();
          },
          error: function() {
            return Coconut.syncView.update();
          }
        });
      }
    });
  };

  Router.prototype.syncGet = function(action) {
    Coconut.router.navigate("", false);
    return this.userLoggedIn({
      success: function() {
        var _ref1;

        if ((_ref1 = Coconut.syncView) == null) {
          Coconut.syncView = new SyncView();
        }
        Coconut.syncView.render();
        return Coconut.syncView.sync.getFromCloud();
      }
    });
  };

  Router.prototype.manage = function() {
    return this.adminLoggedIn({
      success: function() {
        var _ref1;

        if ((_ref1 = Coconut.manageView) == null) {
          Coconut.manageView = new ManageView();
        }
        return Coconut.manageView.render();
      }
    });
  };

  Router.prototype.newResult = function(question_id) {
    return this.userLoggedIn({
      success: function() {
        var _ref1;

        if ((_ref1 = Coconut.questionView) == null) {
          Coconut.questionView = new QuestionView();
        }
        Coconut.questionView.result = new Result({
          question: unescape(question_id)
        });
        Coconut.questionView.model = new Question({
          id: unescape(question_id)
        });
        return Coconut.questionView.model.fetch({
          success: function() {
            return Coconut.questionView.render();
          }
        });
      }
    });
  };

  Router.prototype.editResult = function(result_id) {
    return this.userLoggedIn({
      success: function() {
        var _ref1;

        if ((_ref1 = Coconut.questionView) == null) {
          Coconut.questionView = new QuestionView();
        }
        Coconut.questionView.readonly = false;
        Coconut.questionView.result = new Result({
          _id: result_id
        });
        return Coconut.questionView.result.fetch({
          success: function() {
            Coconut.questionView.model = new Question({
              id: Coconut.questionView.result.question()
            });
            return Coconut.questionView.model.fetch({
              success: function() {
                return Coconut.questionView.render();
              }
            });
          }
        });
      }
    });
  };

  Router.prototype.deleteResult = function(result_id, confirmed) {
    return this.userLoggedIn({
      success: function() {
        var _ref1;

        if ((_ref1 = Coconut.questionView) == null) {
          Coconut.questionView = new QuestionView();
        }
        Coconut.questionView.readonly = true;
        Coconut.questionView.result = new Result({
          _id: result_id
        });
        return Coconut.questionView.result.fetch({
          success: function() {
            if (confirmed === "confirmed") {
              return Coconut.questionView.result.destroy({
                success: function() {
                  Coconut.menuView.update();
                  return Coconut.router.navigate("show/results/" + (escape(Coconut.questionView.result.question())), true);
                }
              });
            } else {
              Coconut.questionView.model = new Question({
                id: Coconut.questionView.result.question()
              });
              return Coconut.questionView.model.fetch({
                success: function() {
                  Coconut.questionView.render();
                  $("#content").prepend("                    <h2>Are you sure you want to delete this result?</h2>                    <div id='confirm'>                      <a href='#delete/result/" + result_id + "/confirmed'>Yes</a>                      <a href='#show/results/" + (escape(Coconut.questionView.result.question())) + "'>Cancel</a>                    </div>                  ");
                  $("#confirm a").button();
                  $("#content form").css({
                    "background-color": "#333",
                    "margin": "50px",
                    "padding": "10px"
                  });
                  return $("#content form label").css({
                    "color": "white"
                  });
                }
              });
            }
          }
        });
      }
    });
  };

  Router.prototype.design = function() {
    return this.userLoggedIn({
      success: function() {
        var _ref1;

        $("#content").empty();
        if ((_ref1 = Coconut.designView) == null) {
          Coconut.designView = new DesignView();
        }
        return Coconut.designView.render();
      }
    });
  };

  Router.prototype.showResults = function(question_id) {
    return this.userLoggedIn({
      success: function() {
        var _ref1;

        if ((_ref1 = Coconut.resultsView) == null) {
          Coconut.resultsView = new ResultsView();
        }
        Coconut.resultsView.question = new Question({
          id: unescape(question_id)
        });
        return Coconut.resultsView.question.fetch({
          success: function() {
            return Coconut.resultsView.render();
          }
        });
      }
    });
  };

  Router.prototype.map = function() {
    return this.userLoggedIn({
      success: function() {
        var _ref1;

        if ((_ref1 = Coconut.mapView) == null) {
          Coconut.mapView = new MapView();
        }
        return Coconut.mapView.render();
      }
    });
  };

  Router.prototype.startApp = function() {
    Coconut.config = new Config();
    return Coconut.config.fetch({
      success: function() {
        var onOffline, onOnline, wardHierarchy;

        if (Coconut.config.local.get("mode") === "cloud") {
          $("body").append("            <link href='js-libraries/Leaflet/leaflet.css' type='text/css' rel='stylesheet' />            <script type='text/javascript' src='js-libraries/Leaflet/leaflet.js'></script>            <script src='js-libraries/Leaflet/leaflet.markercluster-src.js'></script>            <script src='js-libraries/Leaflet/leaflet-plugins/layer/tile/Bing.js'></script>            <script src='js-libraries/Leaflet/leaflet-plugins/layer/tile/Google.js'></script>            <style>              .leaflet-map-pane {                    z-index: 2 !important;              }              .leaflet-google-layer {                    z-index: 1 !important;              }            </style>          ");
        }
        $("#footer-menu").html("          <center>          <span style='font-size:75%;display:inline-block'>            <span id='district'></span><br/>            <span id='user'></span>          </span>          <a href='#login'>Login</a>          <a href='#logout'>Logout</a>          " + (Coconut.config.local.get("mode") === "cloud" ? "<a id='reports-button' href='#reports'>Reports</a>" : (onOffline = function(event) {
          return alert("offline");
        }, onOnline = function(event) {
          return alert("online");
        }, document.addEventListener("offline", onOffline, false), document.addEventListener("online", onOnline, false), "              <a href='#sync/send'>Send data (last success: <span class='sync-sent-status'></span>)</a>              <a href='#sync/get'>Get data (last success: <span class='sync-get-status'></span>)</a>            ")) + "          &nbsp;          <a id='manage-button' style='display:none' href='#manage'>Manage</a>          &nbsp;          <a href='#help'>Help</a>          <span style='font-size:75%;display:inline-block'>Version<br/><span id='version'></span></span>          </center>        ");
        $("[data-role=footer]").navbar();
        $('#application-title').html(Coconut.config.title());
        Coconut.loginView = new LoginView();
        Coconut.questions = new QuestionCollection();
        Coconut.questionView = new QuestionView();
        Coconut.menuView = new MenuView();
        Coconut.syncView = new SyncView();
        Coconut.menuView.render();
        Coconut.syncView.update();
        wardHierarchy = new WardHierarchy();
        return wardHierarchy.fetch({
          success: function() {
            WardHierarchy.hierarchy = wardHierarchy.get("hierarchy");
            return Backbone.history.start();
          },
          error: function(error) {
            return console.error("Error loading Ward Hierarchy: " + error);
          }
        });
      },
      error: function() {
        var _ref1;

        if ((_ref1 = Coconut.localConfigView) == null) {
          Coconut.localConfigView = new LocalConfigView();
        }
        return Coconut.localConfigView.render();
      }
    });
  };

  return Router;

})(Backbone.Router);

Coconut = {};

Coconut.router = new Router();

Coconut.router.startApp();

Coconut.debug = function(string) {
  console.log(string);
  return $("#log").append(string + "<br/>");
};

Coconut.identifyingAttributes = ["Name", "name", "FirstName", "MiddleName", "LastName", "ContactMobilepatientrelative", "HeadofHouseholdName", "ShehaMjumbe"];

Coconut.IRSThresholdInMonths = 6;

/*
//@ sourceMappingURL=app.map
*/
