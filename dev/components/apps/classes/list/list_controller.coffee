define [
	"app",
	"marionette",
	"apps/common/alert_view",
	"apps/common/list_layout",
	"apps/classes/list/list_panel",
	"apps/classes/list/list_view",
	"apps/classes/new/new_view",
	"apps/classes/edit/edit_view",
	"apps/classes/list/fill_view"
], (
	app,
	Marionette,
	AlertView,
	Layout,
	Panel,
	ListView,
	NewView,
	EditView,
	FillView
) ->

	Controller = Marionette.Object.extend {
		channelName: 'entities',

		list_prof: (id) ->
			app.trigger("header:loading", true)
			channel = @getChannel()
			mainFct = @listMain

			require ["entities/classe", "entities/dataManager"], (Classe)->
				fetching = channel.request("custom:entities", ["classes", "users"])
				$.when(fetching).done( (classesList, usersList)->
					prof = usersList.get(id)

					if prof isnt undefined
						listItemsLayout = new Layout()
						listItemsPanel = new Panel()
						app.Ariane.add [
							{ text:"Classes de #{prof.get("nomComplet")}", e:"classes:prof", data:id, link:"classes/prof:#{id}" },
						]
						mainFct(prof, classesList, Classe)
					else
						view = new AlertView({message: "Cet utilisateur n'existe pas.", dismiss:false })
						app.regions.getRegion('main').show(view)
				).fail( (response)->
					if response.status is 401
						alert("Vous devez vous (re)connecter !");
						app.trigger("home:logout");
					else
						alertView = new AlertView()
						app.regions.getRegion('main').show(alertView)
				).always( ()->
					app.trigger("header:loading", false)
				)

		list: ->
			app.trigger("header:loading", true)
			channel = @getChannel()
			mainFct = @listMain
			require ["entities/classe", "entities/dataManager"], (Classe)->
				fetching = channel.request("classes:entities")
				$.when(fetching).done( (classesList)->
					mainFct(false, classesList, Classe)
				).fail( (response)->
					if response.status is 401
						alert("Vous devez vous (re)connecter !");
						app.trigger("home:logout");
					else
						alertView = new AlertView()
						app.regions.getRegion('main').show(alertView)
				).always( ()->
					app.trigger("header:loading", false)
				)

		listMain: (prof, classesList, Classe) ->
			listItemsLayout = new Layout()
			listItemsPanel = new Panel {
				addToProf: if prof isnt false then prof.get("nomComplet") else false
				showAddButton: prof isnt false or app.Auth.isProf()
			}

			if prof isnt false
				idProf = prof.get("id")
				filterFct = (child, index, collection) ->
					return child.get("idOwner") is idProf
			else
				filterFct = false

			listItemsView = new ListView {
				collection: classesList
				filterFct: filterFct
				showFillClassButton: app.Auth.isAdmin()
				showProfName: prof is false and app.Auth.isAdmin()
			}

			listItemsLayout.on "render", ()->
				listItemsLayout.getRegion('panelRegion').show(listItemsPanel)
				listItemsLayout.getRegion('itemsRegion').show(listItemsView)

			listItemsPanel.on "classe:new", ()->
				newItem = new Classe()
				view = new NewView {
					model: newItem
				}

				view.on "form:submit", (data)->
					if prof isnt false then data.idOwner = prof.get("id")
					savingItem = newItem.save(data)
					if savingItem
						$.when(savingItem).done( ()->
							classesList.add(newItem);
							view.trigger("dialog:close");
							listItemsView.flash(newItem);
						).fail( (response)->
							switch response.status
								when 422
									view.triggerMethod("form:data:invalid", response.responseJSON.ajaxMessages)
								when 401
									alert("Vous devez vous (re)connecter !")
									view.trigger("dialog:close")
									app.trigger("home:logout")
								else
									alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/002]")
						)
					else
						view.triggerMethod("form:data:invalid",newItem.validationError)

				app.regions.getRegion('dialog').show(view)

			if (prof is false)
				# en mode classe/prof, je ne permet pas la navigation qui serait de toute façon déroutante
				listItemsView.on "item:show", (childView, args)->
					model = childView.model
					app.trigger("classe:show", model.get("id"))

			listItemsView.on "item:fill", (childView, args)->
				model = childView.model
				view = new FillView {
					nomProf: model.get("nomOwner")
				}

				view.on "form:submit", (data)->
					fillingItem = model.fill(data.list)
					$.when(fillingItem).done( ()->
						childView.render()
						view.trigger("dialog:close")
						childView.flash("success")
					).fail( (response)->
						switch response.status
							when 401
								alert("Vous devez vous (re)connecter !")
								view.trigger("dialog:close")
								app.trigger("home:logout")
							else
								alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/003]")
					)
				app.regions.getRegion('dialog').show(view)


			listItemsView.on "item:edit", (childView, args)->
				model = childView.model
				view = new EditView {
					model:model
				}

				view.on "form:submit", (data)->
					updatingItem = model.save(data)
					if updatingItem
						$.when(updatingItem).done( ()->
							childView.render()
							view.trigger("dialog:close")
							childView.flash("success")
						).fail( (response)->
							switch response.status
								when 422
									view.triggerMethod("form:data:invalid", response.responseJSON.ajaxMessages)
								when 401
									alert("Vous devez vous (re)connecter !")
									view.trigger("dialog:close")
									app.trigger("home:logout")
								else
									alert("Erreur inconnue. Essayez à nouveau ou prévenez l'administrateur [code #{response.status}/003]")
						)
					else
						@triggerMethod("form:data:invalid", model.validationError)

				app.regions.getRegion('dialog').show(view)

			listItemsView.on "item:delete", (childView,e)->
				#childView.remove()
				model = childView.model
				idUser = model.get("id")
				if confirm("Supprimer la classe « #{model.get('nom')} » ?")
					destroyRequest = model.destroy()
					app.trigger("header:loading", true)
					$.when(destroyRequest).done( ()->
						childView.remove()
					).fail( (response)->
						alert("Erreur. Essayez à nouveau !")
					).always( ()->
						app.trigger("header:loading", false)
					)

			app.regions.getRegion('main').show(listItemsLayout)
	}

	return new Controller()
