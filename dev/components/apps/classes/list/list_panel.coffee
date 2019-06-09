define ["jst", "marionette"], (JST, Marionette)->
	Panel = Marionette.View.extend {
		template: window.JST["classes/list/classe-list-panel"]
		serializeData: ->
			{
				showAddButton: @options.showAddButton is true
				addToProf: @options.addToProf ? false
			}

		triggers: {
			"click button.js-new": "classe:new"
		}
	}

	return Panel
