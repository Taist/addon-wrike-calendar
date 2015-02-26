React = require 'react'

{ div } = React.DOM

ReminderEditor = React.createFactory React.createClass
  render: ->
    div {}, 'Reminder Editor'

module.exports = ReminderEditor
