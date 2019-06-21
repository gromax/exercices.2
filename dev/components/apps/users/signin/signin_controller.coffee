import { MnObject } from 'backbone.marionette'
import { AlertView } from 'apps/common/common_views.coffee'
import { SigninClassesCollectionView, TestMdpView, SigninView } from 'apps/users/signin/signin_views.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: "entities"
  showSignin: ->
    app.trigger "header:loading", true
    channel = @getChannel()
    require "entities/dataManager.coffee"

    fetchingClasses = channel.request "classes:entities"
    $.when(fetchingClasses).done( (classes) ->
      listClassesView = new SigninClassesCollectionView {
        collection: classes
      }

      listClassesView.on "item:join", (childView) ->
        classe = childView.model
        User = require("entities/users.coffee").Item
        newUser = new User { nomClasse:classe.get("nom"), idClasse:classe.get("id") }
        mdp_view = new TestMdpView { model: newUser }

        mdp_view.on "form:submit", (data_test) ->
          testingMdp = newUser.testClasseMdp(data_test.mdp)
          app.trigger("header:loading", true)
          $.when(testingMdp).done( ->
            newUser.set "classeMdp", data_test.mdp
            mdp_view.trigger "dialog:close"
            signin_eleve_view = new SigninView { model: newUser }
            signin_eleve_view.on "model:save:success", (model) ->
              alertView = new AlertView {
                title: "Inscription réussie"
                message: "Vous avez créé un compte. Vous pouvez maintenant vous connecter."
                dismiss: true
                type: "success"
              }
              app.trigger("home:show")
              app.regions.getRegion('message').show(alertView)
            app.regions.getRegion('dialog').show(signin_eleve_view);
          ).fail( (response) ->
            if response.status is 422
              mdp_view.trigger "form:data:invalid", { mdp:"Mot de passe incorrect." }
            else
              alert "Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/027]"
          ).always( ->
            app.trigger"header:loading", false
          )
        app.regions.getRegion('dialog').show(mdp_view)
      app.regions.getRegion('main').show(listClassesView)
    ).fail( (response)->
      alertView = new AlertView()
      app.regions.getRegion('main').show(alertView)
    ).always( ->
      app.trigger "header:loading", false
    )
}

export controller = new Controller()
