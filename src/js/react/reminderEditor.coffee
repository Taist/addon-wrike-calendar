React = require 'react'

{ div, select, option, button } = React.DOM

Calendar = require 'react-input-calendar'

TimeIntervalSelector = require './timeIntervalSelector'
TimeDuration = require './timeDuration'

ReminderEditor = React.createFactory React.createClass
  reminderMethods: [ 'popup', 'email', 'sms' ]

  onChangeDate: (startDate) ->
    @setState { startDate }
    console.log 'New date is', startDate

  updateState: (newProps) ->
    reminderData = newProps.reminder.getDisplayData()

    @setState
      currentCalendar: reminderData.currentCalendar
      startTime: reminderData.startTime
      endTime: reminderData.endTime
      reminderMethod: reminderData.reminderMethod or @reminderMethods[0]
      reminderMinutes: reminderData.reminderMinutes or 10
      startDate: reminderData.startDate

  componentWillMount: () ->
    console.log 'componentWillMount'
    @updateState @props

  componentWillReceiveProps: (nextProps) ->
    console.log 'componentWillReceiveProps'
    @updateState nextProps

  onChangeTimeInterval: (interval) ->
    console.log 'onChangeTimeInterval', interval
    @setState interval

  onChangeCalendar: (event) ->
    @setState currentCalendar: event.target.value

  onChangeMethod: (event) ->
    @setState reminderMethod: event.target.value

  onChangeReminderTime: (minutes) ->
    @setState reminderMinutes: minutes

  onReset: () ->
    @updateState @props

  onSave: () ->
    @props.onSave?(@state)

  render: ->
    reminderData = @props.reminder.getDisplayData()

    div { className: 'increaseFontSize', style: paddingLeft: 28, marginBottom: 8 },
      div {},
        Calendar {
          format: 'MM/DD/YYYY'
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

        button { onClick: @onSave }, 'Save'

        button { onClick: @onReset }, 'Reset'

      div {}, 'Notifications',
        select { value: @state.reminderMethod, onChange: @onChangeMethod },
          @reminderMethods.map (m) ->
            option { key: m, value: m }, m

        div { style: display: 'inline-block' },
          TimeDuration {
            minutes: @state.reminderMinutes
            onChange: @onChangeReminderTime
          }

module.exports = ReminderEditor
