import { View } from 'backbone.marionette'
import { SubmitClicked, NewItem, EditItem } from 'apps/common/behaviors.coffee'
import layout_tpl from 'templates/devoirs/edit/edit-devoir-layout.tpl'
import edit_devoir_tpl from 'templates/devoirs/edit/devoir-description-edit.tpl'


DevoirLayout = View.extend {
  template: layout_tpl
  regions: {
    tabsRegion: "#tabs-region"
    panelRegion: "#panel-region"
    contentRegion: "#content-region"
  }
}

NewDevoirView = View.extend {
  title: "Nouveau Devoir"
  template: edit_devoir_tpl
  behaviors: [ SubmitClicked, NewItem ]
}

EditDevoirView = View.extend {
  template: edit_devoir_tpl
  behaviors: [SubmitClicked, EditItem]
  title: "Modifier le devoir"
  generateTitle: false
  onRender: ->
    if @getOption "generateTitle"
      $title = $("<h1>", { text: @title })
      @$el.prepend($title)
}





export { DevoirLayout }
