import { app } from 'app'
import { AlertView, MissingView } from 'apps/common/common_views.coffee'

Router = Backbone.Router.extend {
  routes: {
    '*path': 'notFound'
  }

  showMessageSuccess: (message) ->
    if typeof message is "object"
      message.type = "success"
      view = new AlertView message
    else
      view = new AlertView {
        type: "success"
        message: message
        title: "Succès !"
      }
    app.regions.getRegion('message').show(view)

  showMessageError: (message) ->
    view = new AlertView {
      message: message
    }
    app.regions.getRegion('message').show(view)

  notFound: ->
    view = new AlertView {
      message: "Page introuvable"
      dismiss: false
    }
    app.regions.getRegion('main').show(view)

  dataFetchFail: (response, errorCode) ->
    switch response.status
      when 401
        alert("Vous devez vous (re)connecter !")
        app.trigger("home:logout")
      when 404
        view = new MissingView()
        app.regions.getRegion('message').show(view)
      else
        if errorCode
          message = "Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/#{errorCode}]"
        else
          message = "Essayez à nouveau ou prévenez l'administrateur [code #{response.status}]"
        view = new AlertView {
          message: message
          title: "Erreur inconnue"
        }
        app.regions.getRegion('message').show(view)
}

router = new Router()

app.on "show:message:success", (message)->
  router.showMessageSuccess(message)

app.on "show:message:error", (message) ->
  router.showMessageError(message)

app.on "data:fetch:fail", (response, errorCode) ->
  router.dataFetchFail response

app.on "not:found", ->
  router.notFound()


