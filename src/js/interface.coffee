React = require 'react'
CalendarEventEditor = require './react/calendarEventEditor'

wrikeUtils = require './wrikeUtils'
calendarUtils = require './calendarUtils'

module.exports =
  renderReminder: (container, reminder) ->

    onSave = (state) ->
      reminder.upsert state

    onDelete = ->
      reminder.delete ->
        render()

    onAutorize = ->
      calendarUtils.authorize ->
        currentTask = wrikeUtils.currentTask()
        reminder.load ->
          render()

    render = ->
      React.render ( CalendarEventEditor { reminder, onSave, onDelete, onAutorize } ), container

    render()
