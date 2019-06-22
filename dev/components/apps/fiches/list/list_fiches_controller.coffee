import { MnObject } from 'backbone.marionette'
import { FichesPanel, FichesCollectionView } from 'apps/fiches/list/list_fiches_views.coffee'
import { NewFicheView } from 'apps/fiches/edit/edit_fiche_views.coffee'
import { AlertView, ListLayout } from 'apps/common/common_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: 'entities'
  list: ->
    app.trigger("header:loading", true)
    listItemsLayout = new ListLayout()
    panel = new FichesPanel {
      adminMode: app.Auth.isAdmin()
      showInactifs: app.settings.showFichesInactifs is true
    }
    channel = @getChannel()
    Item = require("entities/fiches.coffee").Item
    require('entities/dataManager.coffee')

    fetchingFichesList = channel.request("custom:entities",["fiches"])
    $.when(fetchingFichesList).done( (fiches)->
      listItemsView = new FichesCollectionView {
        collection: fiches
        adminMode: app.Auth.isAdmin()
        showInactifs: app.settings.showFichesInactifs is true
      }

      listItemsLayout.on "render", ()->
        listItemsLayout.getRegion('panelRegion').show(panel)
        listItemsLayout.getRegion('itemsRegion').show(listItemsView)

      panel.on "fiche:new", ->
        newItem = new Item()
        newItemView = new NewFicheView {
          model: newItem
          collection: fiches
          listView: listItemsView
          errorCode: "020"
        }
        app.regions.getRegion('dialog').show(newItemView)

      panel.on "fiche:toggle:showInactifs", ()->
        alert("non implémenté")

      listItemsView.on "item:show", (childView, args)->
        app.trigger "fiche:show", childView.model.get("id")

      listItemsView.on "item:toggle:activity", (childView) ->
        childView.trigger "toggle:attribute", "actif"

      listItemsView.on "item:toggle:visibility", (childView) ->
        childView.trigger "toggle:attribute", "visible"

      app.regions.getRegion('main').show(listItemsLayout)
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
