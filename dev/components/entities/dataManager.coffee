import Radio from "backbone.radio"

API = {
  timeout:1500000
  stored_data:{}
  stored_time:{}

  getCustomEntities: (ask) ->
    t= Date.now()
    defer = $.Deferred()
    toFetch = _.filter ask, (item)-> (typeof API.stored_data[item] is "undefined") or (typeof API.stored_time[item] is "undefined") or (t-API.stored_time[item]>API.timeout)
    if toFetch.length is 0
      # Pas de fetch requis => on renvoie les résultats
      defer.resolve.apply(null,_.map(ask, (item)-> API.stored_data[item]))
    else
      request = $.ajax("api/customData/"+toFetch.join("&"),{
        method:'GET'
        dataType:'json'
      })

      request.done( (data)->
        for colName in ask
          colObj = false
          switch colName
            when "devoirs" then colObj = require("entities/devoirs.coffee")
            #when "userfiches" then colObj = require("entities/userfiches.coffee")
            #when "exofiches" then colObj = require("entities/exofiches.coffee")
            #when "faits" then colObj = require("entities/faits.coffee")
            when "users" then colObj = require("entities/users.coffee")
            #when "exams" then colObj = require("entities/exams.coffee")
            #when "messages" then colObj = require("entities/messages.coffee")
            when "classes" then colObj = require("entities/classes.coffee")
          if (colObj isnt false) and (data[colName])
            API.stored_data[colName] = new colObj.Collection(data[colName], { parse:true })
            API.stored_time[colName] = t
        defer.resolve.apply(null,_.map(ask, (item)-> API.stored_data[item] ))
      ).fail( (response)->
        defer.reject(response)
      )
    return promise = defer.promise()
  getItem: (entityName, idItem) ->
    defer = $.Deferred()
    fetching = API.getCustomEntities([entityName])
    $.when(fetching).done( (items)->
      defer.resolve(items.get(idItem))
    )
    return promise = defer.promise()
  getUser: (id) ->
    return API.getItem("users",id)
  getClasse: (id) ->
    return API.getItem("classes",id)
  getMe: ->
    defer = $.Deferred()
    t= Date.now()
    '''
    if (typeof API.stored_data.me isnt "undefined") and (typeof API.stored_time.me isnt "undefined") and (t-API.stored_time.me<API.timeout)
      defer.resolve(API.stored_data.me)
    else
      request = $.ajax("api/me",{
        method:'GET'
        dataType:'json'
      })
      request.done( (data)->
        User = require("entities/user").Item
        API.stored_data.me = new User(data, {parse:true})
        API.stored_time.me = t
        defer.resolve(API.stored_data.me)
      ).fail( (response)->
        defer.reject(response)
      )
    '''
    return defer.promise()

  purge: ->
    API.stored_data = {}

  userDestroyUpdate: (idUser)->
    # Assure le cache quand un user est supprimé
    if API.stored_data.userfiches
      userfichesToPurge = API.stored_data.userfiches.where({idUser : idUser})
      API.stored_data.userfiches.remove(userfichesToPurge)
    if (API.stored_data.faits)
      delete API.stored_data.faits
    if (API.stored_data.messages)
      delete API.stored_data.messages

  ficheDestroyUpdate: (idDevoir) ->
    # Assure le cache quand un user est supprimé
    if API.stored_data.userfiches
      userfichesToPurge = API.stored_data.userfiches.where({idFiche : idDevoir})
      API.stored_data.userfiches.remove(userfichesToPurge)
    if API.stored_data.exofiches
      exofichesToPurge = API.stored_data.exofiches.where({idFiche : idDevoir})
      API.stored_data.exofiches.remove(exofichesToPurge)
    if API.stored_data.faits
      delete API.stored_data.faits
    if (API.stored_data.messages)
      delete API.stored_data.messages

  aUEDestroyUpdate: ->
    if (API.stored_data.messages)
      delete API.stored_data.messages
}

channel = Radio.channel('entities')
channel.reply('custom:entities', API.getCustomEntities )
channel.reply('data:purge', API.purge )
channel.reply('classe:entity', API.getClasse )
channel.reply('user:entity', API.getUser )
channel.reply('user:me', API.getMe )
channel.reply('user:destroy:update', API.userDestroyUpdate )
channel.reply('fiche:destroy:update', API.ficheDestroyUpdate )
channel.reply('aUE:destroy:update', API.aUEDestroyUpdate )
