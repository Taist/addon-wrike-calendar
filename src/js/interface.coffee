module.exports =
  renderReminder: (container, reminder) ->
    React = require 'react'
    ReminderEditor = require './react/reminderEditor'

    onSave = (state) ->
      reminder.upsert state

    React.render ( ReminderEditor { reminder, onSave: onSave } ), container
