module.exports =
  renderReminder: (container, reminder) ->
    React = require 'react'
    ReminderEditor = require './react/reminderEditor'

    onSave = (state) ->
      console.log 'onSave', state

    React.render ( ReminderEditor { reminder, onSave: onSave } ), container
