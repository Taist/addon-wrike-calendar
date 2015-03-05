module.exports =
  renderReminder: (container, reminder) ->
    React = require 'react'
    CalendarEventEditor = require './react/calendarEventEditor'

    onSave = (state) ->
      reminder.upsert state

    onDelete = ->
      reminder.delete ->
        React.render ( CalendarEventEditor { reminder, onSave, onDelete } ), container

    React.render ( CalendarEventEditor { reminder, onSave, onDelete } ), container
