import { app } from 'app'

API = {
  showHeader: ->
    require("apps/header/show/header_show_controller.coffee").controller.showHeader()
}

app.on "header:show", ()-> API.showHeader()

app.on "loading:up", ->
  unless app.ajaxCount then app.ajaxCount = 0
  app.ajaxCount++
  app.trigger "header:loading", true

app.on "loading:down", ->
  app.ajaxCount--
  if app.ajaxCount <= 0
    app.trigger "header:loading", false

