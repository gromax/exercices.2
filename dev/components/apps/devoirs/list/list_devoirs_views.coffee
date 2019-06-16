import { View, CollectionView } from 'backbone.marionette'
import { DestroyWarn, FlashItem, FilterList, SortList, ToggleItemValue } from 'apps/common/behaviors.coffee'

import panel_tpl from 'templates/devoirs/list/list-devoirs-panel.tpl'
import no_devoir_tpl from 'templates/devoirs/list/devoir-list-none.tpl'
import devoir_item_tpl from 'templates/devoirs/list/devoir-list-item.tpl'
import devoirs_list_tpl from 'templates/devoirs/list/devoir-list.tpl'


DevoirsPanel = View.extend {
  adminMode: false
  showInactifs: true
  template: panel_tpl
  templateContext: ->
    {
      adminMode: @getOption "adminMode"
      showInactifs: @getOption "showInactifs"
    }
  triggers: {
    "click button.js-new": "devoir:new",
    "click button.js-inactive-filter": "devoir:toggle:showInactifs"
  }
}

NoDevoirView = View.extend {
  template: no_devoir_tpl
  tagName: "tr"
  className: "alert"
}

DevoirItemView = View.extend {
  adminMode: false
  tagName: "tr"
  template: devoir_item_tpl
  behaviors: [
    DestroyWarn
    FlashItem
    {
      behaviorClass: ToggleItemValue
      errorCode: "021"
    }
  ]
  triggers: {
    "click button.js-actif": "toggle:activity"
    "click button.js-visible": "toggle:visibility"
    "click": "show"
  }
  templateContext: ->
    {
      adminMode: @getOption "adminMode"
    }
}

DevoirsCollectionView = CollectionView.extend {
  adminMode: false
  tagName: "table"
  className:"table table-hover"
  template: devoirs_list_tpl
  childView:DevoirItemView
  emptyView:NoDevoirView
  behaviors: [FilterList, SortList]
  childViewEventPrefix: "item"
  childViewContainer: "tbody"
  filterKeys: ["nom", "nomProf"]
  childViewOptions: ->
    {
      adminMode: @getOption("adminMode")
    }
  templateContext: ->
    {
      adminMode: @getOption("adminMode")
    }
}

export { DevoirsPanel, DevoirsCollectionView }
