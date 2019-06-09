Item = Backbone.Model.extend {
  urlRoot: "api/classes"
  defaults: {
    nomOwner: ""
    idOwner:""
    nom: ""
    description: ""
    ouverte: false
    pwd:""
  }
  parse: (data) ->
    if typeof data.ouverte is "string"
      data.ouverte = (Number(data.ouverte)==1)
    data.idOwner = Number data.idOwner
    return data
  fill: (liste) ->
    console.log(liste)
    promise = $.ajax( "api/classe/#{@get('id')}/fill", {
      data:  { liste:liste }
      dataType: "json"
      method: "POST"
    })
    return promise;
  validate: (attrs, options) ->
    errors = {}
    if not attrs.nom
      errors.nom = "Ne doit pas être vide"
    else
      if attrs.nom.length < 2
        errors.nom = "Trop court"
    if not _.isEmpty(errors)
      return errors
}

Collection = Backbone.Collection.extend {
  url: "api/classes"
  model: Item
  comparator: "nom"
}

export { Collection, Item }
