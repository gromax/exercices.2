import { View, CollectionView } from 'backbone.marionette'
import { DestroyWarn, FlashItem, SubmitClicked, FilterList, SortList } from 'apps/common/behaviors.coffee'
import users_panel_tpl from 'templates/users/list/user-list-panel.tpl'
import no_item_tpl from 'templates/users/list/user-list-none.tpl'
import item_admin_view_tpl from 'templates/users/list/user-list-admin-item.tpl'
import item_prof_view_tpl from 'templates/users/list/user-list-prof-item.tpl'
import users_admin_view_tpl from 'templates/users/list/user-list-admin.tpl'
import users_prof_view_tpl from 'templates/users/list/user-list-prof.tpl'

UsersPanel = View.extend {
  template: users_panel_tpl
  filterCriterion: ""
  showAddButton: false
  triggers: {
    "click button.js-new": "user:new"
  }
  events: {
    "submit #filter-form": "applyFilter"
  }
  ui: {
    criterion: "input.js-filter-criterion"
  }
  templateContext: ->
    {
      filterCriterion: @getOption("filterCriterion")
      showAddButton: @getOption("showAddButton")
    }

  applyFilter: (e)->
    e.preventDefault()
    criterion = @ui.criterion.val()
    @trigger("items:filter", criterion)

  onSetFilterCriterion: (criterion)->
    @ui.criterion.val(criterion)
}

NoUserView = View.extend {
  template: no_item_tpl
  tagName: "tr"
  className: "alert"
}

UserView = View.extend {
  tagName: "tr"
  behaviors: [DestroyWarn, FlashItem]
  getTemplate: (data)->
    if app.Auth.isAdmin()
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

  getTemplate: (data)->
    if @getOption("adminMode")
      users_admin_view_tpl
    else
      users_prof_view_tpl

}




export { UsersPanel, UsersCollectionView }
