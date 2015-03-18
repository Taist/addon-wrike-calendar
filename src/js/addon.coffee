wrikeUtils = require './wrikeUtils'
calendarUtils = require './calendarUtils'
Reminder = require './reminder'

reactContainer = null

start = (taistApi, entryPoint) ->
  window.app = app = require './app'
  app.api = taistApi

  if entryPoint is 'wrike'
    reactContainer = $ '<div>'

    calendarUtils.init ->
      wrikeUtils.onCurrentTaskChange (task) -> draw task
      wrikeUtils.onCurrentTaskSave (updatedTask) -> updateReminderForTask updatedTask

  else if entryPoint is 'google'
    taistApi.wait.elementRender '[data-eid]', (element) ->
      eventId = element.attr('data-eid');
      if location.href.indexOf(eventId) > 0
        taistApi.companyData.get eventId, (error, event) ->
          hangoutLink = $ "[href*='#{event.eventId}']"
          tableRow = hangoutLink.parents 'tr:first'
          container = tableRow.clone().insertAfter tableRow
          $('th label', container).text 'Wrike task'

          wrikeLink = $('<a>')
          .attr 'href', "https://www.wrike.com/workspace.htm#&t=#{event.taskId}"
          .attr 'target', event.taskId
          .addClass 'taist-calendar-link' 
          .text event.taskTitle or 'Wrike task'
          $('td div', container).empty().append wrikeLink

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
