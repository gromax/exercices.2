import { app } from 'app'

Router = Backbone.Router.extend {
  routes: {
    "classes/prof::id": "classeProf"
    "classes": "classesList"
    "classe::id": "classeShow"
    "classe::id/edit": "classeEdit"
  }

  classesList: ->
    auth = app.Auth
    forProf = ->
      app.Ariane.reset [{ text:"Classes", e:"classes:list", link:"classes"}]
      require("apps/classes/list/list_classes_controller.coffee").controller.list()

    todo = auth.mapItem {
      "Admin": forProf
      "Prof": forProf
      "Eleve": -> app.trigger("notFound")
      "def": -> app.trigger("home:login")
    }
    todo()

  classeShow: (id) ->
    auth = app.Auth
    forProf = ->
      app.Ariane.reset [{ text:"Classes", e:"classes:list", link:"classes"}]
      require("apps/classes/show/show_classe_controller.coffee").controller.show(id)

    todo = auth.mapItem {
      "Admin": forProf
      "Prof": forProf
      "Eleve": -> app.trigger("notFound")
      "def": -> app.trigger("home:login")
    }
    todo()

  classeEdit: (id) ->
    auth = app.Auth
    forProf = ->
      app.Ariane.reset [{ text:"Classes", e:"classes:list", link:"classes"}]
      require("apps/classes/edit/edit_classe_controller.coffee").controller.edit(id)

    todo = auth.mapItem {
      "Admin": forProf
      "Prof": forProf
      "Eleve": -> app.trigger("notFound")
      "def": -> app.trigger("home:login")
    }
    todo()

  classeProf: (id) ->
    auth = app.Auth
    forAdmin = ->
      app.Ariane.reset [{ text:"Classes", e:"classes:list", link:"classes"}]
      require("apps/classes/list/list_classes_controller.coffee").controller.list_prof(id)

    todo = auth.mapItem {
      "Admin": forAdmin
      "Prof": -> app.trigger("notFound")
      "Eleve": -> app.trigger("notFound")
      "def": -> app.trigger("home:login")
    }
    todo()
}

router = new Router()

app.on "classes:list", () ->
  app.navigate("classes")
  router.classesList()

app.on "classe:show", (id) ->
  app.navigate("classe:#{id}")
  router.classeShow(id)

app.on "classe:edit", (id) ->
  app.navigate("classe:#{id}/edit")
  router.classeEdit(id)

app.on "classes:prof", (id) ->
  app.navigate("classes/prof:#{id}")
  router.classeProf(id)
