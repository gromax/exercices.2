import { MnObject } from 'backbone.marionette'
import { ShowClasseView } from 'apps/classes/show/show_classe_view.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: 'entities',

  show: (id)->
    app.trigger "loading:up"
    channel = @getChannel()
    require 'entities/dataManager.coffee'
    fetchingClasse = channel.request("classe:entity", id)
    $.when(fetchingClasse).done( (item)->
      if item isnt undefined
        app.Ariane.add({ text:item.get("nom"), e:"classe:show", data:id, link:"classe:#{id}"})
        view = new ShowClasseView {
          model: item
        }
        view.on "classe:edit", (item) ->
          app.trigger("classe:edit", item.get("id"))
        app.regions.getRegion('main').show(view)
      else
        app.trigger "not:found"
    ).fail( (response)->
      app.trigger "data:fetch:fail", response
    ).always( ->
      app.trigger "loading:down"
    )
}

export controller = new Controller()
