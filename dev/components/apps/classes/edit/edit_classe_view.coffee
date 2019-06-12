import { View } from 'backbone.marionette'
import { SubmitClicked } from 'apps/common/behaviors.coffee'
import edit_tpl from 'templates/classes/common/classe-form.tpl'

EditClasseView = View.extend {
  template: edit_tpl
  generateTitle: false
  behaviors: [SubmitClicked]
  initialize: ->
    @title = "Modifier la classe : #{@model.get('nom')}"

  onRender: ->
    if @getOption("generateTitle")
      $title = $("<h1>", { text: @title })
      @$el.prepend($title)
}

export { EditClasseView }
