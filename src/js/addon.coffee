taistApi = null
reminder = null

container = null
reactContainer = null

wrikeUtils = require './wrikeUtils'
calendarUtils = require './calendarUtils'
Reminder = require './reminder'

start = (ta) ->
  window.app = app = require './app'
  app.api = taistApi = ta

  container = $ '<span class="taist-reminders-container">'
  reactContainer = $ '<div>'

  calendarUtils.init ->
    wrikeUtils.onCurrentTaskChange (task) -> draw task
    wrikeUtils.onCurrentTaskSave (updatedTask) -> updateReminderForTask updatedTask

draw = (task) ->
  if wrikeUtils.currentUserIsResponsibleForTask task
    reminder = new Reminder task
    if reminder.canBeSet()

      drawRemindersContainer()

      if not calendarUtils.authorized()
        drawAuthorization()
      else
        reminder.load ->
          drawReminderView()

updateReminderForTask = (task)->
  if calendarUtils.authorized()
    reminderToUpdate = new Reminder task
    reminderToUpdate.load ->
      reminderToUpdate.updateForTask()

drawAuthorization = ->
  taistApi.log 'drawing authorization'
  authButton = $ '<button>',
    text: 'Authorize Google Calendar'
    click: ->
      calendarUtils.authorize ->
        #TODO: использовать task из текущего view - он заведомо есть
        currentTask = wrikeUtils.currentTask()
        if currentTask?
          draw currentTask
      return false

  container.append authButton

drawRemindersContainer = ->
  taistApi.log 'drawing reminders container'
  taskDurationSpan = $('.wspace-task-settings-bar')

  taskDurationSpan.after reactContainer
  require('./interface').renderReminder reactContainer[0]

  taskDurationSpan.after container

drawReminderEditControl = ->
  container.html ''
  reminderEditControl = $ '<span></span>'

  displayData = reminder.getDisplayData()

  smsCheck = createNotificationCheck "Sms", "sms", displayData
  emailCheck = createNotificationCheck "E-mail", "email", displayData

  hoursSelect = createTimeSelect displayData.hoursRange, displayData.hours
  minutesSelect = createTimeSelect displayData.minutesRange, displayData.minutes
  setLink = $ '<a></a>',
    text: "Set"
    click: ->
      useSms = smsCheck.check.is(':checked')
      useEmail = emailCheck.check.is(':checked')
      reminder.set hoursSelect.val(), minutesSelect.val(), calendarSelect.val(), useSms, useEmail, ->
        drawReminderView()
  cancelLink = $ "<a></a>",
    text: 'Cancel'
    click: -> drawReminderView()

  calendarSelect = createCalendarSelect displayData.calendars, displayData.currentCalendar

  reminderEditControl.append icons.reminderExists, ': ', hoursSelect, '-', minutesSelect, ' ', smsCheck.check, smsCheck.label, ' ', emailCheck.check, emailCheck.label, ' ', calendarSelect, ' ', setLink, ' / ', cancelLink

  container.append reminderEditControl

createNotificationCheck = (caption, id, displayData) ->
  check: $('<input>', {type: "checkbox", checked: displayData.usedNotifications[id], id: "taist-reminder-#{id}"})
  label: $ "<label for=\"Taist-reminder-#{id}\">#{caption}</label>"

createTimeSelect = (timeValues, currentValue) ->
  closestValue = timeValues[0]
  for timeValue in timeValues
    if timeValue <= currentValue
      closestValue = timeValue
  timeSelect = $ '<select></select>'
  for timeValue in timeValues
    option = $ '<option></option>',
      text: timeValue
      val: timeValue
      selected: timeValue is closestValue
    timeSelect.append option

  return timeSelect

createCalendarSelect = (calendarsList, currentCalendarId) ->
  calendarSelect = $ '<select></select>'
  for calendar in calendarsList
    calendarSelect.append $ '<option></option>',
      text: calendar.summary,
      val: calendar.id,
      selected: currentCalendarId == calendar.id

  return calendarSelect

drawReminderView = ->
  container.html ''
  linkText = null
  iconHtml = null

  if reminder.exists()
    displayData = reminder.getDisplayData()

    iconHtml = icons.reminderExists
    linkText = """<span class="taist-reminders-linkText">#{displayData.hours}:#{displayData.minutes}"""
  else
    iconHtml = icons.noReminder
    linkText = ""

  editLink = $ "<a></a>",
    click: -> drawReminderEditControl()
    style: "border-bottom-style:none;"

  editLink.append iconHtml, linkText

  container.append editLink

  if reminder.exists()
    deleteLink = $ '<a></a>',
      text: 'X'
      click: ->
        reminder.delete ->
          drawReminderView()
      title: 'Delete'

  container.append ' (', deleteLink, ')'

icons =
  noReminder: '<img class="taist-reminders-reminder-icon" title="Add reminder" alt="Add reminder" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAACXBIWXMAAAsTAAALEwEAmpwYAAACf2lUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNC40LjAiPgogICA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPgogICAgICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgICAgICAgICB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iPgogICAgICAgICA8ZGM6dGl0bGU+CiAgICAgICAgICAgIDxyZGY6U2VxPgogICAgICAgICAgICAgICA8cmRmOmxpIHhtbDpsYW5nPSJ4LWRlZmF1bHQiPmdseXBoaWNvbnM8L3JkZjpsaT4KICAgICAgICAgICAgPC9yZGY6U2VxPgogICAgICAgICA8L2RjOnRpdGxlPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIj4KICAgICAgICAgPHhtcDpDcmVhdG9yVG9vbD5BZG9iZSBQaG90b3Nob3AgQ1M2IChNYWNpbnRvc2gpPC94bXA6Q3JlYXRvclRvb2w+CiAgICAgIDwvcmRmOkRlc2NyaXB0aW9uPgogICA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgopxlZkAAAB0ElEQVRIDa1W23HCMBCMTf7jDqIOcDqgA1pwKsAMj2++GRigglBC6EAdBDogHUABQHYZiZHkkzFJNCMknXb3dHeycXK5XJ6atOFwuASuZ7Cr2WxWNuGlTUDE4CDKYt25tcXG5F4E4/E4P51OkyRJuq4IeJtWqzWZTqdb1x7Oax0MBoMCwh8hyV3D0ft8Pl+7NncedcCTn8/nL4B36G2XFM7TNH2LRRKtAdMCIYpr9NpmsCIm6oA5R/8Ey94cUYDGsD4uUHQwGo06BCG/mQuum1tOiBEdIPc5gN9wwLFRM5wKVnSAkHOI7zGqCiNiIEfaEh0AmIOwxfgqkSK2hxzUXsuIA5FTiSBWrIioZ5a4FQcolgLriJ557AYLw/WQ3pPc7/czvF/2KLA2BRbD9hT8xREPnVosFgdrvkVgxDU27Oaj4tR8wQE1tbhguznAxhJrhdNvcfrudfd3P22jdWUnZVkyLRqrNsQ3fxR3j7RDujqMgOEo7vyjOOUUepaiIHtMCnS+Of+rUaugtnSLOoiE/wUcGd29Yu+Q2gP+EzTrh7Ro9xbxjXm3s04hTrKFGK6fm+QEl2CCr4qei4VthXXp2qS5lyIJYG3ms6Uw63XTz5YfqiH1WdCp6QMAAAAASUVORK5CYII=" />'
  reminderExists: '<img class="taist-reminders-reminder-icon" title="Reminder set at" alt="Reminder set at" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAACXBIWXMAAAsTAAALEwEAmpwYAAACf2lUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNC40LjAiPgogICA8cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPgogICAgICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgICAgICAgICB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iPgogICAgICAgICA8ZGM6dGl0bGU+CiAgICAgICAgICAgIDxyZGY6U2VxPgogICAgICAgICAgICAgICA8cmRmOmxpIHhtbDpsYW5nPSJ4LWRlZmF1bHQiPmdseXBoaWNvbnM8L3JkZjpsaT4KICAgICAgICAgICAgPC9yZGY6U2VxPgogICAgICAgICA8L2RjOnRpdGxlPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIj4KICAgICAgICAgPHhtcDpDcmVhdG9yVG9vbD5BZG9iZSBQaG90b3Nob3AgQ1M2IChNYWNpbnRvc2gpPC94bXA6Q3JlYXRvclRvb2w+CiAgICAgIDwvcmRmOkRlc2NyaXB0aW9uPgogICA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgopxlZkAAAB5klEQVRIDa1W3W3CMBC+Qy1UKlXpBM0G0A3YoCuEl/48wQiMAE+t+gIjtBtkg8IGdIJSCalVEFw/OxBwck5SqZYi+z5/9519PlthEaEqjR+aIxLpWy7zWJ5Xgyp+tSoky9lKkHKPxymoD7hsB3zX7BDJkJhuHQmhNyIeystq5uAZozAAxENimWR8XFO4hyBTFzxY3gB25SzvoM7xtQ8uykj4xreTgjNAWow4c6RIZiDLzWCJ6Q+Q5Pw1rRzVfQdmz+eIqwbgx4uu5TC3jriFw9Qnw1ID0HaDyqEPEjJ9tZb45Lh6AGII8wLlGeQ8vIDxyTdPAKycaQb6dd7Fi/wpQHFZ6jFUn9wOfIela7qo5psLQBuTd/5CebZc9wqW9XV5zk3m3lWL6usFxCOcAQKV3GBXCxYWFp8GMvlc7qfSHSTicYTK2U+qOd076r1cUj2OrNaOkAbAxAgrCFD7s9zLqav50HailUwzhS2kxawc6TBPcMG19yl68DnF9W6Nzn5wmBxY0v+JQ44Do12Tp+8F8h5S8iyj+5eGJ15Co61UUdxFiA5WgN6WatlhQ4yX4EbwmyEt0XEVoSKl9DPnlOVpWJZj7BNELW+N9ZDvz/sOscFj2AMHUwwnRcp8CiW/LRRagGla9bflF7nn2hBRMZnFAAAAAElFTkSuQmCC">'

module.exports = { start }
