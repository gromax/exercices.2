import { View, CollectionView } from 'backbone.marionette'
import { app } from 'app'
import item_tpl from 'templates/ariane/show/show-item.tpl'
import ariane_tpl from 'templates/ariane/show/show-list.tpl'
import not_loaded_tpl from 'templates/ariane/show/ariane-not-loaded-view.tpl'

NoView = View.extend {
  tagName: "li"
  className: "breadcrumb-item active"
  template: not_loaded_tpl
}

ItemView = View.extend {
  tagName: "li"
  template: item_tpl
  className: ->
    if @model.get("active")
      "breadcrumb-item"
    else
      # Ça peut paraître bizarre, mais c'est quand il n'y a pas de lien
      # et que c'est inactif qu'il faut mettre la classe active avec bootstrap breadcrumb
      "breadcrumb-item active"
  initialize: ->
    @listenTo(
      @model,
      "change:active",
      ()->
        @render()
    )
  triggers: {
    "click a.js-next" : "ariane:next"
    "click a.js-prev" : "ariane:prev"
    "click a.js-link" : "ariane:navigate"
  }
  onArianePrev: ->
    event_name = @model.get("e")
    data = @model.get("prev")
    app.trigger.apply(app,_.flatten([event_name,data]))
  onArianeNext: ->
    event_name = @model.get("e")
    data = @model.get("next")
    app.trigger.apply(app,_.flatten([event_name,data]))
  onArianeNavigate: ->
    active = @model.get("active")
    event_name = @model.get("e")
    data = @model.get("data")
    if active and event_name
      app.trigger.apply(app,_.flatten([event_name,data]))
}

FilView = CollectionView.extend {
  tagName:"ol"
  className: "breadcrumb"
  childViewEventPrefix: "item"
  childView: ItemView
  emptyView: NoView
}

ArianeView = View.extend {
  tagName: "nav"
  template: ariane_tpl
  regions: {
    body: {
      el:'ol'
      replaceElement:true
    }
  }
  onRender: ->
    @subCollection = new FilView {
      collection: @collection
    }
    @showChildView('body', @subCollection)
}

export { ArianeView }
