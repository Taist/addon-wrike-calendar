wrikeUtils = require './wrikeUtils'
calendarUtils = require './calendarUtils'
Reminder = require './reminder'

reactContainer = null

start = (taistApi) ->
  window.app = app = require './app'
  app.api = taistApi

  reactContainer = $ '<div>'

  calendarUtils.init ->
    wrikeUtils.onCurrentTaskChange (task) -> draw task
    wrikeUtils.onCurrentTaskSave (updatedTask) -> updateReminderForTask updatedTask

draw = (task) ->
  # if wrikeUtils.currentUserIsResponsibleForTask task
  reminder = new Reminder task

  taskDurationSpan = $('.wspace-task-settings-bar')
  taskDurationSpan.after reactContainer
  reminder.load ->
    require('./interface').renderReminder reactContainer[0], reminder

updateReminderForTask = (task)->
  if calendarUtils.authorized()
    reminderToUpdate = new Reminder task
    reminderToUpdate.load ->
      reminderToUpdate.updateForTask()

module.exports = { start }
