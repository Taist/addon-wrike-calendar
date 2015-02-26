module.exports =
  renderReminder: (container) ->
    React = require 'react'
    ReminderEditor = require './react/reminderEditor'
    React.render ( ReminderEditor {} ), container
