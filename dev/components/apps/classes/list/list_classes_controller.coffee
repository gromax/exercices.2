import { MnObject } from 'backbone.marionette'
import { ClassesCollectionView, ClassesPanel } from 'apps/classes/list/list_classes_views.coffee'
import { EditClasseView, NewClasseView, FillClasseView } from 'apps/classes/edit/edit_classe_views.coffee'
import { ListLayout } from 'apps/common/common_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: 'entities',

  list_prof: (id) ->
    app.trigger "loading:up"
    channel = @getChannel()
    mainFct = @listMain
    require 'entities/dataManager.coffee'
    fetching = channel.request("custom:entities", ["classes", "users"])
    $.when(fetching).done( (classesList, usersList)->
      prof = usersList.get(id)
      if prof isnt undefined
        listItemsLayout = new ListLayout()
        listItemsPanel = new ClassesPanel()
        app.Ariane.add [
          { text:"Classes de #{prof.get("nomComplet")}", e:"classes:prof", data:id, link:"classes/prof:#{id}" }
        ]
        mainFct(prof, classesList)
      else
        app.trigger "not:found"
    ).fail( (response)->
      app.trigger "data:fetch:fail", response
    ).always( ->
      app.trigger "loading:down"
    )

  list: ->
    app.trigger "loading:up"
    channel = @getChannel()
    mainFct = @listMain
    require 'entities/dataManager.coffee'
    fetching = channel.request("custom:entities", ["classes"])
    $.when(fetching).done( (classesList)->
      mainFct(false, classesList)
    ).fail( (response)->
      app.trigger "data:fetch:fail", response
    ).always( ->
      app.trigger "loading:down"
    )

  listMain: (prof, classesList) ->
    listItemsLayout = new ListLayout()
    listItemsPanel = new ClassesPanel {
      addToProf: if prof isnt false then prof.get("nomComplet") else false
      showAddButton: prof isnt false or app.Auth.isProf()
    }

    listItemsView = new ClassesCollectionView {
      collection: classesList
      filterKeys: ["id", "nom", "prenom"]
      showFillClassButton: app.Auth.isAdmin()
      showProfName: prof is false and app.Auth.isAdmin()
    }

    if prof isnt false
      listItemsView.trigger "set:filter:criterion", prof.get("id")+prof.get("nom")+prof.get("prenom"), { preventRender: true }

    listItemsLayout.on "render", ->
      listItemsLayout.getRegion('panelRegion').show(listItemsPanel)
      listItemsLayout.getRegion('itemsRegion').show(listItemsView)

    listItemsPanel.on "classe:new", ->
      OClasse = require("entities/classes.coffee").Item
      newItem = new OClasse()
      view = new NewClasseView {
        model: newItem
        errorCode: "002"
        listView: listItemsView
      }
      app.regions.getRegion('dialog').show(view)

    if (prof is false)
      # en mode classe/prof, je ne permet pas la navigation qui serait de toute façon déroutante
      listItemsView.on "item:show", (childView)->
        model = childView.model
        app.trigger("classe:show", model.get("id"))

    listItemsView.on "item:classes:prof", (childView)->
      app.trigger "classes:prof", childView.model.get("idOwner")

    listItemsView.on "item:fill", (childView)->
      model = childView.model
      view = new FillClasseView {
        nomProf: model.get("nomOwner")
        itemView: childView
        errorCode: "003"
      }

    listItemsView.on "item:edit", (childView)->
      model = childView.model
      view = new EditClasseView {
        model: model
        itemView: childView
        errorCode: "003"
      }
      app.regions.getRegion('dialog').show(view)


    app.regions.getRegion('main').show(listItemsLayout)
}

export controller = new Controller()
