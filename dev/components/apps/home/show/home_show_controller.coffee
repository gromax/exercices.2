import { MnObject } from 'backbone.marionette'
import { OffPanel, AdminProfPanel, EleveListeDevoirs, EleveLayout, UnfinishedsView, NotFoundView, ForgottenKeyView } from 'apps/home/show/home_views.coffee'
import { AlertView } from 'apps/common/common_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: "entities"
  notFound: ->
    view = new NotFoundView()
    app.regions.getRegion('main').show(view)
  showAdminHome: ->
    view = new AdminProfPanel({adminMode:true})
    app.regions.getRegion('main').show(view)
  showProfHome: ->
    view = new AdminProfPanel({adminMode:false})
    app.regions.getRegion('main').show(view)
  showOffHome: ->
    view = new OffPanel()
    app.regions.getRegion('main').show(view)
  showEleveHome: ->
    app.trigger("header:loading", true)
    layout = new EleveLayout()
    channel = @getChannel()
    require('entities/dataManager.coffee')
    fetchingData = channel.request("custom:entities", ["userfiches", "exofiches", "faits"])
    $.when(fetchingData).done( (userfiches, exofiches, faits) ->
      listEleveView = new EleveListeDevoirs {
        collection: userfiches
        exofiches: exofiches
        faits: faits
      }
      listEleveView.on "item:devoir:show", (childView) ->
        model = childView.model
        app.trigger("devoir:show", model.get("id"))
      unfinishedMessageView = null
      listeUnfinished = _.filter(
        faits.where({ finished: false }),
        (item) ->
          uf = userfiches.get(item.get("aUF"))
          if uf.get("actif") and uf.get("ficheActive")
            return true
          return false
      )
      n = listeUnfinished.length
      if n>0
        # Il existe des exerices non terminés, on affiche la vue correspondante
        unfinishedMessageView = new UnfinishedsView { number:n }
        unfinishedMessageView.on "unfinished:show", () ->
          app.trigger "faits:unfinished"
        layout.on "render", ()->
          layout.getRegion('devoirsRegion').show(listEleveView)
          if unfinishedMessageView
            layout.getRegion('unfinishedRegion').show(unfinishedMessageView)
        app.regions.getRegion('main').show(layout)
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

  showLogOnForgottenKey: (success) ->
    if success
      view = new ForgottenKeyView()
      view.on "forgotten:reinitMDP:click", () ->
        app.trigger "user:editPwd", null
      app.regions.getRegion('main').show(view)
    else
      view = new AlertView {
        title:"Clé introuvable !"
        message:"L'adresse que vous avez saisie n'est pas valable."
      }
      app.regions.getRegion('main').show(view)

  casloginfailed:  ->
    view = new AlertView {
      title:"Échec de l'authentification !"
      message:"L'authentification par l'ENT a échoué."
    }
    app.regions.getRegion('main').show(view)
}

export controller = new Controller()

