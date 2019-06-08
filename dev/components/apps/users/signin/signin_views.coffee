import { View } from 'backbone.marionette'
import { SubmitClicked } from 'apps/common/behaviors.coffee'
import test_mdp_tpl from 'templates/home/signin/test-mdp-form.tpl'

TestMdpView = View.extend {
  template: test_mdp_tpl
  behaviors: [SubmitClicked]
  initialize: ->
    @title = "Rejoindre la classe "+@model.get("nomClasse")
}

# NewEleveView => déplacer dans l'application users
NewEleveView = View.extend {
  title: "Nouvel Utilisateur"
  behaviors: [SubmitClicked]
  initialize: ->
    @title = "Rejoindre la classe "+@model.get("nomClasse")
  }
  showPWD: true
  ranks: false
}


export { TestMdpView, NewEleveView }
