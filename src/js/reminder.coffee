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

        console.log 'existingReminderData', existingReminderData

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

    if @exists()
      addLeadingZero = (number) -> if number < 10 then "0" + number else number

      startDate = new Date @_reminderData.event.start.dateTime
      startTime = "#{startDate.getHours()}:#{addLeadingZero startDate.getMinutes()}"

      endDate = new Date @_reminderData.event.end.dateTime
      endTime = "#{endDate.getHours()}:#{addLeadingZero endDate.getMinutes()}"

    else
      startDate = new Date
      startTime = endTime = '8:00'


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
      reminderMinutes
    }

    console.log displayData
    return displayData

  delete: (callback) ->
    if @exists()
      calendarUtils.deleteEvent @_reminderData.event.id, @_reminderData.calendarId, =>
        @_reminderData = null
        callback()

  _updateDateTime: (date, time) ->
    timeParts = time.match(/\d+/g) or []
    date.setHours(timeParts[0] or 0)
    date.setMinutes(timeParts[1] or 0)
    return date

  upsert: (data) ->
    console.log 'reminder.upsert', data
    eventStartDate = @_updateDateTime new Date(data.startDate), data.startTime
    eventEndDate = @_updateDateTime new Date(data.startDate), data.endTime
    @_updateEvent eventStartDate, eventEndDate, data.currentCalendar.id, data.reminderMethod, data.reminderMinutes, ->
      console.log 'reminder updated'

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
    @_updateEvent eventStartDate, eventStartDate, newCalendarId, null, null, callback

  _updateEvent: (eventStartDate, eventEndDate, newCalendarId, method, minutes, callback) ->
    eventData = @_reminderData?.event ? {}

    eventData.summary = @_task.data["title"]
    eventData.start = {dateTime: eventStartDate} if eventStartDate
    eventData.end = {dateTime: eventEndDate} if eventEndDate
    eventData.description = "Task link: https://www.wrike.com/open.htm?id=#{@_task.data.id}"

    if method
      eventData.reminders = { useDefault: no, overrides: [] } unless eventData.reminders?.overrides
      eventData.reminders.overrides[0] = { method, minutes }

    newCallback = (newEvent) =>
      @_save newEvent, newCalendarId, callback

    if @_reminderData?
      calendarUtils.changeEvent @_reminderData.event.id, @_reminderData.calendarId, newCalendarId, eventData, newCallback
    else
      calendarUtils.createEvent newCalendarId, eventData, newCallback

  updateForTask: ->
    if @exists()
      @_updateEvent null, null, @_reminderData.calendarId, null, null, ->

  _save: (newEvent, calendarId, callback) ->
    @_reminderData = {event: newEvent, calendarId}
    @_defaultSettings = {calendarId, reminders: newEvent.reminders}
    app.api.userData.set @_task.data.id, {eventId: newEvent.id, calendarId}, =>
      app.api.userData.set "defaultSettings", @_defaultSettings, -> callback()

module.exports = Reminder
