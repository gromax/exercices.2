import { MnObject } from 'backbone.marionette'
import { ClassesCollectionView, ClassesPanel, FillClasseView, NewItemView } from 'apps/classes/list/classes_list_views.coffee'
import { EditClasseView } from 'apps/classes/edit/edit_classe_view.coffee'
import { AlertView, ListLayout } from 'apps/common/common_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: 'entities',

  list_prof: (id) ->
    app.trigger("header:loading", true)
    channel = @getChannel()
    mainFct = @listMain
    require('entities/dataManager.coffee')
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
        view = new AlertView({message: "Cet utilisateur n'existe pas.", dismiss:false })
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

  list: ->
    app.trigger("header:loading", true)
    channel = @getChannel()
    mainFct = @listMain
    require('entities/dataManager.coffee')
    fetching = channel.request("custom:entities", ["classes"])
    $.when(fetching).done( (classesList)->
      mainFct(false, classesList)
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

    listItemsLayout.on "render", ()->
      listItemsLayout.getRegion('panelRegion').show(listItemsPanel)
      listItemsLayout.getRegion('itemsRegion').show(listItemsView)

    listItemsPanel.on "classe:new", ()->
      OClasse = require("entities/classes.coffee").Item
      newItem = new OClasse()
      view = new NewItemView {
        model: newItem
      }

      view.on "form:submit", (data)->
        if prof isnt false then data.idOwner = prof.get("id")
        savingItem = newItem.save(data)
        if savingItem
          app.trigger("header:loading", true)
          $.when(savingItem).done( ()->
            classesList.add(newItem)
            view.trigger("dialog:close")
            listItemsView.children.findByModel(newItem)?.trigger("flash:success")
          ).fail( (response)->
            switch response.status
              when 422
                view.triggerMethod("form:data:invalid", response.responseJSON.ajaxMessages)
              when 401
                alert("Vous devez vous (re)connecter !")
                view.trigger("dialog:close")
                app.trigger("home:logout")
              else
                alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/002]")
          ).always( ()->
            app.trigger("header:loading", false)
          )
        else
          view.triggerMethod("form:data:invalid",newItem.validationError)
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
      }

      view.on "form:submit", (data)->
        fillingItem = model.fill(data.list)
        app.trigger("header:loading", true)
        $.when(fillingItem).done( ()->
          childView.render()
          view.trigger("dialog:close")
          childView.trigger "flash:success"
        ).fail( (response)->
          switch response.status
            when 401
              alert("Vous devez vous (re)connecter !")
              view.trigger("dialog:close")
              app.trigger("home:logout")
            else
              alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/003]")
        ).always( ()->
          app.trigger("header:loading", false)
        )
      app.regions.getRegion('dialog').show(view)

    listItemsView.on "item:edit", (childView)->
      model = childView.model
      view = new EditClasseView {
        model:model
      }

      view.on "form:submit", (data)->
        updatingItem = model.save(data)
        if updatingItem
          app.trigger("header:loading", true)
          $.when(updatingItem).done( ()->
            childView.render()
            view.trigger("dialog:close")
            childView.trigger "flash:success"
          ).fail( (response)->
            switch response.status
              when 422
                view.triggerMethod("form:data:invalid", response.responseJSON.ajaxMessages)
              when 401
                alert("Vous devez vous (re)connecter !")
                view.trigger("dialog:close")
                app.trigger("home:logout")
              else
                alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/003]")
          ).always( ()->
            app.trigger("header:loading", false)
          )
        else
          @triggerMethod("form:data:invalid", model.validationError)
      app.regions.getRegion('dialog').show(view)


    app.regions.getRegion('main').show(listItemsLayout)
}

export controller = new Controller()
