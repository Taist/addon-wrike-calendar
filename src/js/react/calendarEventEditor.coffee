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
      reminders: reminderData.reminders.slice 0
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
      weekday: 'short'
      year: 'numeric' if @state.startDate.getYear() isnt new Date().getYear()
      month: 'long'
      day: 'numeric'

    timeOptions =
      hour: 'numeric'
      minute: '2-digit'

    startTime = new Date @state.startDate
    startTime.setHours 0, @state.startTime
    endTime = new Date @state.startDate
    endTime.setHours 0, @state.endTime

    language = navigator.language
    @state.startDate.toLocaleString(language, dateOptions) + ' ' +
    startTime.toLocaleString(language, timeOptions).toLowerCase() + ' - ' +
    endTime.toLocaleString(language, timeOptions).toLowerCase()

  render: ->
    div { className: 'taist-reminders-container', style: marginBottom: 6 },
      if @state.mode is 'autorization'
        div {
          onClick: @onAuthorize
          className: 'taist-link taist-link-background'
          style: padding: "6px 28px 6px 28px"
        }, 'Authorize calendar addon'

      if @state.mode is 'new'
        div {
          onClick: @onEditEvent
          className: 'taist-link taist-link-background'
          style: padding: "6px 28px 6px 28px"
        }, 'Add to calendar'

      if @state.mode is 'view'
        div {
          onClick: @onEditEvent
          className: 'taist-link taist-link-background',
          style: padding: "6px 28px 6px 28px"
        }, @getEventDescription()

      if @state.mode is 'edit'
        div { style: marginLeft: 28 },
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
        div { style: marginLeft: 28, marginBottom: 6, marginTop: 8 },
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
              div { onClick: @onAddReminder, className: 'taist-link', style: marginTop: 8 },
                'Add notification'

module.exports = CalendarEventEditor
