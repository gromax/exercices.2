import { View } from 'backbone.marionette'
import alert_tpl from 'templates/common/alert-view.tpl'
import list_layout_tpl from 'templates/common/list-layout.tpl'
import missing_item_tpl from 'templates/common/missing-item.tpl'


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

MissingView = View.extend {
  template: missing_item_tpl
  message: "Cet item n'existe pas."
  templateContext: ->
    {
      message: @getOption("message")
    }
}

ListLayout = View.extend {
  template: list_layout_tpl
  regions: {
    panelRegion: "#panel-region"
    itemsRegion: "#items-region"
  }
}

export { AlertView, MissingView, ListLayout }
