import { Behavior } from 'backbone.marionette'
import Syphon from 'backbone.syphon'

SortList = Behavior.extend {
  events: {
    "click a.js-sort":"sortFct"
  }

  sortFct: (e)->
    e.preventDefault()
    tag = $(e.currentTarget).attr("sort")
    collection = @view.collection
    if collection.comparatorAttr is tag
      collection.comparatorAttr = "inv_"+tag
      collection.comparator = (a,b)->
      if a.get(tag)>b.get(tag)
        -1
      else
        1
    else
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
    if criterion is "" or typeof @view.filterKeys is "undefined"
      @view.removeFilter(filterFct, options)
    else
      filterKeys = @view.filterKeys
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
    message = "Supprimer l'élément ##{@view.model.get("id")} ?";
    if confirm(message)
      @view.trigger("delete", @view)

  onRemove: ->
    view = @view
    view.$el.fadeOut( ()->
      view.trigger("model:destroy", view.model)
      view.remove()
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

export { SortList, FilterList, DestroyWarn, SubmitClicked }
