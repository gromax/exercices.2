import { MnObject } from 'backbone.marionette'
import { UsersPanel, UsersCollectionView } from 'apps/users/list/list_users_views.coffee'
import { NewUserView, EditUserView, EditPwdUserView } from 'apps/users/edit/edit_user_views.coffee'
import { ListLayout } from 'apps/common/common_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: 'entities'
  listUsers: (criterion)->
    channel = @getChannel()
    require('entities/dataManager.coffee')
    app.trigger "loading:up"
    fetchingUsers = channel.request("custom:entities", ["users"])
    $.when(fetchingUsers).done( (users) ->
      criterion = criterion ? ""
      usersListLayout = new ListLayout()
      usersListPanel = new UsersPanel {
        filterCriterion:criterion
        showAddButton:app.Auth.isAdmin()
      }
      usersListView = new UsersCollectionView {
        collection: users
        adminMode: app.Auth.isAdmin()
      }
      usersListView.trigger "set:filter:criterion", criterion, { preventRender:false }
      usersListPanel.on "items:filter", (filterCriterion)->
        usersListView.trigger "set:filter:criterion", filterCriterion, { preventRender:false }
        app.trigger("users:filter", filterCriterion)

      usersListLayout.on "render", ->
        usersListLayout.getRegion('panelRegion').show(usersListPanel)
        usersListLayout.getRegion('itemsRegion').show(usersListView)

      usersListPanel.on "user:new", ->
        User = require("entities/users.coffee").Item
        newUser = new User()
        newUserView = new NewUserView {
          model: newUser
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
          model: model
          itemView: childView
          errorCode: "031"
          editorIsAdmin: app.Auth.isAdmin()
        }

        app.regions.getRegion('dialog').show(editView)

      usersListView.on "item:editPwd", (childView, args)->
        model = childView.model
        editPwdView = new EditPwdUserView {
          model: model
          itemView: childView
          errorCode: "032"
        }

        app.regions.getRegion('dialog').show(editPwdView)

      usersListView.on "item:forgotten", (childView,e)->
        model = childView.model
        email = model.get("email")
        if confirm("Envoyer un mail de réinitialisation à « #{model.get('nomComplet')} » ?")
          app.trigger "loading:up"
          sendingMail = channel.request("forgotten:password", email)
          sendingMail.always( ->
            app.trigger "loading:down"
          ).done( (response)->
            childView.trigger "flash:success"
          ).fail( (response)->
            alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/034]")
          )

      usersListView.on "item:sudo", (childView, e)->
        model = childView.model
        app.trigger "loading:up"
        connecting = app.Auth.sudo model.get("id")
        $.when(connecting).done( ->
          app.trigger "home:show"
        ).fail( (response)->
          switch response.status
            when 404
              alert "Page inconnue !"
            when 403
              alert "Non autorisé !"
            else
              alert "Erreur inconnue."
        ).always( ->
          app.trigger "loading:down"
        )

      app.regions.getRegion('main').show(usersListLayout)
    ).fail( (response)->
      app.trigger "data:fetch:fail", response
    ).always( ->
      app.trigger "loading:down"
    )
}

export controller = new Controller()
