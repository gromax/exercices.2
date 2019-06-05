import Backbone from 'backbone'
import Radio from 'backbone.radio'

Session = Backbone.Model.extend {
	urlRoot: "api/session"
	initialize: ->
		that = @
		# Hook into jquery
		# Use withCredentials to send the server cookies
		# The server must allow this through response headers
		$.ajaxPrefilter( ( options, originalOptions, jqXHR) ->
			options.xhrFields = {
				withCredentials: true
			}
		)

	validate: (attrs, options)->
		errors = []
		if not attrs.identifiant
			errors.push { success:false, message:"L'email ne doit pas être vide" }
		if not attrs.pwd
			errors.push { success:false, message:"Le mot de passe ne doit pas être vide" }
		if not _.isEmpty(errors)
			return errors

	toJSON: ->
		return {
			identifiant: @get("identifiant")
			pwd: @get("pwd")
		}

	parse: (data)->
		if data.logged
			logged = data.logged
		else
			logged = data
		if not logged.nomClasse
			logged.nomClasse = "N/A"
		logged.unread = Number logged.unread ? 0
		logged.isRoot = (logged.rank is "Root")
		logged.isAdmin = (logged.rank is "Root") or (logged.rank is "Admin")
		logged.isProf = (logged.rank is "Prof");
		logged.isEleve = (logged.rank is "Élève");
		logged.logged_in = (logged.rank isnt "Off");
		if logged.logged_in
			logged.nomComplet = logged.prenom+" "+logged.nom
		else
			logged.nomComplet = ""
		logged.isOff = not logged.logged_in
		if typeof logged.pref is "string" and logged.pref isnt ""
			logged.pref = JSON.parse(logged.pref)
		else logged.pref = {
			mathquill:true
		}
		return logged

	refresh: (data)->
		@set(@parse(data))

	getAuth: (callback)->
		# getAuth is wrapped around our router
		# before we start any routers let us see if the user is valid
		@fetch({
			success: callback
		})

	getWithForgottenKey: (key) ->
		that = @
		defer = $.Deferred()
		request = $.ajax("api/forgotten/"+key,{
			method:'GET'
			dataType:'json'
		})
		request.done( (response)->
			that.refresh(response)
			defer.resolve()
		).fail( (response)->
			defer.reject(response)
		)
		return defer.promise()

	isAdmin: ->
		rank = @get("rank")
		return (rank is "Root") or (rank is "Admin")

	isProf: ->
		@get("rank") is "Prof"

	isEleve: ->
		@get("rank") is "Élève"

	isOff: ->
		@get("isOff")

	sudo: (id) ->
		that = @
		defer = $.Deferred()
		if not @isAdmin()
			defer.reject({status:403})
		else
			request = $.ajax "api/session/sudo/#{id}", {
				method: "POST"
				dataType: "json"
			}
			request.done( (response)->
				that.refresh(response)
				Radio.channel('entities').request("data:purge")
				defer.resolve()
			).fail( (response)->
				defer.reject(response)
			)
		return defer.promise()

	mapItem: (itemsList) ->
		itemsList = itemsList ? {}
		rank = @get("rank")
		switch rank
			when "Root"
				if _.has(itemsList,"Root")
					return itemsList["Root"]
				else if _.has(itemsList,"Admin")
					return itemsList["Admin"]
				else
					return itemsList.def
			when "Admin"
				if _.has(itemsList,"Admin")
					return itemsList["Admin"]
				else
					return itemsList.def
			when "Prof"
				if _.has(itemsList,"Prof")
					return itemsList["Prof"]
				else
					return itemsList.def
			when "Élève"
				if _.has(itemsList,"Eleve")
					return itemsList["Eleve"]
				else
					return itemsList.def
			else
				if _.has(itemsList,"Off")
					return itemsList["Off"]
				else
					return itemsList.def
}

API = {
	getSession: (callback)->
		Auth = new Session()
		Auth.on "destroy", ()->
			@unset("id")
			channel = Radio.channel('entities')
			channel.request("data:purge")
		Auth.getAuth(callback)
		return Auth

	sendForgottenEmail: (email)->
		return request = $.ajax(
			"api/forgotten",
			{
				method:'POST'
				dataType:'json'
				data: { email:email }
			}
		)
}

channel = Radio.channel('entities')
channel.reply('session:entity', API.getSession )
channel.reply('forgotten:password', API.sendForgottenEmail )

module.exports = Session
