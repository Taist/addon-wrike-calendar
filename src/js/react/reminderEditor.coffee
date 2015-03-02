React = require 'react'

{ div, select, option } = React.DOM

Calendar = require 'react-input-calendar'

TimeIntervalSelector = require './TimeIntervalSelector'

ReminderEditor = React.createFactory React.createClass
  reminderMethods: [ 'popup', 'email', 'sms' ]

  onChangeDate: ( startDate ) ->
    @setState { startDate }
    console.log 'New date is', startDate

  updateState: (props) ->
    reminderData = @props.reminder.getDisplayData()

    @setState
      currentCalendar: reminderData.currentCalendar
      startTime: reminderData.startTime
      endTime: reminderData.endTime
      reminderMethod: reminderData.method or @reminderMethods[0]
      reminderMinutes: reminderData.minutes or 10
      startDate: reminderData.startDate

  componentWillMount: () ->
    @updateState @props

  componentWillReceiveProps: ( nextProps ) ->
    @updateState nextProps

  onChangeTimeInterval: (interval) ->
    console.log 'onChangeTimeInterval', interval
    @setState interval

  onChangeCalendar: (event) ->
    @setState currentCalendar: event.target.value

  onChangeMethod: (event) ->
    @setState reminderMethod: event.target.value

  render: ->
    reminderData = @props.reminder.getDisplayData()

    div {},
      Calendar {
        format: "MM-DD-YYYY"
        date: @state.startDate
        onChange: @onChangeDate
        closeOnSelect: true
      }
      div { style: display: 'inline-block' },
        TimeIntervalSelector
          startTime: @state.startTime
          endTime: @state.endTime
          onChange: @onChangeTimeInterval

      select { value: @state.currentCalendar, onChange: @onChangeCalendar },
        reminderData.calendars.map (c) ->
          option { key: c.id, value: c.id }, c.summary

      select { value: @state.reminderMethod, onChange: @onChangeMethod },
        @reminderMethods.map (m) ->
          option { key: m, value: m }, m

module.exports = ReminderEditor
