import { Behavior } from 'backbone.marionette'
import Syphon from 'backbone.syphon'

SortList = Behavior.extend {
  events: {
    "click a.js-sort":"sortFct"
  }

  sortFct: (e)->
    e.preventDefault()
    @view.$el.find(".js-sort-icon").remove()
    $sortEl = $(e.currentTarget)
    tag = $sortEl.attr("sort")
    collection = @view.collection
    if collection.comparatorAttr is tag
      $sortEl.append("<span class='js-sort-icon'>&nbsp;<i class='fa fa-sort-amount-desc'></i></span>")
      collection.comparatorAttr = "inv_"+tag
      collection.comparator = (a,b)->
        if a.get(tag)>b.get(tag)
          -1
        else
          1
    else
       $sortEl.append("<span class='js-sort-icon'>&nbsp;<i class='fa fa-sort-amount-asc'></i></span>")
       collection.comparatorAttr = tag
       collection.comparator = tag
    collection.sort()

}

FilterList = Behavior.extend {
  initialize: ->
    if (typeof @view.options.filterCriterion isnt "undefined") and (@view.options.filterCriterion isnt "")
      @view.trigger("set:filter:criterion",@view.options.filterCriterion, { preventRender: true })
  onSetFilterCriterion: (criterion, options) ->
    criterion = criterion.normalize('NFD').replace(/[\u0300-\u036f]/g, "").toLowerCase()
    if criterion is "" or typeof @view.getOption("filterKeys") is "undefined"
      @view.removeFilter(options)
    else
      filterKeys = @view.getOption("filterKeys")
      parseFct = (model) ->
        reductionFct = (m,k) ->
          m+model.get(k)
        _.reduce(filterKeys, reductionFct, "").normalize('NFD').replace(/[\u0300-\u036f]/g, "").toLowerCase()
      filterFct = (view, index, children) ->
        parseFct(view.model).indexOf(criterion) isnt -1
      @view.setFilter(filterFct, options)
}

DestroyWarn = Behavior.extend {
  ui: {
    destroy: '.js-delete'
  }

  events: {
    'click @ui.destroy': 'warnBeforeDestroy'
  }

  warnBeforeDestroy: (e) ->
    e.preventDefault()
    e.stopPropagation() # empêche la propagation d'un click à l'élément parent dans le dom
    model = @view.model
    message = "Supprimer l'élément ##{model.get("id")} ?";
    if confirm(message)
      app = require('app').app
      destroyRequest = model.destroy()
      app.trigger("header:loading", true)
      $.when(destroyRequest).done( ->
        view = @view
        view.$el.fadeOut( ->
          view.trigger("model:destroy", view.model)
          view.remove()
        )
      ).fail( (response)->
        alert("Erreur. Essayez à nouveau !")
      ).always( ()->
        app.trigger("header:loading", false)
      )
}

SubmitClicked = Behavior.extend {
  ui: {
    submit: 'button.js-submit'
  }
  options: {
    messagesDiv: false # si on précise une cible, les messages sont concentrés là, sinon ils sont associés à l'input de name correspondant à l'erreur
  }
  events: {
    'click @ui.submit': 'submitClicked'
  }

  submitClicked: (e) ->
    e.preventDefault()
    e.stopPropagation() # empêche la propagation d'un click à l'élément parent dans le dom
    data = Syphon.serialize(@)
    @view.trigger("form:submit", data)

  onFormDataInvalid: (errors) ->
    $view = @view.$el
    clearFormErrors = () ->
      $form = $view.find("form")
      $form.find("div.alert").each( ()->
        $(this).remove()
      )
      $form.find(".help-inline.text-danger").each( ()->
        $(this).remove()
      )
      $form.find(".form-group.has-error").each( ()->
        $(this).removeClass("has-error")
      )

    if @getOption("messagesDiv")
      $container = $view.find("#messages")
      markErrors = (value)->
        $errorEl
        if value.success
          $errorEl = $("<div>", { class: "alert alert-success", role:"alert", text: value.message })
        else
          $errorEl = $("<div>", { class: "alert alert-danger", role:"alert", text: value.message })
        $container.append($errorEl)
    else
      markErrors = (value, key) ->
        $controlGroup = $("input[name='#{key}']",$view).closest(".form-group")
        $controlGroup.addClass("has-error")
        if $.isArray(value)
          value.forEach( (el)->
            $errorEl = $("<span>", { class: "help-inline text-danger", text: el })
            $controlGroup.append($errorEl)
          )
        else
          $errorEl = $("<span>", { class: "help-inline text-danger", text: value })
          $controlGroup.append($errorEl)

    clearFormErrors()
    _.each(errors, markErrors)
}

FlashItem = Behavior.extend {
  onFlashSuccess: ->
    @flash("success")
  onFlashError: ->
    @flash("danger")
  flash: (cssClass) ->
    $view = @$el
    if @view.tagName is "tr"
      preCss = "table-" # dans Bootstrap
    else
      preCss = ""
    $view.hide().toggleClass(preCss+cssClass).fadeIn(800, ()->
      setTimeout( ()->
        $view.toggleClass(preCss+cssClass)
      , 500)
    )
}

NewItem = Behavior.extend {
  onFormSubmit: (data)->
    newItem = @view.model
    savingItem = newItem.save(data)
    if savingItem
      app = require('app').app
      app.trigger "header:loading", true
      view = @view
      $.when(savingItem).done( ->
        view.getOption("collection")?.add newItem
        view.trigger "dialog:close"
        view.getOption("listView")?.children.findByModel(newItem)?.trigger("flash:success")
      ).fail( (response)->
        switch response.status
          when 422
            view.trigger "form:data:invalid", response.responseJSON.errors
          when 401
            alert("Vous devez vous (re)connecter !")
            view.trigger("dialog:close")
            app.trigger("home:logout")
          else
            if errorCode = view.getOption("errorCode")
              errorCode = "/#{errorCode}"
            else
              errorCode = ""
            alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}#{errorCode}]")
      ).always(()->
        app.trigger("header:loading", false)
      )
    else
      @view.trigger "form:data:invalid",newItem.validationError
}

EditItem = Behavior.extend {
  updatingFunctionName: "save"
  onFormSubmit: (data)->
    fct = @view.getOption "onFormSubmit"
    if (typeof fct is "function")
      fct(data)
    else
      @onEditSubmit data
  onEditSubmit: (data)->
    model = @view.model
    updatingFunctionName = @getOption "updatingFunctionName"
    updatingItem = model[updatingFunctionName](data)
    if updatingItem
      app = require('app').app
      app.trigger "header:loading", true
      view = @view
      $.when(updatingItem).done( ->
        itemView = view.getOption("itemView")
        onSuccess = view.getOption("onSuccess")
        itemView?.render()
        view.trigger "dialog:close" # si ce n'est pas une vue dialog, le trigger ne fait rien
        itemView?.trigger("flash:success")
        onSuccess?(model,data)
      ).fail( (response)->
        switch response.status
          when 422
            view.trigger "form:data:invalid", response.responseJSON.errors
          when 401
            alert("Vous devez vous (re)connecter !")
            view.trigger("dialog:close")
            app.trigger("home:logout")
          else
            if errorCode = view.getOption("errorCode")
              errorCode = "/#{errorCode}"
            else
              errorCode = ""
            alert "Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}#{errorCode}]"
      ).always(()->
        app.trigger "header:loading", false
      )
    else
      @view.trigger "form:data:invalid",model.validationError
}

ToggleItemValue = Behavior.extend {
  onToggleAttribute: (attributeName) ->
    model = @view.model
    attributeValue = model.get(attributeName)
    model.set(attributeName, !attributeValue)
    updatingItem = model.save()
    self = @
    if updatingItem
      app = require('app').app
      app.trigger "header:loading", true
      $.when(updatingItem).done( ->
        self.view.render()
        self.view.trigger "flash:success"
      ).fail( (response)->
        if response.status is 401
          alert "Vous devez vous (re)connecter !"
          app.trigger "home:logout"
        else
          if errorCode = self.view.getOption("errorCode")
            errorCode = "/#{errorCode}"
          else
            errorCode = ""
          alert "Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}#{errorCode}]"
      ).always( ()->
        app.trigger "header:loading", false
      )
    else
      @view.trigger "flash:error"
}

FilterPanel = Behavior.extend {
  ui: {
    criterion: "input.js-filter-criterion"
    form: "#filter-form"
  }
  events: {
    "submit @ui.form": "applyFilter"
  }
  applyFilter: (e)->
    e.preventDefault()
    criterion = @ui.criterion.val()
    @view.trigger("items:filter", criterion)
  onSetFilterCriterion: (criterion)->
    @ui.criterion.val(criterion)
}

export { SortList, FilterList, DestroyWarn, SubmitClicked, FlashItem, NewItem, EditItem, ToggleItemValue, FilterPanel }
