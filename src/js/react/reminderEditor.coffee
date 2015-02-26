React = require 'react'

{ div, span, select } = React.DOM

Calendar = require 'react-input-calendar'

TimeSelector = React.createFactory React.createClass
  getInitialState: () ->
    minimalInterval: 30

  timeStringToMinutes: (time) ->
    parts = time.match /^(\d{1,2})(\D(\d{2}))?/

    unless parts
      return 0

    hours = parseInt parts[1], 10
    minutes = parseInt parts[3], 10

    hours * 60 + minutes - minutes / @state.minimalInterval

  generateOptions: ->
    # startTime

  render: ->
    span {}, @timeStringToMinutes('1:17');
    # select {}, @generateOptions()

ReminderEditor = React.createFactory React.createClass
  onChange: (newDate) ->
    console.log 'New date is', newDate

  render: ->
    div {},
      Calendar {
        format: "DD.MM.YYYY"
        date: new Date
        onChange: @onChange
        closeOnSelect: true
      }
      div { style: display: 'inline-block' },
        TimeSelector { startTime: '12:30' }

module.exports = ReminderEditor
