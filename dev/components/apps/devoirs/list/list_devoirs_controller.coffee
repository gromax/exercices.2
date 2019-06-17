import { MnObject } from 'backbone.marionette'
import { DevoirsPanel, DevoirsCollectionView } from 'apps/devoirs/list/list_devoirs_views.coffee'
import { NewDevoirView, EditDevoirView } from 'apps/devoirs/edit/edit_devoir_views.coffee'
import { AlertView, ListLayout } from 'apps/common/common_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: 'entities'
  list: ->
    app.trigger("header:loading", true)
    listItemsLayout = new ListLayout()
    panel = new DevoirsPanel {
      adminMode: app.Auth.isAdmin()
      showInactifs: app.settings.showDevoirsInactifs is true
    }
    channel = @getChannel()
    Item = require("entities/devoirs.coffee").Item
    require('entities/dataManager.coffee')

    fetchingDevoirsList = channel.request("custom:entities",["devoirs"])
    $.when(fetchingDevoirsList).done( (devoirs)->
      listItemsView = new DevoirsCollectionView {
        collection: devoirs
        adminMode: app.Auth.isAdmin()
        showInactifs: app.settings.showDevoirsInactifs is true
      }

      listItemsLayout.on "render", ()->
        listItemsLayout.getRegion('panelRegion').show(panel)
        listItemsLayout.getRegion('itemsRegion').show(listItemsView)

      panel.on "devoir:new", ->
        newItem = new Item()
        newItemView = new NewDevoirView {
          model: newItem
          collection: devoirs
          listView: listItemsView
          errorCode: "020"
        }
        app.regions.getRegion('dialog').show(newItemView)

      panel.on "devoir:toggle:showInactifs", ()->
        alert("non implémenté")

      listItemsView.on "item:show", (childView, args)->
        app.trigger "devoir:show", childView.model.get("id")

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
