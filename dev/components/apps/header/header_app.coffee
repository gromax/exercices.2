import { app } from 'app'

API = {
  showHeader: ->
    require("apps/header/show/header_show_controller.coffee").controller.showHeader()
}

app.on "header:show", ()-> API.showHeader()
