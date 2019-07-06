import { MnObject } from 'backbone.marionette'
import { EditClasseView } from 'apps/classes/edit/edit_classe_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: "entities"
  edit: (id) ->
    app.trigger app.trigger "loading:up"
    channel = @getChannel()
    require 'entities/dataManager.coffee'
    fetchingClasse = channel.request("classe:entity",id)
    $.when(fetchingClasse).done( (item) ->
      if item isnt undefined
        app.Ariane.add [
          { text:item.get("nom"), e:"classe:show", data:id, link:"classe:"+id},
          { text:"Modification", e:"classe:edit", data:id, link:"classe:"+id+"/edit"},
        ]
        view = new EditClasseView {
          model: item
          generateTitle: true
          errorCode: "001"
          onSuccess: (model, data)-> app.trigger "classe:show", model.get("id")
        }
        app.regions.getRegion('main').show(view)
      else
        app.trigger "not:found"
    ).fail( (response) ->
      app.trigger "data:fetch:fail", response
    ).always( ->
      app.trigger "loading:down"
    )
}


export controller = new Controller()
