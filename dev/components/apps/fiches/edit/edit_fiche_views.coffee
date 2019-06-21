import { View, CollectionView } from 'backbone.marionette'
import { SubmitClicked, NewItem, EditItem, ToggleItemValue, DestroyWarn, FlashItem, SortList, FilterList, FilterPanel } from 'apps/common/behaviors.coffee'
import layout_tpl from 'templates/fiches/edit/edit-fiche-layout.tpl'
import edit_fiche_tpl from 'templates/fiches/edit/fiche-description-edit.tpl'
import devoir_list_none_tpl from 'templates/fiches/edit/devoirs-list-none.tpl'
import devoir_item_view_tpl from 'templates/fiches/edit/devoirs-list-item.tpl'
import devoir_list_view_tpl from 'templates/fiches/edit/devoirs-list.tpl'
import eleve_list_none_tpl from 'templates/fiches/edit/add-devoir-eleve-none.tpl'
import eleve_item_view_tpl from 'templates/fiches/edit/add-devoir-eleve-item.tpl'
import eleve_list_view_tpl from 'templates/fiches/edit/add-devoir-eleves-list.tpl'
import add_devoir_panel_tpl from 'templates/fiches/edit/add-devoir-panel.tpl'
import tabs_panel_tpl from 'templates/fiches/edit/tabs-panel.tpl'
import exam_panel_tpl from 'templates/fiches/edit/exam-panel.tpl'
import exam_list_none_tpl from 'templates/fiches/edit/exam-list-none.tpl'
import exam_list_item_tpl from 'templates/fiches/edit/exam-list-item.tpl'
import exam_list_tpl from 'templates/fiches/edit/exam-list.tpl'
import exam_edit_tpl from 'templates/fiches/edit/exam-edit.tpl'


FicheLayout = View.extend {
  template: layout_tpl
  regions: {
    tabsRegion: "#tabs-region"
    panelRegion: "#panel-region"
    contentRegion: "#content-region"
  }
}

NewFicheView = View.extend {
  title: "Nouvelle fiche"
  template: edit_fiche_tpl
  behaviors: [ SubmitClicked, NewItem ]
}

EditFicheView = View.extend {
  template: edit_fiche_tpl
  behaviors: [SubmitClicked, EditItem]
  title: "Modifier le fiche"
  generateTitle: false
  onRender: ->
    if @getOption "generateTitle"
      $title = $("<h1>", { text: @title })
      @$el.prepend($title)
}

TabsPanel = View.extend {
  template: tabs_panel_tpl
  panel: 0
  triggers: {
    "click a.js-devoir": "tab:devoir"
    "click a.js-exercices": "tab:exercices"
    "click a.js-notes": "tab:notes"
    "click a.js-eleves": "tab:eleves"
    "click a.js-exams": "tab:exams"
  }
  templateContext: ->
    {
      panel: @getOption "panel"
    }
  setPanel: (panel) ->
    @options.panel = panel
    $tabs = @$el.find("a.nav-link")
    $tabs.removeClass "active"
    $tabs[panel].addClass "active"
}

#---------------------------
# views pour liste devoirs -
#---------------------------

NoDevoirView = View.extend {
  template: devoir_list_none_tpl
  tagName: "tr"
  className: "alert"
}

DevoirItemView = View.extend {
  tagName: "tr"
  errorCode: "???"
  template: devoirs-list-item
  behaviors: [
    ToggleItemValue
    DestroyWarn
    FlashItem
  ]
  templateContext: ->
    data = _.clone(this.model.attributes)
    note = String @model.calcNote(@getOption("exofiches"), @getOption("faits"), @getOption("notation"))
    if note.length is 1
      note = "0#{note}"
    { note }
  triggers: {
    "click button.js-actif": "toggle:activity"
    "click": "show"
  }
}

DevoirsCollectionView = CollectionView.extend {
  tagName: "table"
  className:"table table-hover"
  template: devoirs-list
  childView:DevoirItemView
  emptyView:NoDevoirView
  childViewEventPrefix: "item"
  childViewContainer: "tbody"
  behaviors: [SortList]
  childViewOptions: (model, index) ->
    {
      exofiches: @getOption "exofiches"
      faits: @getOption "faits"
      notation: @getOption "notation"
    }
  viewFilter: (view, index, children) ->
    return view.model.get("idFiche") is @getOption("idFiche")

}

#------------------------
# views pour add devoir -
#------------------------

NoEleveView = View.extend {
  template: eleve_list_none_tpl
  tagName: "tr"
  className: "alert"
}

EleveItemView = View.extend {
  tagName: "tr"
  counter: 0
  template: eleve_item_view_tpl
  triggers: {
    "click button.js-addDevoir": "item:add"
  }
  templateContext: ->
    {
      counter: @getOption "counter"
    }
  onUpCounter: ->
    @options.counter = @getOption("counter")+1
}

ElevesCollectionView = CollectionView.extend {
  tagName: "table"
  className: "table table-hover"
  template: eleve_list_view_tpl
  childView: EleveItemView
  emptyView: NoEleveView
  behaviors: [SortList, FilterList]
  childViewEventPrefix: "item"
  childViewContainer: "tbody"
  filterKeys: ["nom", "prénom", "nomClasse"]

  initialize: ->
    # on fait un préfiltrage des devoirs pour accélerer le comptage pour chaque élève
    @options.devoirs = @getOption("devoirs").where({ idFiche: @getOption("idFiche") })

  childViewOptions: (model, index) ->
    {
      counter: _.where(@getOption("devoirs", { idUser: model.get("id") }).length
    }

}

AddDevoirPanel = View.extend {
  template: add_devoir_panel_tpl
  behaviors: [FilterPanel]
}

#-------------------
# views pour exams -
#-------------------

ExamPanel = View.extend {
  template: exam_panel_tpl
  triggers: {
    "click button.js-new": "exam:new"
  }
}

NoExamView = View.extend {
  template: exam_list_none_tpl
  tagName: "tr"
  className: "alert"
}

ExamItemView = View.extend {
  tagName: "tr"
  errorCode: "???"
  template: exam_list_item_tpl
  behaviors: [DestroyWarn, ToggleItemValue, FlashItem]
  triggers: {
    "click button.js-edit": "edit",
    "click button.js-lock": "item:lock"
    "click": "item:show"
  }
}

ExamsCollectionView = CollectionView.extend {
  tagName: "table"
  className:"table table-hover"
  template: exam_list_tpl
  childView: ExamItemView
  emptyView: NoExamView
  childViewEventPrefix: "item"
  behaviors: [SortList]
  filterView: (child, index, collection) ->
    # On affiche que les exofiches qui ont sont dans la bonne fiche
    child.get("idFiche") is @getOption("idFiche")

}

ExamEditView = View.extend {
  title: "Modification"
  behaviors: [SubmitClicked, EditItem]
  template: exam_edit_tpl
}

export { FicheLayout, NewFicheView, EditFicheView, TabsPanel, DevoirsCollectionView, ElevesCollectionView, AddDevoirPanel, ExamsCollectionView, ExamPanel, ExamEditView }
