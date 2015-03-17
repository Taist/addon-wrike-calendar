React = require 'react'

{ div, span, a, button } = React.DOM

Calendar = require 'react-input-calendar'

TimeIntervalSelector = require './timeIntervalSelector'
TimeDuration = require './timeDuration'
CustomSelect = require './customSelect'
CalendarReminderEditor = require './calendarReminderEditor'

CalendarEventEditor = React.createFactory React.createClass
  calendarsList: []

  onChangeDate: (monthDateYear) ->
    dateParts = monthDateYear.split /\D/
    startDate = new Date dateParts[2], dateParts[0] - 1, dateParts[1], 12
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
      htmlLink: reminderData.htmlLink
      reminders: reminderData.reminders.slice 0
      mode: if reminderData.exists then 'view' else 'new'
      isNewEvent: false

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
    reminders.push { method: 'sms', minutes: '10' }
    @setState { reminders }

  onDeleteReminder: (index) ->
    reminders = @state.reminders
    reminders.splice index, 1
    @setState { reminders }

  onEditEvent: (event) ->
    if event.target.tagName.toLowerCase() isnt 'a'
      @setState mode: 'edit'

  onNewEvent: ->
    @setState mode: 'edit', isNewEvent: true

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

    eventDescription =
    @state.startDate.toLocaleString(language, dateOptions) + ' ' +
    startTime.toLocaleString(language, timeOptions).toLowerCase() + ' - ' +
    endTime.toLocaleString(language, timeOptions).toLowerCase()

    span {},
      span {}, eventDescription
      span {},
        span {}, ' ('
        a {
          target: 'blank'
          href: @state.htmlLink.replace(/\/event\?/, '/render?') + '#main_7'
        },
          @state.currentCalendar.summary
        span {}, ')'


  render: ->
    div { className: 'taist-reminders-container', style: marginBottom: 6 },
      if @state.mode is 'autorization'
        div {
          onClick: @onAuthorize
          className: 'taist-link taist-link-background'
          style: padding: "6px 26px 6px 26px"
        }, 'Authorize calendar addon'

      if @state.mode is 'new'
        div {
          onClick: @onNewEvent
          className: 'wspace-button-add x-btn-noicon'
          style: margin: "6px 26px 6px 26px"
        }, 'Add to calendar'

      if @state.mode is 'view'
        div {
          onClick: @onEditEvent
          className: 'taist-link taist-link-background',
          style: padding: "6px 26px 6px 26px"
        }, @getEventDescription()

      if @state.mode is 'edit'
        div { style: marginLeft: 26 },
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

          div { style: marginLeft: 12, display: 'inline-block' }, 'in'

          div { style: marginLeft: 4, display: 'inline-block' },
            CustomSelect {
              selected: { id: @state.currentCalendar.id, value: @state.currentCalendar.summary }
              onChange: @onChangeCalendar
              options: @calendarsList.map (c) -> { id: c.id, value: c.summary }
            }

          div { style: display: 'inline-block' },
            div {
              className: 'taist-link'
              onClick: @onSave
              style: marginLeft: 12, color: 'rgb(82, 133, 184)'
            }, 'Save'
            unless @state.isNewEvent
              div {
                className: 'taist-link',
                onClick: @onDelete,
                style: marginLeft: 12, color: 'rgb(164, 13, 13)'
              }, 'Delete'
            div {
              className: 'taist-link',
              onClick: @onReset,
              style: marginLeft: 12
            }, 'Cancel'

      if @state.mode is 'edit'
        div { style: marginLeft: 26, marginBottom: 6, marginTop: 8 },
          div { style: display: 'inline-block' },
            div {},
              @state.reminders.map (reminder, index) =>
                CalendarReminderEditor {
                  index
                  reminder
                  onChange: @onChangeReminder
                  onDelete: @onDeleteReminder
                }
            div { style: marginTop: 12 },
              div { onClick: @onAddReminder, className: 'wspace-button-add x-btn-noicon' },
                'Add notification'

module.exports = CalendarEventEditor
