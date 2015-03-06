React = require 'react'

{ div, select, option, button } = React.DOM

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

  onAutorize: ->
    @props.onAutorize?()

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

  render: ->
    div { className: 'increaseFontSize', style: paddingLeft: 28, marginBottom: 8 },
      if @state.mode is 'autorization'
        div { className: 'taist-link', onClick: @onAutorize }, 'Authorize calendar addon'

      if @state.mode is 'new'
        div { className: 'taist-link', onClick: @onEditEvent }, 'Create new event in the Google Calendar'

      if @state.mode is 'view' or @state.mode is 'edit'
        div {},
          div { style: display: 'inline-block', position: 'relative' },
            if @state.mode is 'view'
              div {
                style:
                  position: 'absolute'
                  width: '100%'
                  height: '100%'
                  zIndex: 2048
              }, ''

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
            if @state.mode is 'view'
              div { className: 'taist-link', onClick: @onEditEvent, style: marginLeft: 12 }, 'Edit'

            if @state.mode is 'edit'
              div { style: display: 'inline-block' },
                div { className: 'taist-link', onClick: @onSave, style: marginLeft: 12 }, 'Save'
                div { className: 'taist-link', onClick: @onDelete, style: marginLeft: 12 }, 'Delete'
                div { className: 'taist-link', onClick: @onReset, style: marginLeft: 12 }, 'Cancel'

      if @state.mode is 'edit'
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
