import { ArianeView } from "apps/ariane/show/ariane_show_view.coffee"
import { app } from 'app'

export controller = {
  showAriane: ->
    if app.Ariane
      view = new ArianeView { collection: app.Ariane.collection }
      app.regions.getRegion('ariane').show(view)
    else
      console.log "L'objet fil d'ariane n'est pas initialisé."
}
