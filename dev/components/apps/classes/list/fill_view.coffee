define ["jst","marionette", "backbone.syphon"], (JST,Marionette) ->
	View = Marionette.View.extend {
		template: window.JST["classes/list/classe-fill-form"]
		events: {
			"click button.js-submit": "submitClicked"
		}

		initialize: ->
			@title = "Nouvelle classe pour #{@options.nomProf}";

		submitClicked: (e)->
			e.preventDefault()
			data = Backbone.Syphon.serialize(this)
			@trigger("form:submit", data)
	}

	return View
