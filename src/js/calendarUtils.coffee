app = require './app'

calendarUtils =
  _client: null
  _auth: null
  _api: null
  _authorized: false
  init: (callback) ->
    jsonpCallbackName = 'calendarUtilsInitAfterApiLoad'
    window[jsonpCallbackName] = =>
      delete window[jsonpCallbackName]
      @_waitForGapiAndInit callback

    $('body').append "<script src=\"https://apis.google.com/js/client.js?onload=#{jsonpCallbackName}\"></script>"

  _waitForGapiAndInit: (callback) ->
    gapi = window["gapi"]
    @_client = gapi.client
    @_auth = gapi.auth
    @_client.setApiKey 'AIzaSyCLQdexpRph5rbV4L3V_9i0rXRRNiib304'

    window.setTimeout (=> @_getExistingAuth callback), 0

  _getExistingAuth: (callback) ->  @_getAuth true, callback

  authorize: (callback) -> @_getAuth false, callback

  _getAuth: (useExistingAuth, callback) ->
    authOptions =
      client_id: '181733347279'
      scope: 'https://www.googleapis.com/auth/calendar'
      immediate: useExistingAuth
    @_auth.authorize authOptions, (authResult) =>
      @_authorized = authResult and not authResult.error?
      if @_authorized
        @_loadCalendarApi callback
      else
        callback()

  _loadCalendarApi: (callback) ->
    @_client.load "calendar", "v3", =>
      @_api = @_client["calendar"]
      callback()

  authorized: -> @_authorized

  loadCalendars: (callback) ->
    request = @_api["calendarList"].list
      minAccessRole: "writer"
      showHidden: true

    request
    .then (response) =>
      callback response.result.items

  getEvent: (eventId, calendarId, callback) -> @_accessEvent "get", {calendarId, eventId}, callback

  deleteEvent: (eventId, calendarId, callback) ->  @_accessEvent "delete", {calendarId, eventId}, callback

  changeEvent: (eventId, currentCalendarId, newCalendarId, eventData, callback) ->
    app.api.log "changing: ", arguments
    @_accessEvent "update", {resource: eventData, calendarId: currentCalendarId, eventId}, (newEvent) =>
      if currentCalendarId != newCalendarId
        @_moveEvent eventId, currentCalendarId, newCalendarId, callback
      else
        callback newEvent

  createEvent: (calendarId, eventData, callback) -> @_accessEvent "insert", {calendarId, resource: eventData}, callback

  _moveEvent: (eventId, currentCalendarId, newCalendarId, callback) ->
    app.api.log "moving: ", arguments
    @_accessEvent "move", {calendarId: currentCalendarId, destination: newCalendarId, eventId}, callback

  _accessEvent: (method, params, callback) ->
    # params.eventId = "duehudhueh"
    @_api.events[method](params)
    .then (response) ->
      if response.error?
        app.api.error "couldn't #{method} event: ", params, eventOrResponse.error
      else
        callback response.result

module.exports = calendarUtils
