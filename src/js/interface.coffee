module.exports =
  renderReminder: (container, reminder) ->
    React = require 'react'
    CalendarEventEditor = require './react/calendarEventEditor'

    onSave = (state) ->
      reminder.upsert state

    React.render ( CalendarEventEditor { reminder, onSave: onSave } ), container
