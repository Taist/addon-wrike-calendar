React = require 'react'

{ div, span, button } = React.DOM

Calendar = require 'react-input-calendar'

TimeIntervalSelector = require './timeIntervalSelector'
TimeDuration = require './timeDuration'
CustomSelect = require './customSelect'
CalendarReminderEditor = require './calendarReminderEditor'

CalendarEventEditor = React.createFactory React.createClass
  calendarsList: []

  onChangeDate: (startDate) ->
    @setState { startDate }

  getCalendarById: (calendarId) ->
    @calendarsList.filter( (c) -> c.id is calendarId )[0]

  updateState: (newProps) ->
    reminderData = newProps.reminder.getDisplayData()

    unless reminderData
      @setState mode: 'autorization'
      return

    @calendarsList = reminderData.calendars

    @setState
      currentCalendar: @getCalendarById reminderData.currentCalendar
      startTime: reminderData.startTime
      endTime: reminderData.endTime
      startDate: reminderData.startDate
      reminders: reminderData.reminders
      mode: if reminderData.exists then 'view' else 'new'

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

  onSave: ->
    @props.onSave?(@state)
    @setState mode: 'view'

  onDelete: ->
    @props.onDelete?()

  onAuthorize: ->
    @props.onAuthorize?()

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

  onEditEvent: ->
    @setState mode: 'edit'

  getEventDescription: ->
    dateOptions =
      weekday: 'long'
      year: 'numeric'
      month: 'long'
      day: 'numeric'

    timeOptions =
      hour: 'numeric'
      minute: '2-digit'

    startTime = new Date @state.startDate
    startTime.setHours 0, @state.startTime
    endTime = new Date @state.startDate
    endTime.setHours 0, @state.endTime
    console.log @state.startDate, @state.startTime, startTime

    @state.startDate.toLocaleString(navigator.language, dateOptions) + ' ' +
    startTime.toLocaleString(navigator.language, timeOptions) + ' - ' +
    endTime.toLocaleString(navigator.language, timeOptions)

  render: ->
    div { className: 'taist-font-size', style: paddingLeft: 28, marginBottom: 12 },
      if @state.mode is 'autorization'
        div { className: 'taist-link', onClick: @onAuthorize }, 'Authorize calendar addon'

      if @state.mode is 'new'
        div { className: 'taist-link', onClick: @onEditEvent }, 'Create new event in the Google Calendar'

      if @state.mode is 'view'
        div { className: 'taist-link', onClick: @onEditEvent }, @getEventDescription()

      if @state.mode is 'edit'
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

          div { style: display: 'inline-block' },
            div { className: 'taist-link', onClick: @onSave, style: marginLeft: 12 }, 'Save'
            div { className: 'taist-link', onClick: @onDelete, style: marginLeft: 12 }, 'Delete'
            div { className: 'taist-link', onClick: @onReset, style: marginLeft: 12 }, 'Cancel'

      if @state.mode is 'edit'
        div { style: marginTop: 8 },
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
              div { onClick: @onAddReminder, className: 'taist-link', style: marginTop: 4 },
                'Add notification'

module.exports = CalendarEventEditor
