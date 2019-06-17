import { View, CollectionView } from 'backbone.marionette'
import { FilterList, FilterPanel } from 'apps/common/behaviors.coffee'

import panel_tpl from 'templates/exercices/list/exercice-list-panel.tpl'
import no_exercice_view_tpl from 'templates/exercices/list/exercice-list-none.tpl'
import exercice_item_view_tpl from 'templates/exercices/list/exercice-list-item.tpl'

ExercicesPanel = View.extend {
  template: panel_tpl
  behaviors: [FilterPanel]
  templateContext: ->
    {
      filterCriterion: this.options.filterCriterion ? ""
    }
}

NoExerciceView = View.extend {
  template: no_exercice_view_tpl
  tagName: "a"
  className: "list-group-item"
}

ExerciceItemView = View.extend {
  tagName: "a",
  className: "list-group-item"
  template: exercice_item_view_tpl
  triggers: {
    "click": "exercice:show"
  }
  #onRender: () ->
  #  MathJax.Hub.Queue(["Typeset",MathJax.Hub,this.$el[0]])
}

ExercicesCollectionView = CollectionView.extend {
  className:"list-group"
  emptyView: NoExerciceView
  childView: ExerciceItemView
  childViewEventPrefix: "item"
  behaviors: [FilterList]
  filterKeys: ["title", "description", "keyWords"]
}

export { ExercicesPanel, ExercicesCollectionView }
