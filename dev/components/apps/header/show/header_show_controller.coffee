import { HeaderView } from 'apps/header/show/header_show_view.coffee'
import { app } from 'app'

export controller = {
  showHeader: ->
    navbar = new HeaderView()
    app.regions.getRegion('header').show(navbar)
    if app.Auth
      navbar.listenTo(
        app.Auth,
        "change",
        ()-> @logChange()
      )
    else
      alert "Erreur lors du chargement."
    navbar.listenTo(app,"header:loading", navbar.spin)
}
