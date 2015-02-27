module.exports =
  renderReminder: (container, reminder) ->
    React = require 'react'
    ReminderEditor = require './react/reminderEditor'
    React.render ( ReminderEditor { reminder } ), container
