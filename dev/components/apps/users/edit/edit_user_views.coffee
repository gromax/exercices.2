import { View } from 'backbone.marionette'
import { SubmitClicked, NewItemInList, EditItemInList } from 'apps/common/behaviors.coffee'

import edit_user_tpl from 'templates/users/edit/user-form.tpl'
import edit_pwd_user_tpl from 'templates/users/edit/userpwd-form.tpl'


EditUserView = View.extend {
  showPref: true
  showPWD: false
  ranks: false
  editorIsAdmin: false
  generateTitle: false
  template: edit_user_tpl
  behaviors: [SubmitClicked, EditItemInList]
  initialize: ->
    @title = "Modifier #{@model.get('prenom')} #{@model.get('nom')}"
  templateContext: ->
    {
      showPWD: @getOption "showPWD"
      showPref: @getOption "showPref"
      ranks: @getOption "ranks"
      editorIsAdmin: @getOption "editorIsAdmin"
    }
  onRender: ->
    if @getOption "generateTitle"
      $title = $("<h1>", { text: @title })
      @$el.prepend($title)

EditPwdUserView = View.extend {
  template: edit_pwd_user_tpl
  behaviors: [SubmitClicked, EditItemInList]
  title: "Modifier le mot de passe"
  generateTitle: false
  onRender: ->
    if @getOption "generateTitle"
      $title = $("<h1>", { text: @title })
      @$el.prepend($title)
}

NewUserView = View.extend {
  title: "Nouvel Utilisateur"
  showPWD: true
  showPref: true
  ranks:1
  editorIsAdmin: true
  template: edit_user_tpl
  behaviors: [ SubmitClicked, NewItemInList ]
  templateContext: ->
    {
      showPWD: @getOption "showPWD"
      showPref: @getOption "showPref"
      ranks: @getOption "ranks"
      editorIsAdmin: @getOption "editorIsAdmin"
    }
}

export { EditUserView, EditPwdUserView, NewUserView }
