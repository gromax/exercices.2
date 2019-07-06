import { MnObject } from 'backbone.marionette'
import { ShowUserView } from 'apps/users/show/show_user_view.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: "entities"
  showUser: (id, isMe) ->
    app.trigger "loading:up"
    channel = @getChannel()
    require('entities/dataManager.coffee')
    if isMe
      fetchingUser = channel.request("user:me")
    else
      fetchingUser = channel.request("user:entity", id)
    $.when(fetchingUser).done( (user)->
      if user isnt undefined
        if isMe
          app.Ariane.add { text:"Mon compte", e:"user:show", data:id, link:"user:#{id}"}
        else
          app.Ariane.add { text:user.get("nomComplet"), e:"user:show", data:id, link:"user:#{id}"}
        view = new ShowUserView {
          model: user
        }
        view.on "click:edit", ->
          app.trigger("user:edit", user.get("id"))
        view.on "click:edit:pwd", ->
          app.trigger("user:editPwd", user.get("id"))
        app.regions.getRegion('main').show(view)
      else
        if isMe
          app.Ariane.add { text:"Mon compte", e:"user:show", data:id, link:"user:#{id}"}
        else
          app.Ariane.add { text:"Utilisateur inconnu", e:"user:show", data:id, link:"user:#{id}"}
        app.trigger "not:found"
    ).fail( (response)->
      app.trigger "data:fetch:fail", response
    ).always( ->
      app.trigger "loading:down"
    )
}

export controller = new Controller()
