React = require 'react'

{ div, select, option, button } = React.DOM

Calendar = require 'react-input-calendar'

TimeIntervalSelector = require './timeIntervalSelector'
TimeDuration = require './timeDuration'
CustomSelect = require './customSelect'

ReminderEditor = React.createFactory React.createClass
  reminderMethods: [ 'popup', 'email', 'sms' ]

  onChangeDate: (startDate) ->
    @setState { startDate }
    console.log 'New date is', startDate

  calendarsList: []

  getCalendarById: (calendarId) ->
    @calendarsList.filter( (c) -> c.id is calendarId )[0]

  updateState: (newProps) ->
    reminderData = newProps.reminder.getDisplayData()

    @calendarsList = reminderData.calendars

    @setState
      currentCalendar: @getCalendarById reminderData.currentCalendar
      startTime: reminderData.startTime
      endTime: reminderData.endTime
      reminderMethod: reminderData.reminderMethod or @reminderMethods[0]
      reminderMinutes: reminderData.reminderMinutes or 10
      startDate: reminderData.startDate

  componentWillMount: () ->
    @updateState @props

  componentWillReceiveProps: (nextProps) ->
    @updateState nextProps

  onChangeTimeInterval: (interval) ->
    @setState interval

  onChangeCalendar: (calendar) ->
    @setState currentCalendar: @getCalendarById calendar.id

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

        div { style: marginLeft: 12, display: 'inline-block' },
          CustomSelect {
            selected: { id: @state.currentCalendar.id, value: @state.currentCalendar.summary }
            onChange: @onChangeCalendar
            options: @calendarsList.map (c) -> { id: c.id, value: c.summary }
          }

        button { onClick: @onSave, style: marginLeft: 12 }, 'Save'

        button { onClick: @onReset, style: marginLeft: 12 }, 'Reset'

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
