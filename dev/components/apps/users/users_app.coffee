import { app } from 'app'

Router = Backbone.Router.extend {
  routes: {
    "users(/filter/criterion::criterion)": "listUsers"
    "user::id": "showUser"
    "user::id/edit": "editUser"
    "user::id/password": "editUserPwd"
  }

  listUsers: (criterion) ->
    auth = app.Auth
    forProf = ->
      app.Ariane.reset([{ text:"Utilisateurs", e:"users:list", link:"users"}])
      require("apps/users/list/list_users_controller.coffee").controller.listUsers(criterion)

    todo = auth.mapItem {
      "Admin": forProf
      "Prof": forProf
      "Eleve": () -> app.trigger("notFound")
      "def": () -> app.trigger("home:login")
    }
    todo()

  showUser: (id) ->
    auth = app.Auth
    if auth.get("id") is id
      app.Ariane.reset []
      require("apps/users/show/show_user_controller.coffee").controller.showUser(id, true)
    else if auth.isAdmin() or auth.isProf()
      app.Ariane.reset [{ text:"Utilisateurs", e:"users:list", link:"users"}]
      require("apps/users/show/show_user_controller.coffee").controller.showUser(id, false)
    else
      app.trigger("notFound")

  editUser: (id) ->
    auth = app.Auth
    if auth.get("id") is id
      app.Ariane.reset []
      require("apps/users/edit/edit_user_controller.coffee").controller.editUser(id, true, app.Auth.isAdmin(), false)
    else if  auth.isAdmin() or auth.isProf()
      app.Ariane.reset [{ text:"Utilisateurs", e:"users:list", link:"users"}]
      require("apps/users/edit/edit_user_controller.coffee").controller.editUser(id, false, app.Auth.isAdmin(), false)
    else
      app.trigger("notFound")

  editUserPwd: (id) ->
    auth = app.Auth
    id = id ? auth.get("id")
    if auth.get("id") is id
      app.Ariane.reset []
      require("apps/users/edit/edit_user_controller.coffee").controller.editUser(id, true, app.Auth.isAdmin(), true)
    else if auth.isAdmin() or auth.isProf()
      app.Ariane.reset [{ text:"Utilisateurs", e:"users:list", link:"users"}]
      require("apps/users/edit/edit_user_controller.coffee").controller.editUser(id, false, app.Auth.isAdmin(), true)
    else
      app.trigger("notFound")
}

router = new Router()

app.on "users:list", ->
  app.navigate "users"
  router.listUsers()

app.on "users:filter", (criterion) ->
  if criterion
    app.navigate "users/filter/criterion:#{criterion}"
  else
    app.navigate "users"

app.on "user:show", (id) ->
  app.navigate "user:#{id}"
  router.showUser id

app.on "user:edit", (id) ->
  app.navigate "user:#{id}/edit"
  router.editUser id

app.on "user:editPwd", (id) ->
  app.navigate "user:#{id}/password"
  router.editUserPwd id
