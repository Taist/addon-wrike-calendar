React = require 'react'

{ div } = React.DOM

Calendar = require 'react-input-calendar'

TimeIntervalSelector = require './TimeIntervalSelector'

ReminderEditor = React.createFactory React.createClass
  onChangeDate: (newDate) ->
    console.log 'New date is', newDate

  render: ->
    div {},
      Calendar {
        format: "DD.MM.YYYY"
        date: new Date
        onChange: @onChangeDate
        closeOnSelect: true
      }
      div { style: display: 'inline-block' },
        TimeIntervalSelector {}

module.exports = ReminderEditor
