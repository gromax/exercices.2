import { MnObject } from 'backbone.marionette'
import { EditClasseView } from 'apps/classes/edit/edit_classe_view.coffee'
import { AlertView, MissingItemView } from 'apps/common/common_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: "entities"
  edit: (id) ->
    app.trigger("header:loading", true);
    channel = @getChannel()
    require('entities/dataManager.coffee')
    fetchingClasse = channel.request("classe:entity",id)
    $.when(fetchingClasse).done( (item) ->
      if item isnt undefined
        app.Ariane.add([
          { text:item.get("nom"), e:"classe:show", data:id, link:"classe:"+id},
          { text:"Modification", e:"classe:edit", data:id, link:"classe:"+id+"/edit"},
        ])
        view = new EditClasseView {
          model: item
          generateTitle: true
        }

        view.on "form:submit", (data) ->
          updatingItem = item.save(data)
          if updatingItem
            app.trigger("header:loading", true)
            $.when(updatingItem).done( ()->
              app.trigger("classe:show", item.get("id"))
            ).fail( (response) ->
              switch
                when response.status is 422
                  view.triggerMethod("form:data:invalid", response.responseJSON.errors)
                when response.status is 401
                  alert("Vous devez vous (re)connecter !")
                  app.trigger("home:logout")
                else
                  alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code "+response.status+"/001]")
            ).always( ()->
              app.trigger("header:loading", false)
            )
          else
            view.triggerMethod("form:data:invalid", item.validationError)
      else
        view = new MissingView {message:"Cette classe n'existe pas !"}
      app.regions.getRegion('main').show(view)
    ).fail( (response) ->
      if response.status is 401
        alert("Vous devez vous (re)connecter !")
        app.trigger("home:logout")
      else
        alertView = new AlertView()
        app.regions.getRegion('main').show(alertView)
    ).always( () ->
      app.trigger("header:loading", false)
    )
}


export controller = new Controller()
