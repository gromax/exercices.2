import { View } from 'backbone.marionette'
import { SubmitClicked, NewItem, EditItem } from 'apps/common/behaviors.coffee'
import layout_tpl from 'templates/fiches/edit/edit-fiche-layout.tpl'
import edit_fiche_tpl from 'templates/fiches/edit/fiche-description-edit.tpl'


FicheLayout = View.extend {
  template: layout_tpl
  regions: {
    tabsRegion: "#tabs-region"
    panelRegion: "#panel-region"
    contentRegion: "#content-region"
  }
}

NewFicheView = View.extend {
  title: "Nouvelle fiche"
  template: edit_fiche_tpl
  behaviors: [ SubmitClicked, NewItem ]
}

EditFicheView = View.extend {
  template: edit_fiche_tpl
  behaviors: [SubmitClicked, EditItem]
  title: "Modifier le fiche"
  generateTitle: false
  onRender: ->
    if @getOption "generateTitle"
      $title = $("<h1>", { text: @title })
      @$el.prepend($title)
}

export { FicheLayout, NewFicheView, EditFicheView }
