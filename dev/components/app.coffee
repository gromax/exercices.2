import { Application, View } from 'backbone.marionette'
import Radio from 'backbone.radio'

Manager = Application.extend {
  region: '#app'
  getCurrentRoute: () -> Backbone.history.fragment
  navigate: (route, options) ->
    options or (options = {})
    Backbone.history.navigate(route, options)
  onBeforeStart: (app, options) ->
    RegionContainer = View.extend {
      el: "#app-container"
      regions: {
        header: "#header-region"
        ariane: "#ariane-region"
        message: "#message-region"
        main: "#main-region"
        dialog: "#dialog-region"
      }
    }

    @regions = new RegionContainer()

    @regions.getRegion("dialog").onShow = (region,view) ->
      self = @
      require 'jquery-ui/dialog.js'
      closeDialog = () ->
        self.stopListening()
        self.empty()
        self.$el.dialog("destroy")
        view.trigger("dialog:closed")
      @listenTo(view, "dialog:close", closeDialog)
      @$el.dialog {
        modal: true
        title: view.title
        width: "auto"
        close: (e, ui) ->
          closeDialog()
      }

  onStart: (app, options) ->
    @version = VERSION
    self = @
    historyStart = () ->
      require('apps/home/home_app.coffee')
      require('apps/ariane/ariane_app.coffee')
      require('apps/header/header_app.coffee')
      require('apps/classes/classes_app.coffee')
      # import des différentes app
      self.trigger "header:show"
      self.trigger "ariane:show"
      if Backbone.history
        Backbone.history.start()
        if self.getCurrentRoute() is ""
          self.trigger "home:show"

    # import de l'appli entities, session
    require('entities/session.coffee')

    channel = Radio.channel('entities')
    @Auth = channel.request('session:entity', historyStart)
    @Ariane = require("entities/ariane.coffee").ArianeController
    @settings = {}
}

export app = new Manager()
