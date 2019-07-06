import { MnObject } from 'backbone.marionette'
import { LoginView } from 'apps/home/login/login_view.coffee'
import { app } from 'app'

Controller = MnObject.extend {
  channelName: "entities"
  showLogin: ->
    channel = @getChannel()
    view = new LoginView { generateTitle: true, showForgotten:true }
    view.on "form:submit", (data) ->
      openingSession = app.Auth.save(data)
      if openingSession
        app.trigger "loading:up"
        $.when(openingSession).done( (response)->
          app.trigger "home:show"
        ).fail( (response)->
          app.trigger "data:fech:fail", response, "025"
        ).always( ->
          app.trigger "loading:down"
        )
      else
        view.triggerMethod("form:data:invalid", app.Auth.validationError)

    view.on "login:forgotten", (email)->
      # Vérification de l'email
      re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
      if !re.test(email)
        view.triggerMethod("form:data:invalid", [{ success:false, message: "L'email n'est pas valide"}])
      else
        app.trigger "loading:up"
        sendingMail = channel.request("forgotten:password", email)
        sendingMail.done( (response)->
          app.trigger "show:message:success", {
            title:"Email envoyé"
            message:"Un message a été envoyé à l'adresse #{email}. Veuillez vérifier dans votre boîte mail et cliquer sur le lien contenu dans le mail. [Cela peut prendre plusieurs minutes...]"
          }
        ).fail( (response)->
          app.trigger "data:fech:fail", response, "033"
        ).always( ->
          app.trigger "loading:down"
        )
    app.regions.getRegion('main').show(view)

  showReLogin: (options)->
    that = @
    view = new LoginView { generateTitle: false, showForgotten:false, title:"Reconnexion" }
    this.listenTo view,"dialog:closed", ->
      options?.fail?()
    view.on "form:submit", (data) ->
      if data.identifiant is "" or data.identifiant is app.Auth.get("identifiant")
        # C'est bien la même personne qui se reconnecte
        openingSession = app.Auth.save(data)
        if openingSession
          app.trigger "loading:up"
          $.when(openingSession).done( (response)->
            that.stopListening()
            view.trigger "dialog:close"
            options?.done?()
          ).fail( (response)->
            app.trigger "data:fech:fail", response, "025"
          ).always( ->
            app.trigger "loading:down"
          )
        else
          view.triggerMethod("form:data:invalid", app.Auth.validationError)
      else
        view.triggerMethod("form:data:invalid", [{success:false, message:"C'est une reconnexion : Vous devez réutiliser le même identifiant que précedemment."}])
    app.regions.getRegion('dialog').show(view)
}

export controller = new Controller()
