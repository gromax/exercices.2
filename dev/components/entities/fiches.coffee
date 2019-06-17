Item = Backbone.Model.extend {
  urlRoot: "api/fiches"

  defaults: {
    nomOwner: false
    idOwner: ""
    nom: ""
    description: ""
    visible: false
    actif: false
    notation: 0
    date: "2000-01-01"
  }

  toJSON: ->
    _.pick(this.attributes, 'id', 'idOwner', 'nom', 'description', 'visible', 'actif', 'notation')

  parse: (data) ->
    if data.id then data.id = Number data.id
    data.idOwner = Number data.idOwner
    data.notation = Number data.notation
    data.actif = (data.actif is "1") or (data.actif is 1) or (data.actif is true)
    data.visible = (data.visible is "1") or (data.visible is 1) or (data.visible is true)
    data

  validate: (attrs, options) ->
    errors = {}
    if not attrs.nom
      errors.nom = "Ne doit pas être vide"
    else
      if attrs.nom.length<2
        errors.nom = "Trop court"
    if not _.isEmpty(errors)
      errors
}

Collection = Backbone.Collection.extend {
  url: "api/fiches"
  model: Item
  comparator: "nom"
}


export { Item, Collection }
