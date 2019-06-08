import { View } from 'backbone.marionette'
import { app } from 'app'
import header_tpl from 'templates/header/show/header-navbar.tpl'


HeaderView = View.extend {
  template: header_tpl
  triggers: {
    "click a.js-home": "home:show"
    "click a.js-edit-me": "home:editme"
    "click a.js-login": "home:login"
    "click a.js-logout": "home:logout"
    "click a.js-message": "messages:list"
  }

  templateContext: ->
    if app.Auth
      auth = _.clone(app.Auth.attributes)
    else
      auth = { isOff: true }
    {
      isAdmin: auth.isAdmin is true
      isProf: auth.isProf is true
      isEleve: auth.isEleve is true
      isOff: auth.isOff is true
      nomComplet: if auth.isOff then "Déconnecté" else auth.prenom+" "+auth.nom
      unread: auth.unread ? 0
      version: app.version
    }
  logChange: ->
    @render()
  onHomeShow: ->
    app.trigger("home:show")
  onHomeEditme: ->
    app.trigger("user:show",app.Auth.get("id"))
  onHomeLogin: ->
    app.trigger("home:login")
  onHomeLogout: ->
    app.trigger("home:logout")
  onMessagesList: ->
    app.trigger("messages:list")
  spin: (set_on) ->
    if (set_on)
      $("span.js-spinner", @$el).html("<i class='fa fa-spinner fa-spin'></i>")
    else
      $("span.js-spinner", @$el).html("")
}

export { HeaderView }
