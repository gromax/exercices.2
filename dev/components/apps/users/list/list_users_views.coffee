import { View, CollectionView } from 'backbone.marionette'
import { DestroyWarn, FlashItem, FilterList, SortList, FilterPanel } from 'apps/common/behaviors.coffee'
import users_panel_tpl from 'templates/users/list/user-list-panel.tpl'
import no_item_tpl from 'templates/users/list/user-list-none.tpl'
import item_admin_view_tpl from 'templates/users/list/user-list-admin-item.tpl'
import item_prof_view_tpl from 'templates/users/list/user-list-prof-item.tpl'
import users_admin_view_tpl from 'templates/users/list/user-list-admin.tpl'
import users_prof_view_tpl from 'templates/users/list/user-list-prof.tpl'

UsersPanel = View.extend {
  template: users_panel_tpl
  showAddButton: false
  behaviors: [FilterPanel]
  triggers: {
    "click button.js-new": "user:new"
  }
  templateContext: ->
    {
      filterCriterion: @getOption("filterCriterion") || ""
      showAddButton: @getOption("showAddButton")
    }
}

NoUserView = View.extend {
  template: no_item_tpl
  tagName: "tr"
  className: "alert"
}

UserView = View.extend {
  tagName: "tr"
  adminMode: false
  behaviors: [DestroyWarn, FlashItem]
  getTemplate: (data)->
    if @getOption "adminMode"
      item_admin_view_tpl
    else
      item_prof_view_tpl
  triggers: {
    "click td a.js-edit": "edit"
    "click td a.js-editPwd": "editPwd"
    "click button.js-forgotten": "forgotten"
    "click button.js-sudo": "sudo"
    "click": "show"
  }
}

UsersCollectionView = CollectionView.extend {
  adminMode: false
  tagName: "table"
  className:"table table-hover"
  childView:UserView
  emptyView:NoUserView
  behaviors: [FilterList, SortList]
  childViewEventPrefix: "item"
  childViewContainer: "tbody"
  filterKeys: ["nom", "prenom", "nomClasse"]
  childViewOptions: ->
    {
      adminMode: @getOption "adminMode"
    }
  getTemplate: (data)->
    if @getOption "adminMode"
      users_admin_view_tpl
    else
      users_prof_view_tpl
}

export { UsersPanel, UsersCollectionView }
