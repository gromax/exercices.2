import { MnObject } from 'backbone.marionette'
impott { FicheLayout, TabsPanel, ShowFicheDescriptionView } from 'apps/fiches/edit/edit_fiche_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: "entities"
  linkTabsEvents: (tabs, tabindex)->
    if tabindex isnt 0 then tabs.on "tab:description", ()->
      app.trigger "devoir:showDescription", id
    if tabindex isnt 1 then tabs.on "tab:exercices", ()->
      app.trigger "devoir:showExercices", id
    if tabindex isnt 2 then tabs.on "tab:notes", ()->
      app.trigger "devoir:showUserfiches", id
    if tabindex isnt 3 then tabs.on "tab:eleves", ()->
      app.trigger "devoir:addUserfiche", id
    if tabindex isnt 4 then tabs.on "tab:exams", ()->
      app.trigger "devoir:exams", id
  showDescription: (id) ->
    # vue des paramètres du devoir lui même
    app.trigger "loading:up"
    layout = new FicheLayout()
    tabs = new TabsPanel {panel:0}
    @linkTabsEvents tabs
    layout.on "render", ()->
      layout.getRegion('tabsRegion').show(tabs)
    app.regions.getRegion('main').show(layout)
    channel = @getChannel()
    require "entities/dataManager"
    fetchingData = channel.request "custom:entities", ["fiches"]
    $.when(fetchingData).done( (fiches)->
      fiche = fiches.get(id)
      if fiche
        view = new ShowFicheDescriptionView {
          model: fiche
        }
        view.on "edit", ->
          app.trigger "fiche:edit", id
        layout.getRegion('contentRegion').show(view)
      else
        app.trigger "not:found"
    ).fail( (response) ->
      app.trigger "data:fetch:fail", response
    ).always( ->
      app.trigger "loading:down"
    )

}

export controller = new Controller()
