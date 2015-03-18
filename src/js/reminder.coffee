app = require './app'

calendarUtils = require './calendarUtils'

class Reminder
  @_calendarsList: null
  _reminderData: null
  _defaultSettings: null
  _isAuthorizedOnGoogle: false

  constructor: (@_task) ->
  load: (callback) ->
    @_isAuthorizedOnGoogle = calendarUtils.authorized()
    unless @_isAuthorizedOnGoogle
      callback()
    else
      Reminder._loadCalendars =>
        @_loadReminderData -> callback()

  exists: -> @_reminderData?

  @_loadCalendars: (callback) ->
    if not @_calendarsList?
      calendarUtils.loadCalendars (calendarsList) =>
        @_calendarsList = calendarsList
        callback()
    else
      callback()

  _loadReminderData: (callback) ->
    @_reminderData = null

    app.api.userData.get "defaultSettings", (error, defaultSettingsData = {}) =>
      @_defaultSettings = defaultSettingsData

      app.api.companyData.get @_task.data.id, (error, existingReminderData) =>
        eventId = existingReminderData?.eventId
        calendarId = existingReminderData?.calendarId

        if not eventId? or not calendarId?
          callback()
        else
          calendarUtils.getEvent eventId, calendarId, (event) =>
            eventIsActual = event? and event.status != "cancelled"
            if eventIsActual
              @_reminderData =
                event: event
                calendarId: calendarId
            callback()

  _getBaseDateTime: -> new Date @_getRawBaseValue()

  _getRawBaseValue: -> @_task.data["startDate"] ? @_task.data["finishDate"]

  getDisplayData: ->
    unless @_isAuthorizedOnGoogle
      return null

    if @exists()
      startDate = new Date @_reminderData.event.start.dateTime
      startTime = startDate.getHours() * 60 + startDate.getMinutes()

      endDate = new Date @_reminderData.event.end.dateTime
      endTime = endDate.getHours() * 60 + endDate.getMinutes()

      htmlLink = @_reminderData.event.htmlLink

    else
      startDate = new Date
      startTime = endTime = 8 * 60

    currentSettings =
      if @_reminderData?
        calendarId: @_reminderData.calendarId
        reminders: @_reminderData.event.reminders
      else
        calendarId: @_defaultSettings.calendarId

    reminders = currentSettings?.reminders?.overrides ? []
    reminderMethod = reminders[0]?.method
    reminderMinutes = reminders[0]?.minutes

    usedNotifications = {}
    for notification in reminders
      usedNotifications[notification.method] = yes

    displayData = {
      calendars: Reminder._calendarsList,
      currentCalendar: currentSettings?.calendarId or Reminder._calendarsList?[0].id,

      startDate,
      startTime,
      endTime,
      reminderMethod,
      reminderMinutes,
      htmlLink,

      reminders,
      exists: @exists()
    }

    return displayData

  delete: (callback) ->
    if @exists()
      calendarUtils.deleteEvent @_reminderData.event.id, @_reminderData.calendarId, =>
        @_reminderData = null
        callback()

  _updateDateTime: (date, time) ->
    date.setHours Math.floor time / 60
    date.setMinutes time % 60
    return date

  upsert: (data, callback) ->
    eventStartDate = @_updateDateTime new Date(data.startDate), data.startTime
    eventEndDate = @_updateDateTime new Date(data.startDate), data.endTime
    @_updateEvent eventStartDate, eventEndDate, data.currentCalendar.id, data.reminders, ->
      console.log 'reminder updated'
      callback()

  set: (hours, minutes, calendarId, useSms, useEmail, callback) ->
    eventStartDate = @_getBaseDateTime()
    eventStartDate.setHours hours, minutes
    notifications = []
    if useSms
      notifications.push "sms"
    if useEmail
      notifications.push "email"
    @_setByDateTime eventStartDate, calendarId, notifications, callback

  _setByDateTime: (eventStartDate, newCalendarId, notifications, callback) ->
    @_updateEvent eventStartDate, eventStartDate, newCalendarId, null, callback

  _updateEvent: (eventStartDate, eventEndDate, newCalendarId, reminders, callback) ->
    eventData = @_reminderData?.event ? {}

    eventData.summary = "[Wrike] " + @_task.data["title"]
    eventData.start = {dateTime: eventStartDate} if eventStartDate
    eventData.end = {dateTime: eventEndDate} if eventEndDate
    # eventData.description = "Task link: https://www.wrike.com/open.htm?id=#{@_task.data.id}"

    eventData.reminders = { useDefault: no, overrides: reminders } if reminders

    newCallback = (newEvent) =>
      @_save newEvent, newCalendarId, callback

    if @_reminderData?
      calendarUtils.changeEvent @_reminderData.event.id, @_reminderData.calendarId, newCalendarId, eventData, newCallback
    else
      calendarUtils.createEvent newCalendarId, eventData, newCallback

  updateForTask: ->
    if @exists()
      @_updateEvent null, null, @_reminderData.calendarId, null, ->

  getIdFromLink: (link) ->
    matches = link.match /eid=([^&#]+)/
    if matches then matches[1] else ''

  _save: (newEvent, calendarId, callback) ->
    @_reminderData = {event: newEvent, calendarId}

    dataToSave = {
      taskId: @_task.data.id,
      taskTitle: @_task.data.title,
      calendarId
      eventId: newEvent.id,
      htmlLink: newEvent.htmlLink,
      hangoutLink: newEvent.hangoutLink,
    }
    @_defaultSettings = { calendarId }
    app.api.companyData.set @_task.data.id, dataToSave, =>
      app.api.userData.set "defaultSettings", @_defaultSettings, =>
        callback()
        app.api.companyData.set @getIdFromLink(newEvent.htmlLink), dataToSave, ->
        app.api.companyData.set @getIdFromLink(newEvent.hangoutLink), dataToSave, ->

module.exports = Reminder
