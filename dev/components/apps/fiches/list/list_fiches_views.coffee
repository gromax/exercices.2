import { View, CollectionView } from 'backbone.marionette'
import { DestroyWarn, FlashItem, FilterList, SortList, ToggleItemValue } from 'apps/common/behaviors.coffee'

import panel_tpl from 'templates/fiches/list/list-fiches-panel.tpl'
import no_fiche_tpl from 'templates/fiches/list/fiche-list-none.tpl'
import fiche_item_tpl from 'templates/fiches/list/fiche-list-item.tpl'
import fiches_list_tpl from 'templates/fiches/list/fiche-list.tpl'


FichesPanel = View.extend {
  adminMode: false
  showInactifs: true
  template: panel_tpl
  templateContext: ->
    {
      adminMode: @getOption "adminMode"
      showInactifs: @getOption "showInactifs"
    }
  triggers: {
    "click button.js-new": "fiche:new",
    "click button.js-inactive-filter": "fiche:toggle:showInactifs"
  }
}

NoFicheView = View.extend {
  template: no_fiche_tpl
  tagName: "tr"
  className: "alert"
}

FicheItemView = View.extend {
  adminMode: false
  tagName: "tr"
  template: fiche_item_tpl
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

FichesCollectionView = CollectionView.extend {
  adminMode: false
  tagName: "table"
  className:"table table-hover"
  template: fiches_list_tpl
  childView:FicheItemView
  emptyView:NoFicheView
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

export { FichesPanel, FichesCollectionView }
