(doc) ->
  val = ""
  val = '"Fecha":"' + doc.Fecha + '"'
  val += ',' + '"Nombre":"' + doc.Nombre + '"'
  val += ',' +'"Apellido":"' + doc.Apellido + '"'
  val += ',' +'"Apodo":"' + doc.Apodo + '"'
  val += ',' +'"Calleynumero":"' + doc.Calleynumero + '"'
  val += ',' +'"Provincia":"' + doc.Provincia + '"'
  val += ',' +'"Municipio":"' + doc.Municipio + '"'
  val += ',' +'"BarrioComunidad":"' + doc.BarrioComunidad + '"'

  emit doc.uuid, "{" + val + "}" if doc.question is "Participant Registration-es" and doc.Completado is "true" and (doc.Estecolateralparticipante is undefined or doc.Estecolateralparticipante isnt "Sí")