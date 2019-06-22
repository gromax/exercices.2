Item = Backbone.Model.extend {
  urlRoot: "api/assosUF"
  defaults: {
    nomUser: ""
    prenomUser: ""
    idUser: 0
    idFiche: 0
    actif:false
  }

  parse: (data) ->
    if data.id
      data.id = Number data.id
    data.idUser = Number data.idUser
    data.idFiche = Number data.idFiche
    if data.nomUser? then data.nomCompletUser = "#{data.nomUser} #{data.prenomUser}" else data.nomUser = ""
    data.actif = (data.actif is "1") or (data.actif is 1) or (data.actif is true)
    if data.notation
      # notation est transmis pour un chargement élève
      data.notation = Number data.notation
    else
      data.notation = 0
    if data.ficheActive
      data.ficheActive = (data.ficheActive is "1") or (data.ficheActive is 1) or (data.ficheActive is true)
    return data

  toJSON: ->
    _.pick(@attributes, "idUser", "idFiche", "actif")

  getCoeffs: (aEFsCollec) ->
    exercices_coeff={}
    if aEFsCollec
      models = aEFsCollec.models
      exercices_coeff[item.get("id")] = { coeff:item.get("coeff"), num:item.get("num") } for item in models
    exercices_coeff

  calcNote: (aEFs_models_array, notes_json_array, notation) ->
    # notation = système de notation
    unless notation? then notation = @get("notation") # si notation n'est pas fourni, on prend celui donné par le modele
    total = aEFs_models_array.reduce (memo, item) ->
      notes_of_EF = _.where(notes_json_array, { aEF: item.get("id") })
      return item.calcNote(notes_of_EF, notation)*item.get("coeff")+ memo
    , 0

    totalCoeff = aEFs_models_array.reduce (memo,item) ->
      return item.get("coeff") + memo
    , 0
    Math.ceil total/totalCoeff
}

Collection = Backbone.Collection.extend {
  url: "api/assosUF"
  model: Item

  getNumberForEachUser: ->
    _.countBy(@models, (m) ->
      m.get "idUser"
    )

}

export { Item, Collection }
