// Generated by CoffeeScript 1.3.1
var SyncView,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

SyncView = (function(_super) {

  __extends(SyncView, _super);

  SyncView.name = 'SyncView';

  function SyncView() {
    this.render = __bind(this.render, this);
    return SyncView.__super__.constructor.apply(this, arguments);
  }

  SyncView.prototype.initialize = function() {
    return this.sync = new Sync();
  };

  SyncView.prototype.el = '#content';

  SyncView.prototype.render = function() {
    var _this = this;
    return this.sync.fetch({
      success: function() {
        return _this.$el.html("          <h2>Cloud Server: " + (_this.sync.target()) + "</h2>          <a href='#sync/send'>Send data</a> (last done: " + (_this.sync.last_time("send")) + ")          <a href='#sync/get'>Get data</a> (last done: " + (_this.sync.last_time("get")) + ")          ");
      },
      error: function() {
        _this.sync.save();
        return _.delay(_this.render, 1000);
      }
    });
  };

  return SyncView;

})(Backbone.View);
