import { app } from 'app'

Router = Backbone.Router.extend {
  routes: {
    "" : "showHome"
    "home" : "showHome"
    "login" : "showLogin"
    "logout" : "logout"
    "forgotten::key": "forgotten"
    "casloginfailed": "casloginfailed"
  }
  showHome: ->
    app.Ariane.reset []
    controller = require("apps/home/show/home_show_controller.coffee").controller
    switch
      when app.Auth.isAdmin() then controller.showAdminHome()
      when app.Auth.isProf() then controller.showProfHome()
      when app.Auth.isEleve() then controller.showEleveHome()
      else controller.showOffHome()
  showLogin: ->
    if app.Auth.get("logged_in")
      @showHome()
    else
      app.Ariane.reset [{text:"Connexion", link:"login", e:"home:login"}]
      require("apps/home/login/login_controller.coffee").controller.showLogin()
  showReLogin:(options) ->
    require("apps/home/login/login_controller.coffee").controller.showReLogin()
  logout: ->
    self = @
    if app.Auth.get("logged_in")
      closingSession = app.Auth.destroy()
      $.when(closingSession).done( (response)->
        # En cas d'échec de connexion, l'api server renvoie une erreur
        # Le delete n'occasione pas de raffraichissement des données
        # Il faut donc le faire manuellement
        app.Auth.refresh(response.logged)
        self.showHome()
      ).fail( (response)->
        alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/024]");
      )
  forgotten: (key)->
    if app.Auth.get("logged_in")
      app.trigger("notFound")
    else
      app.Ariane.reset [{text:"Réinitialisation de mot de passe"}]
      app.trigger("header:loading", true)
      showController = require("apps/home/show/home_show_controller.coffee").controller
      fetching = app.Auth.getWithForgottenKey(key)
      $.when(fetching).done( ()->
        showController.showLogOnForgottenKey(true)
      ).fail( (response)->
        if response.status is 401
          showController.showLogOnForgottenKey(false)
        else
          alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/034]")
      ).always( ()->
        app.trigger("header:loading", false)
      )
  casloginfailed: ->
    if app.Auth.get("logged_in")
      app.trigger("notFound")
    else
      app.Ariane.reset [{text:"Échec d'identification par l'ENT"}]
      require("apps/home/show/home_show_controller.coffee").controller.casloginfailed()
}

router = new Router()

app.on "home:show", ()->
  app.navigate("home")
  router.showHome()

app.on "home:login", ()->
  app.navigate("login")
  router.showLogin()

app.on "home:relogin", (options)->
  router.showReLogin(options)

app.on "home:logout", ()->
  router.logout()
  app.trigger("home:show")
