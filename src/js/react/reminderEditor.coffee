React = require 'react'

{ div, select, option } = React.DOM

Calendar = require 'react-input-calendar'

TimeIntervalSelector = require './TimeIntervalSelector'

ReminderEditor = React.createFactory React.createClass
  onChangeDate: (newDate) ->
    console.log 'New date is', newDate

  updateState: (props) ->
    @setState currentCalendar: props.reminder.getDisplayData().currentCalendar

  componentWillMount: () ->
    @updateState @props

  componentWillReceiveProps: ( nextProps ) ->
    @updateState nextProps

  render: ->
    reminderData = @props.reminder.getDisplayData()
    console.log 'render', reminderData
    console.log @state.currentCalendar

    div {},
      Calendar {
        format: "DD.MM.YYYY"
        date: new Date
        onChange: @onChangeDate
        closeOnSelect: true
      }
      div { style: display: 'inline-block' },
        TimeIntervalSelector { startTime: reminderData.startTime, endTime: reminderData.endTime }
      select { value: @state.currentCalendar },
        reminderData.calendars.map (c) ->
          option { key: c.id, value: c.id }, c.summary

module.exports = ReminderEditor
