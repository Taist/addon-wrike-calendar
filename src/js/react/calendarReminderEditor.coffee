React = require 'react'

{ div, select, option } = React.DOM

TimeDuration = require './timeDuration'

CalendarReminderEditor = React.createFactory React.createClass
  reminderMethods: [ 'popup', 'email', 'sms' ]

  updateState: (newProps) ->
    @setState newProps.reminder

  componentWillMount: () ->
    @updateState @props

  componentWillReceiveProps: (nextProps) ->
    @updateState nextProps

  onChangeMethod: (event) ->
    @setState method: event.target.value, =>
      @props.onChange?(@props.index, @state)

  onChangeReminderTime: (minutes) ->
    @setState minutes: minutes, =>
      @props.onChange?(@props.index, @state)

  render: ->
    console.log @props
    div {},
      select {
        value: @state.method
        onChange: @onChangeMethod
        style:
          marginRight: 12
      },
        @reminderMethods.map (m) ->
          option { key: m, value: m }, m

      div { style: display: 'inline-block' },
        TimeDuration {
          minutes: @state.minutes
          onChange: @onChangeReminderTime
        }

module.exports = CalendarReminderEditor
