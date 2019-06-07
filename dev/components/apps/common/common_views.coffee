import { View } from 'backbone.marionette'
import alert_tpl from 'templates/common/alert-view.tpl'

AlertView = View.extend {
  tag: "div",
  type: "danger"
  title: "Erreur !"
  message: "Erreur inconnue. Reessayez !"
  template: alert_tpl
  className: -> "alert alert-#{@getOption('type')}"
  templateContext: ->
    {
      title: @getOption("title")
      message: @getOption("message")
      type: @getOption("type")
    }
}

export { AlertView }
