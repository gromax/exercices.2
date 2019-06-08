import { app } from 'app'

app.on "ariane:show", (data) ->
  require("apps/ariane/show/ariane_show_controller.coffee").controller.showAriane()
