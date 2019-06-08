import { View } from 'backbone.marionette'
import { SubmitClicked } from 'apps/common/behaviors.coffee'
import Syphon from 'backbone.syphon'
import login_tpl from 'templates/home/login/home-login.tpl'

LoginView = View.extend {
  className:"card"
  template: login_tpl
  behaviors: [{
    behaviorClass: SubmitClicked
    messagesDiv: "messages"
  }]
  showForgotten: false # défault value
  generateTitle: true
  events: {
    "click button.js-forgotten": "forgottenClicked"
  }
  initialize: ->
    @title = @options.title ? "Connexion"
  onRender: ->
    if @getOption("generateTitle")
      $title = $("<div>", { text: "Connexion", class:"card-header"})
      @$el.prepend($title)
  templateContext: ->
    {
      showForgotten: @getOption("showForgotten")
    }
  forgottenClicked: (e)->
    e.preventDefault()
    data = Syphon.serialize(@)
    @trigger("login:forgotten", data.identifiant)
}

export { LoginView }
