import { MnObject } from 'backbone.marionette'
import { EditUserView, EditPwdUserView } from 'apps/users/edit/edit_user_views.coffee'
import { AlertView, MissingItemView } from 'apps/common/common_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: "entities"
  editUser: (id, isMe, isAdmin, pwd) ->
    if pwd is true
      text="Modification du mot de passe"
      trigger="user:editPwd"
    else
      textLink="Modification"
      trigger="user:edit"

    app.trigger("header:loading", true)
    channel = @getChannel()
    require('entities/dataManager.coffee')
    if isMe
      fetchingUser = channel.request("user:me")
    else
      fetchingUser = channel.request("user:entity", id)
    $.when(fetchingUser).done( (user)->
      if user isnt undefined
        if isMe
          id = user.get("id")
          app.Ariane.add [
            { text:"Mon compte", e:"user:show", data:user.get("id"), link:"user:#{id}" }
            { text:textLink, e:trigger, data:user.get("id"), link:"user:#{id}/edit" }
          ]
        else
          app.Ariane.add [
            { text:user.get("nomComplet"), e:"user:show", data:user.get("id"), link:"user:"+user.get("id") }
            { text:textLink, e:trigger, data:user.get("id"), link:"user:"+user.get("id")+"/edit" }
          ]

        if pwd id true
          view = new EditPwdUserView {
            model: user
            generateTitle: true
            editorIsAdmin: isAdmin
          }
        else
          view = new EditUserView {
            model: user
            generateTitle: true
            editorIsAdmin: isAdmin
          }

        view.on "form:submit", (data) ->
          app.trigger("header:loading", true)
          updatingUser = user.save(_.omit(data,"pwdConfirm"))
          if updatingUser
            $.when(updatingUser).done( ()->
              if isMe
                app.Auth.set(data) # met à jour nom, prénom et pref
              app.trigger("user:show", user.get("id"));
            ).fail( (response)->
              switch response.status
                when 422
                  view.triggerMethod("form:data:invalid", response.responseJSON.errors)
                when 401
                  alert("Vous devez vous (re)connecter !")
                  app.trigger("home:logout")
                else
                  alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/028]")
            ).always( ()->
              app.trigger("header:loading", false)
            )
          else
            view.triggerMethod("form:data:invalid", user.validationError)
      else
        if isMe
          app.Ariane.add [
            { text:"Mon compte", e:"user:show", data:id, link:"user:#{id}" }
            { text:textLink, e:trigger, data:id, link:"user:#{id}/edit" }
          ]
        else
          app.Ariane.add [
            { text:"Utilisateur inconnu", e:"user:show", data:id, link:"user:"+id }
            { text:textLink, e:trigger, data:id, link:"user:"+id+"/edit" }
          ]
        view = new MissingView {message:"Cet utilisateur n'existe pas !"}
      app.regions.getRegion('main').show(view)
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
