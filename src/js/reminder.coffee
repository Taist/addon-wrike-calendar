app = require './app'

calendarUtils = require './calendarUtils'

class Reminder
  @_calendarsList: null
  _reminderData: null
  _defaultSettings: null
  constructor: (@_task) ->
  load: (callback) ->
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

    app.api.userData.get "defaultSettings", (error, defaultSettingsData) =>
      @_defaultSettings = defaultSettingsData
      app.api.userData.get @_task.data.id, (error, existingReminderData) =>
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

  canBeSet: -> @_getRawBaseValue()?

  _getBaseDateTime: -> new Date @_getRawBaseValue()

  _getRawBaseValue: -> @_task.data["startDate"] ? @_task.data["finishDate"]

  getDisplayData: ->
    [hours, minutes] =
    if @exists()
      addLeadingZero = (number) -> if number < 10 then "0" + number else number

      reminderTime = new Date @_reminderData.event.start.dateTime

      startTime = "#{reminderTime.getHours()}:#{reminderTime.getMinutes()}"

      endDate = new Date @_reminderData.event.end.dateTime
      endTime = "#{endDate.getHours()}:#{endDate.getMinutes()}"

      [(addLeadingZero reminderTime.getHours()), (addLeadingZero reminderTime.getMinutes())]
    else
      ['08', '00']

    hoursRange = ['06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21',
                  '22', '23']
    minutesRange = ['00', '15', '30', '45']

    currentSettings =
      if @_reminderData?
        calendardId: @_reminderData.calendarId
        reminders: @_reminderData.event.reminders
      else @_defaultSettings

    usedNotifications = {}
    for notification in currentSettings?.reminders?.overrides ? []
      usedNotifications[notification.method] = yes

    return {
      hours,
      minutes,
      hoursRange,
      minutesRange,
      usedNotifications,
      calendars: Reminder._calendarsList,
      currentCalendar: currentSettings?.calendarId ? Reminder._calendarsList?[0].id,

      startTime,
      endTime
    }

  delete: (callback) ->
    if @exists()
      calendarUtils.deleteEvent @_reminderData.event.id, @_reminderData.calendarId, =>
        @_reminderData = null
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
    eventData = @_reminderData?.event ? {}

    eventData.summary = @_task.data["title"]
    eventData.start = {dateTime: eventStartDate}
    eventData.end = {dateTime: eventStartDate}
    eventData.description = "Task link: https://www.wrike.com/open.htm?id=#{@_task.data.id}"

    if notifications?
      eventData.reminders =
        useDefault: no
        overrides: []

      for method in notifications
        eventData.reminders.overrides.push {method, minutes: 0}

    newCallback = (newEvent) =>
      @_save newEvent, newCalendarId, callback

    if @_reminderData?
      calendarUtils.changeEvent @_reminderData.event.id, @_reminderData.calendarId, newCalendarId, eventData, newCallback
    else
      calendarUtils.createEvent newCalendarId, eventData, newCallback

  updateForTask: ->
    if @exists()
      startDateTime = @_task.data["startDate"]
      reminderDateTime = @_getBaseDateTime()
      startDateTime.setHours reminderDateTime.getHours(), reminderDateTime.getMinutes()

      @_setByDateTime startDateTime, @_reminderData.calendarId, null, ->

  _save: (newEvent, calendarId, callback) ->
    @_reminderData = {event: newEvent, calendarId}
    @_defaultSettings = {calendarId, reminders: newEvent.reminders}
    app.api.userData.set @_task.data.id, {eventId: newEvent.id, calendarId}, =>
      app.api.userData.set "defaultSettings", @_defaultSettings, -> callback()

module.exports = Reminder
