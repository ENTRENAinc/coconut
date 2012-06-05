// Generated by CoffeeScript 1.3.1
var CaseView,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

CaseView = (function(_super) {

  __extends(CaseView, _super);

  CaseView.name = 'CaseView';

  function CaseView() {
    this.render = __bind(this.render, this);
    return CaseView.__super__.constructor.apply(this, arguments);
  }

  CaseView.prototype.el = '#content';

  CaseView.prototype.render = function() {
    return this.$el.html("      <h1>Case ID: " + (this["case"].MalariaCaseID()) + "</h1>      <h2>Last Modified: " + (this["case"].LastModifiedAt()) + "</h2>      <h2>Questions: " + (this["case"].Questions()) + "</h2>      <pre>      " + (JSON.stringify(this["case"].toJSON(), null, 4)) + "      </pre>    ");
  };

  return CaseView;

})(Backbone.View);
