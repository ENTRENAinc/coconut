// Generated by CoffeeScript 1.6.3
var AttendanceListView, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

AttendanceListView = (function(_super) {
  __extends(AttendanceListView, _super);

  function AttendanceListView() {
    _ref = AttendanceListView.__super__.constructor.apply(this, arguments);
    return _ref;
  }

  AttendanceListView.prototype.el = "#content";

  AttendanceListView.prototype.events = {
    "keyup #search": "filter"
  };

  AttendanceListView.prototype.initialize = function(options) {
    var key, value;
    for (key in options) {
      value = options[key];
      this[key] = value;
    }
    return Coconut.resultCollection != null ? Coconut.resultCollection : Coconut.resultCollection = new ResultCollection();
  };

  AttendanceListView.prototype.filter = function(event) {
    var foundRow, id, query, row, rows, table, _ref1, _results;
    query = this.$el.find("#search").val();
    table = this.$el.find(".tablesorter");
    rows = $(".tablesorter tr");
    _ref1 = this.searchRows;
    _results = [];
    for (id in _ref1) {
      row = _ref1[id];
      foundRow = this.findTRByClass(rows, id);
      if (foundRow !== null) {
        if (~row.indexOf(query) || query.length < 3) {
          _results.push($(foundRow).show());
        } else {
          _results.push($(foundRow).hide());
        }
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  AttendanceListView.prototype.findTRByClass = function(rows, className) {
    var classNames, id, row;
    for (id in rows) {
      row = rows[id];
      classNames = row.className;
      if (classNames.indexOf(className) > -1) {
        return row;
      }
    }
    return null;
  };

  AttendanceListView.prototype.save = function() {
    var currentData;
    currentData = $('#attendanceForm').toObject({
      skipEmpty: true
    });
    currentData.lastModifiedAt = moment(new Date()).format(Coconut.config.get("datetime_format"));
    currentData.savedBy = $.cookie('current_user');
    return Coconut.attendanceListView.result.save(currentData, {
      success: function() {
        return $("#content").html("<p align='center' style='font-size:12pt'>        Lista de asistentes se ha guardado.</p>");
      }
    });
  };

  AttendanceListView.prototype.render = function() {
    var birthday, cbChecked, cbHTML, cbValue, html, participant, participantData, participantsSorted, standard_value_table, _i, _len,
      _this = this;
    this.searchRows = {};
    html = "";
    if ("module" === Coconut.config.local.get("mode")) {
      standard_value_table = "      " + (((function() {
        var key, re, value, _ref1, _results;
        _ref1 = this.standard_values;
        _results = [];
        for (key in _ref1) {
          value = _ref1[key];
          re = new RegExp("#", "g");
          value = value.replace(re, "/");
          _results.push("<input type='hidden' name='" + key + "' value='" + value + "'>");
        }
        return _results;
      }).call(this)).join("")) + "      ";
    }
    html += ("" + (standard_value_table || '') + "<div style='font-size: 14pt;font-weight: bold'>") + this.standard_values.activity_name + "</div><br>";
    html += "<div style='font-size: 10pt'><input type='text' id='search' placeholder='filter'></div><br>";
    html += "<div id='attendanceForm' style='overflow:auto;'><table class='tablesorter'>          <thead>            <tr>              <th></th>              <th>Apellido</th>              <th>Nombre</th>              <th>Sexo</th>              <th>Fecha de <br/>Nacimiento</th>              <th>Barrio o Sector</th>              <th>Teléfono</th>              <th>Correo Electrónico</th>            </tr></thead>        <tbody>";
    participantsSorted = caseInsensitiveSortJSONData(this.wsData.participants.rows, "Apellido", true);
    for (_i = 0, _len = participantsSorted.length; _i < _len; _i++) {
      participant = participantsSorted[_i];
      participantData = participant.value;
      html += "<tr class='row-" + participantData.uuid + "'>";
      this.searchRows[participantData.uuid] = "";
      cbChecked = "";
      cbValue = this.result.safeGet(participantData.uuid, '');
      if (cbValue === 'true') {
        cbChecked = " checked='checked' ";
      }
      cbHTML = "<input name='" + participantData.uuid + "' id='" + participantData.uuid + "' type='checkbox' value='true' " + cbChecked + "></input>";
      html += "<td>" + cbHTML + "</td>";
      html += this.createColumn(participantData.Apellido, participantData.uuid, true);
      html += this.createColumn(participantData.Nombre, participantData.uuid, true);
      html += this.createColumn(participantData.Sexo, participantData.uuid, false);
      birthday = participantData.Día + "/" + participantData.Mes + "/" + participantData.Año;
      html += this.createColumn(birthday, participantData.uuid, false);
      html += this.createColumn(participantData.BarrioComunidad, participantData.uuid, false);
      html += this.createColumn(participantData.Teléfono, participantData.uuid, false);
      html += this.createColumn(participantData.Direccióndecorreoelectrónico, participantData.uuid, false);
      html += "</tr>";
    }
    "</tbody></table></div>";
    html += "<button id='completeButton' name='completeButton' type='button'>Guardar</button>";
    this.$el.html(html);
    $('table tr').each(function(index, row) {
      if (index % 2 === 1) {
        return $(row).addClass("odd");
      }
    });
    $('#completeButton').click(this.save);
  };

  AttendanceListView.prototype.createColumn = function(value, participantId, searchField) {
    var columnHtml;
    if (value === null || typeof value === "undefined") {
      columnHtml = "<td></td>";
    } else {
      columnHtml = "<td>" + value + "</td>";
      if (searchField === true) {
        this.searchRows[participantId] += value;
      }
    }
    return columnHtml;
  };

  AttendanceListView.prototype.jQueryUIze = function($obj) {
    return $obj.find('input[type=checkbox]').checkboxradio();
  };

  return AttendanceListView;

})(Backbone.View);

/*
//@ sourceMappingURL=AttendanceListView.map
*/