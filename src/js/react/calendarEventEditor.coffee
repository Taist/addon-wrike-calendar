React = require 'react'

{ div, select, option, button } = React.DOM

Calendar = require 'react-input-calendar'

TimeIntervalSelector = require './timeIntervalSelector'
TimeDuration = require './timeDuration'
CustomSelect = require './customSelect'
CalendarReminderEditor = require './calendarReminderEditor'

CalendarEventEditor = React.createFactory React.createClass
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
      startDate: reminderData.startDate
      reminders: reminderData.reminders

  componentWillMount: () ->
    @updateState @props

  componentWillReceiveProps: (nextProps) ->
    @updateState nextProps

  onChangeTimeInterval: (interval) ->
    @setState interval

  onChangeCalendar: (calendar) ->
    @setState currentCalendar: @getCalendarById calendar.id

  onReset: () ->
    @updateState @props

  onSave: () ->
    @props.onSave?(@state)

  onChangeReminder: (index, reminder) ->
    reminders = @state.reminders
    reminders[index] = reminder
    @setState { reminders }

  onAddReminder: ->
    reminders = @state.reminders
    reminders.push { method: 'popup', minutes: '10' }
    @setState { reminders }

  onDeleteReminder: (index) ->
    reminders = @state.reminders
    reminders.splice index, 1
    @setState { reminders }

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

      div {},
        div { style: display: 'inline-block', verticalAlign: 'top', paddingRight: 12 },
          'Notifications'
        div { style: display: 'inline-block' },
          div {},
            @state.reminders.map (reminder, index) =>
              CalendarReminderEditor {
                index
                reminder
                onChange: @onChangeReminder
                onDelete: @onDeleteReminder
              }
          div {},
            div { onClick: @onAddReminder, className: 'taist-link' }, 'Add notification'

module.exports = CalendarEventEditor
