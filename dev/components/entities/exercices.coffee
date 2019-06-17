import Radio from "backbone.radio"
import Catalog from "entities/exercices_catalog.coffee"

Item = Backbone.Model.extend {
  defaults: {
    title: "Titre de l'exercice",
    description: "Description de l'exercice"
    keywords: ""
    options: {}
  }
}

Collection = Backbone.Collection.extend {
  model: Item
}

API =
  getEntities: ->
    new Collection( require("entities/exercices_catalog.coffee").catalog.all() )

channel = Radio.channel 'entities'
channel.reply 'exercices:entities', API.getEntities


export { Item, Collection }
