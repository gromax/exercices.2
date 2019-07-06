import { MnObject } from 'backbone.marionette'
import { ExercicesPanel, ExercicesCollectionView } from 'apps/exercices/list/list_exercices_views.coffee'
import { ListLayout } from 'apps/common/common_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: "entities"
  list: (criterion) ->
    criterion = criterion ? ""
    layout = new ListLayout()
    panel = new ExercicesPanel {filterCriterion:criterion}
    channel = @getChannel()

    require "entities/exercices.coffee"
    exercicesCollection = channel.request("exercices:entities")
    listExercicesView = new ExercicesCollectionView {
      collection: exercicesCollection
      filterCriterion: criterion
    }

    panel.on "items:filter", (filterCriterion) ->
      listExercicesView.trigger("set:filter:criterion", filterCriterion, { preventRender:false })
      app.trigger("exercices:filter", filterCriterion)

    layout.on "render", () ->
      layout.getRegion('panelRegion').show(panel)
      layout.getRegion('itemsRegion').show(listExercicesView)

    listExercicesView.on "item:exercice:show", (childView) ->
      app.trigger "exercice:show", childView.model.get("id")

    app.regions.getRegion('main').show(layout)
}

export controller = new Controller()
