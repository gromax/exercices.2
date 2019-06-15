import { MnObject } from 'backbone.marionette'
import { UsersPanel, UsersCollectionView } from 'apps/users/list/list_users_views.coffee'
import { NewUserView, EditUserView, EditPwdUserView } from 'apps/users/edit/edit_user_views.coffee'
import { AlertView, MissingItemView, ListLayout } from 'apps/common/common_views.coffee'
import { app } from 'app'

Controller = Marionette.Object.extend {
  channelName: 'entities'
  listUsers: (criterion)->
    criterion = criterion ? ""
    app.trigger("header:loading", true)
    usersListLayout = new ListLayout()
    usersListPanel = new UsersPanel {
      filterCriterion:criterion
      showAddButton:app.Auth.isAdmin()
    }
    channel = @getChannel()

    User = require("entities/users.coffee").item
    require('entities/dataManager.coffee')

    fetchingUsers = channel.request("custom:entities", ["users"])
    $.when(fetchingUsers).done( (users) ->
      usersListView = new UsersCollectionView {
        collection: users
      }

      usersListView.trigger "set:filter:criterion", criterion, { preventRender:false }

      usersListPanel.on "users:filter", (filterCriterion)->
        usersListView.triggerMethod "set:filter:criterion", filterCriterion, { preventRender:false }
        app.trigger("users:filter", filterCriterion)

      usersListLayout.on "render", ->
        usersListLayout.getRegion('panelRegion').show(usersListPanel)
        usersListLayout.getRegion('itemsRegion').show(usersListView)

      usersListPanel.on "user:new", ->
        newUser = new User()
        newUserView = new NewUserView {
          model: newUser
          collection: users
          listView: usersListView
          ranks: if app.Auth.isRoot() then 2 else 1
          errorCode: "030"
        }
        app.regions.getRegion('dialog').show(newUserView)

      usersListView.on "item:show", (childView, args)->
        model = childView.model
        app.trigger("user:show", model.get("id"))

      usersListView.on "item:edit", (childView, args)->
        model = childView.model
        editView = new EditUserView {
          model:model
          editorIsAdmin:app.Auth.isAdmin()
        }

        editView.on "form:submit", (data)->
          editView.trigger "edit:submit", data, childView, "031"

        app.regions.getRegion('dialog').show(editView)

      usersListView.on "item:editPwd", (childView, args)->
        model = childView.model
        editPwdView = new EditPwdUserView {
          model:model
        }

        editPwdView.on "form:submit", (data)->
          if data.pwd isnt data.pwdConfirm
            editPwdView.trigger "form:data:invalid", { pwdConfirm:"Les mots de passe sont différents." }
          else
            editPwdView.trigger "edit:submit", _.omit(data,"pwdConfirm"), childView, "032"

        app.regions.getRegion('dialog').show(editPwdView)

      usersListView.on "item:forgotten", (childView,e)->
        model = childView.model
        email = model.get("email")
        if confirm("Envoyer un mail de réinitialisation à « #{model.get('nomComplet')} » ?")
          app.trigger("header:loading", true)
          sendingMail = channel.request("forgotten:password", email)
          sendingMail.always( ->
            app.trigger "header:loading", false
          ).done( (response)->
            childView.trigger "flash:success"
          ).fail( (response)->
            alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/034]")
          )

      usersListView.on "item:sudo", (childView, e)->
        model = childView.model
        app.trigger "header:loading", true
        connecting = app.Auth.sudo model.get("id")
        $.when(connecting).done( ()->
          app.trigger("home:show")
        ).fail( (response)->
          switch response.status
            when 404
              alert "Page inconnue !"
            when 403
              alert "Non autorisé !"
            else
              alert "Erreur inconnue."
        ).always( ->
          app.trigger("header:loading", false)
        )

      app.regions.getRegion('main').show(usersListLayout)
    ).fail( (response)->
      if response.status is 401
        alert("Vous devez vous (re)connecter !")
        app.trigger("home:logout")
      else
        alertView = new AlertView()
        app.regions.getRegion('main').show(alertView)
    ).always( ()->
      app.trigger("header:loading", false)
    )
}

export controller = new Controller()
