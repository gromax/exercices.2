import { View, CollectionView } from 'backbone.marionette'
import off_tpl from 'templates/home/show/home-off.tpl'
import notFound_tpl from 'templates/home/show/home-off.tpl'
import admin_prof_tpl from 'templates/home/show/home-admin-prof.tpl'
import eleve_no_devoir_tpl from 'templates/home/show/devoirs-list-eleve-none.tpl'
import eleve_devoir_item_tpl from 'templates/home/show/devoirs-list-eleve-item.tpl'
import eleve_layout_tpl from 'templates/home/show/eleve-view-layout.tpl'
import eleve_unfinisheds_tpl from 'templates/home/show/unfinished-message.tpl'
import forgotten_key_tpl from 'templates/home/show/home-forgotten-key.tpl'
import { app } from 'app'

NotFoundView = View.extend {
  className: "jumbotron"
  template: notFound_tpl
}

OffPanel = View.extend {
  className: "jumbotron"
  template: off_tpl
  triggers: {
    "click a.js-login": "home:login"
  }
  onHomeLogin: (e) ->
    app.trigger("home:login")

  templateContext: ->
    {
      version: app.version
    }
}

AdminProfPanel = View.extend {
  className: "jumbotron"
  template: admin_prof_tpl
  events: {
    "click a.js-menu-item": "clickMenuItem"
  }

  clickMenuItem: (e) ->
    e.preventDefault()
    cible = $(e.currentTarget).attr("cible")
    app.trigger "#{cible}:list"

  templateContext: ->
    {
      adminMode: @getOption("adminMode") is true
      unread: app.Auth.get("unread")
    }
}

EleveNoDevoirView = View.extend {
  template:  eleve_no_devoir_tpl
  tagName: "a"
  className: "list-group-item"
}

EleveDevoirItem = View.extend {
  tagName: "a"
  template: eleve_devoir_item_tpl
  triggers: {
    "click": "devoir:show"
  }

  className: ->
    if not @model.get("actif") or @model.has("ficheActive") and not @model.get("ficheActive")
      "list-group-item list-group-item-danger"
    else
      "list-group-item"

  templateContext: ->
    faits = @getOption("faits").where({aUF: options.model.get("id")})
    exofiches = @getOption("exofiches").where({idFiche: options.model.get("idFiche")})
    {
      actif: data.actif && _.has(data,"ficheActive") && data.ficheActive
      note: @model.calcNote(exofiches, faits)
    }
}

EleveListeDevoirs = CollectionView.extend {
  className:"list-group"
  emptyView: EleveNoDevoirView
  childView: EleveDevoirItem
  childViewEventPrefix: "item"
  childViewOptions: (model, index)->
    {
      exofiches: @getOption("exofiches")
      faits: @getOption("faits")
    }
}

EleveLayout = View.extend {
  template: eleve_layout_tpl
  regions: {
    devoirsRegion: "#devoirs-region"
    unfinishedRegion: "#unfinished-region"
  }
}

UnfinishedsView = View.extend {
  tagName: "div",
  className: "alert alert-warning"
  template: eleve_unfinisheds_tpl
  templateContext: ->
    {
      number: @getOption("number")
    }
  triggers: {
    "click": "devoir:unfinished:show"
  }
}

ForgottenKeyView = View.extend {
  className: "jumbotron"
  template: forgotten_key_tpl
  triggers: {
    "click a.js-reinit-mdp": "forgotten:reinitMDP:click"
  }
}

export {
  OffPanel
  AdminProfPanel
  EleveListeDevoirs
  EleveLayout
  UnfinishedsView
  NotFoundView
  ForgottenKeyView
}
