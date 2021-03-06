// Generated by CoffeeScript 1.9.2
var AttendanceListView,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

AttendanceListView = (function(superClass) {
  extend(AttendanceListView, superClass);

  function AttendanceListView() {
    return AttendanceListView.__super__.constructor.apply(this, arguments);
  }

  AttendanceListView.prototype.el = "#content";

  AttendanceListView.prototype.initialize = function(options) {
    var key, value;
    for (key in options) {
      value = options[key];
      this[key] = value;
    }
    if (Coconut.resultCollection == null) {
      Coconut.resultCollection = new ResultCollectionWithCollateral();
    }
    return this.$el.append('<div id="reportloader"><marquee ALIGN="Top" LOOP="infinite"  DIRECTION="right" style="font-size:24px; color:#FF8000">Cargando el informe. Por favor espera ...</marquee></div>');
  };

  AttendanceListView.prototype.filter = function(event) {
    var foundRow, id, query, ref, results, row, rows, table;
    query = this.$el.find("#search").val();
    table = this.$el.find(".tablesorter");
    rows = $(".tablesorter tr");
    ref = this.searchRows;
    results = [];
    for (id in ref) {
      row = ref[id];
      foundRow = this.findTRByClass(rows, id);
      if (foundRow !== null) {
        if (~row.indexOf(query) || query.length < 3) {
          results.push($(foundRow).show());
        } else {
          results.push($(foundRow).hide());
        }
      } else {
        results.push(void 0);
      }
    }
    return results;
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
    var currentData, i, initialUUID;
    currentData = $('#attendanceForm').toObject({
      skipEmpty: true
    });
    i = 0;
    while (i < Coconut.attendanceListView.initialCheckedUUIDs.length) {
      initialUUID = Coconut.attendanceListView.initialCheckedUUIDs[i];
      if (!currentData.hasOwnProperty(initialUUID)) {
        currentData[initialUUID] = 'false';
      }
      i++;
    }
    currentData.lastModifiedAt = moment(new Date()).format(Coconut.config.get("datetime_format"));
    currentData.savedBy = $.cookie('current_user');
    return Coconut.attendanceListView.result.save(currentData, {
      success: function() {
        return $("#content").html("<p align='center' style='font-size:12pt'> Lista de asistentes se ha guardado.</p>");
      }
    });
  };

  AttendanceListView.prototype.render = function() {
    var birthday, cbChecked, cbHTML, cbValue, html, j, len, participant, participantData, participantsSorted, sorter, sorting, standard_value_table;
    this.searchRows = {};
    html = "";
    if ("module" === Coconut.config.local.get("mode")) {
      standard_value_table = "      " + (((function() {
        var _ref1, _results, key, re, value;
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
    html += ((standard_value_table || '') + "<div style='font-size: 14pt;font-weight: bold'>") + this.standard_values.activity_name + "</div><br>";
    html += "<div id='attendanceForm' style='overflow:auto;'><table id='participants'> <thead> <tr> <th>Ordenar por Cotejo</th> <th>UUID</th> <th>Fecha de Creación</th> <th>Apellido</th> <th>Nombre</th> <th>Apodo</th> <th>Sexo</th> <th>Fecha de <br/>Nacimiento</th> <th>Barrio o Sector</th> <th>Teléfono</th> <th>Es Colateral</th> <th>Facebook</th> </tr></thead> <tbody>";
    participantsSorted = caseInsensitiveSortJSONData(this.wsData.participants.rows, "Apellido", true);
    Coconut.attendanceListView.initialCheckedUUIDs = [];
    for (j = 0, len = participantsSorted.length; j < len; j++) {
      participant = participantsSorted[j];
      participantData = participant.value;
      html += "<tr class='row-" + participantData.uuid + "'>";
      this.searchRows[participantData.uuid] = "";
      cbChecked = "";
      cbValue = this.result.safeGet(participantData.uuid, '');
      if (cbValue === 'true') {
        Coconut.attendanceListView.initialCheckedUUIDs.push(participantData.uuid);
        cbChecked = " checked='checked' ";
      }
      cbHTML = "<input name='" + participantData.uuid + "' id='" + participantData.uuid + "' type='checkbox' value='true' " + cbChecked + "></input>";
      html += "<td>" + cbHTML + "</td>";
      html += this.createColumn(participantData.uuid, participantData.uuid, true);
      html += this.createColumn(participantData.createdAt, participantData.uuid, true);
      html += this.createColumn(participantData.Apellido, participantData.uuid, true);
      html += this.createColumn(participantData.Nombre, participantData.uuid, true);
      html += this.createColumn(participantData.Apodo, participantData.uuid, true);
      html += this.createColumn(participantData.Sexo, participantData.uuid, false);
      birthday = participantData.Día + "/" + participantData.Mes + "/" + participantData.Año;
      html += this.createColumn(birthday, participantData.uuid, false);
      html += this.createColumn(participantData.BarrioComunidad, participantData.uuid, false);
      html += this.createColumn(participantData.Teléfono, participantData.uuid, false);
      html += this.createColumn(participantData.Estecolateralparticipante, participantData.uuid, false);
      html += this.createColumn(participantData.NombredeusuariodeFacebook, participantData.uuid, false);
      html += "</tr>";
    }
    "</tbody></table></div>";
    html += "<button id='completeButton' name='completeButton' type='button'>Guardar</button>";
    this.$el.html(html);
    $('#participants').dataTable({
      "bPaginate": false,
      "bSort": true,
      "bFilter": false
    });
    $.tablesorter.addParser({
      id: 'checkbox',
      is: function(s, table, cell) {
        var v;
        v = $(cell).find('input[type=checkbox]').length > 0;
        return v;
      },
      format: function(s, table, cell) {
        var v;
        v = $(cell).find('input:checked').length > 0 ? 1 : 0;
        return v;
      },
      type: 'numeric'
    });
    sorting = [[0, 1]];
    $('input[type="checkbox"]').change(function() {
      $('#participants').trigger('update');
    });
    sorter = $('#participants').tablesorter({
      'headers': {
        '0': {
          'sorter': 'checkbox'
        }
      }
    });
    sorter.bind('sortStart', function(sorter) {
      $('#participants').trigger('update');
    });
    $('#participants').trigger('sorton', [sorting]);
    $('#reportloader').hide();
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

//# sourceMappingURL=AttendanceListView.js.map
