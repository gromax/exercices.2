import { View, CollectionView } from 'backbone.marionette'
import { SubmitClicked, NewItem } from 'apps/common/behaviors.coffee'
import test_mdp_tpl from 'templates/users/signin/test-mdp-form.tpl'
import signin_tpl from 'templates/users/edit/userpwd-form.tpl'
import no_classe_tpl from 'templates/users/signin/signin-no-classe.tpl'
import classe_item_tpl from 'templates/users/signin/signin-classe-item.tpl'


TestMdpView = View.extend {
  template: test_mdp_tpl
  behaviors: [SubmitClicked]
  initialize: ->
    @title = "Rejoindre la classe "+@model.get("nomClasse")
}

SigninView = View.extend {
  title: "Rejoindre une classe"
  template: signin_tpl
  errorCode: "026"
  behaviors: [SubmitClicked, NewItem]
  initialize: ->
    @title = "Rejoindre la classe "+@model.get("nomClasse")
  }
  templateContext: ->
    {
      showPWD: true
      showPref: false
      ranks: false
      editorIsAdmin: false
    }
}

SigninNoClasseView = View.extend {
  template: no_classe_tpl
}

SigninClasseItemView = View.extend {
  template: signin-classe-item
  tagName: "a"
  className: "list-group-item list-group-item-action js-join"
  triggers: {
    "click": "join"
  }
}

SigninClassesCollectionView = CollectionView.extend {
  tagName: "div"
  className: "list-group"
  childView: SigninClasseItemView
  emptyView: SigninNoClasseView
  childViewEventPrefix: "item"
}


export { TestMdpView, SigninView, SigninClassesCollectionView }
