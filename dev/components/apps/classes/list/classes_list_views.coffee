import { View, CollectionView } from 'backbone.marionette'
import { DestroyWarn, FlashItem, SubmitClicked } from 'apps/common/behaviors.coffee'
import no_item_tpl from 'templates/classes/list/classe-list-none.tpl'
import item_view_tpl from 'templates/classes/list/classe-list-item.tpl'
import classes_view_tpl from 'templates/classes/list/classe-list.tpl'
import panel_tpl from 'templates/classes/list/classe-list-panel.tpl'
import fill_tpl from 'templates/classes/list/classe-fill-form.tpl'

NoItemView = View.extend {
  template: no_item_tpl
  tagName: "tr"
  className: "alert"
}

ItemView = View.extend {
  tagName: "tr"
  template: item_view_tpl
  behaviors: [
    DestroyWarn
    {
      behaviorClass: FlashItem
      preCss: "table-"
    }
  ]
  triggers: {
    "click td a.js-edit": "item:edit"
    "click td a.js-fill": "item:fill"
    "click td a.js-classe-prof": "item:classe-prof"
    "click": "item:show"
  }

  templateContext: ->
    showProfName = @getOption("showProfName")
    {
      showProfName
      linkProf: showProfName and (@model.get("idOwner") isnt app.Auth.get("id"))
      showFillClassButton: @getOption("showFillClassButton")
    }
}

ClassesCollectionView = CollectionView.extend {
  tagName:'table'
  className:"table table-hover"
  template: classes_view_tpl
  childView:ItemView
  emptyView:NoItemView
  childViewEventPrefix: "item"
  childViewContainer: "tbody"
  templateContext: ->
    {
      showProfName: @getOption("showProfName")
    }
  childViewOptions: (model)->
    {
      showFillClassButton: @getOption("showFillClassButton")
      showProfName: @getOption("showProfName")
    }
}

ClassesPanel = View.extend {
  template: panel_tpl
  showAddButton: false
  addToProf: false
  templateContext: ->
    {
      showAddButton: @getOption("showAddButton")
      addToProf: @getOption("addToProf")
    }
  triggers: {
    "click button.js-new": "classe:new"
  }
}

FillClasseView = View.extend {
  template: fill_tpl
  behaviors: [SubmitClicked]
  events: {
    "click button.js-submit": "submitClicked"
  }

  initialize: ->
    @title = "Nouvelle classe pour #{@getOption('nomProf')}";
}

export { ClassesCollectionView, ClassesPanel, FillClasseView }
