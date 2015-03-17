React = require 'react'
CalendarEventEditor = require './react/calendarEventEditor'

wrikeUtils = require './wrikeUtils'
calendarUtils = require './calendarUtils'

module.exports =
  renderReminder: (container, reminder) ->

    onSave = (state) ->
      reminder.upsert state, ->
        render()

    onDelete = ->
      reminder.delete ->
        render()

    onAuthorize = ->
      calendarUtils.authorize ->
        currentTask = wrikeUtils.currentTask()
        reminder.load ->
          render()

    render = ->
      React.render ( CalendarEventEditor { reminder, onSave, onDelete, onAuthorize } ), container

    render()
