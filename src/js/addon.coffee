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
    waitForEventContainer '[data-eid]'
    waitForEventContainer '.bubblemain:visible'

renderInProgress = no

waitForEventContainer = (selector) ->
  app.api.wait.repeat ->
    shouldStartRendering = $(selector).length > 0 and
    $('.taist-calendar-link', selector).length is 0 and
    renderInProgress is no

    renderInProgress = yes if shouldStartRendering

    return shouldStartRendering

  , (container) ->
    renderLinkOnEditPage container

renderLinkOnEditPage = (container) ->
  if location.href.indexOf('/calendar/') > 0
    hangoutLink = $ "[href*='hceid=']", container
    matches = hangoutLink?.attr('href')?.match /hceid=([^&#]+)/
    hangoutId = matches?[1]

    if hangoutId
      app.api.companyData.get hangoutId, (error, event) ->
        tableRow = hangoutLink.parents 'tr:first'
        wrikeLinkContainer = tableRow.clone().insertAfter tableRow
        wrikeLabel = $('<div>').addClass('rtc-label').text('Wrike task')
        $('th', wrikeLinkContainer).empty().append wrikeLabel

        wrikeLink = $('<a>')
        .attr 'href', "https://www.wrike.com/workspace.htm#t=#{event.taskId}"
        .attr 'target', event.taskId
        .addClass 'taist-calendar-link'
        .text event.taskTitle or 'Wrike task'
        $('td', wrikeLinkContainer).empty().append wrikeLink

        renderInProgress = no

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
