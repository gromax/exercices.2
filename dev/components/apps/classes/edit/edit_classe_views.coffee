import { View } from 'backbone.marionette'
import { SubmitClicked, EditItem } from 'apps/common/behaviors.coffee'
import edit_tpl from 'templates/classes/common/classe-form.tpl'
import new_tpl from 'templates/classes/common/classe-form.tpl'
import fill_tpl from 'templates/classes/list/classe-fill-form.tpl'

EditClasseView = View.extend {
  template: edit_tpl
  generateTitle: false
  behaviors: [SubmitClicked, EditItem]
  initialize: ->
    @title = "Modifier la classe : #{@model.get('nom')}"

  onRender: ->
    if @getOption("generateTitle")
      $title = $("<h1>", { text: @title })
      @$el.prepend($title)
}

NewClasseView = View.extend {
  title: "Nouvelle classe"
  template: new_tpl
  behaviors: [SubmitClicked, EditItem]
}

FillClasseView = View.extend {
  template: fill_tpl
  behaviors: [
    SubmitClicked,
    {
      behaviorClass: EditItem
      updatingFunctionName: "fill"
    }
  ]
  initialize: ->
    @title = "Nouvelle classe pour #{@getOption('nomProf')}";
}

export { EditClasseView, NewClasseView, FillClasseView }
