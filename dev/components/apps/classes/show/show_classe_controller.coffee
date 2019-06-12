import { MnObject } from 'backbone.marionette'
import { ShowClasseView } from 'apps/classes/show/show_classe_view.coffee'
import { AlertView, MissingItemView } from 'apps/common/common_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: 'entities',

  show: (id)->
    app.trigger("header:loading", true)
    channel = @getChannel()
    require('entities/dataManager.coffee')
    fetchingClasse = channel.request("classe:entity", id)
    $.when(fetchingClasse).done( (item)->
      if item isnt undefined
        app.Ariane.add({ text:item.get("nom"), e:"classe:show", data:id, link:"classe:#{id}"})
        view = new ShowClasseView {
          model: item
        }
        view.on "classe:edit", (item) ->
          app.trigger("classe:edit", item.get("id"))
      else
        view = new MissingItemView( { message: "Cette classe n'existe pas !"})
      app.regions.getRegion('main').show(view)
    ).fail( (response)->
      if response.status is 401
        alert("Vous devez vous (re)connecter !")
        app.trigger("home:logout")
      else
        alertView = new AlertView()
        app.regions.getRegion('main').show(alertView)
    ).always( ->
      app.trigger("header:loading", false)
    )
}

export controller = new Controller()
