React = require 'react'
awesomeIcons = require './awesomeIcons'

{ div } = React.DOM

TimeDuration = require './timeDuration'
CustomSelect = require './customSelect'

CalendarReminderEditor = React.createFactory React.createClass
  reminderMethods: [ 'email', 'sms', 'popup' ]

  updateState: (newProps) ->
    @setState newProps.reminder

  componentWillMount: () ->
    @updateState @props

  componentWillReceiveProps: (nextProps) ->
    @updateState nextProps

  onChangeMethod: (selectedOption) ->
    @setState method: selectedOption.value, =>
      @props.onChange?(@props.index, @state)

  onChangeReminderTime: (minutes) ->
    @setState minutes: minutes, =>
      @props.onChange?(@props.index, @state)

  onDelete: () ->
    @props.onDelete?(@props.index)

  render: ->
    div { style: marginTop: 4 },
      CustomSelect {
        selected: { id: @state.method, value: @state.method }
        onChange: @onChangeMethod
        options: @reminderMethods.map (method) -> { id: method, value: method }
        width: 80
      }

      div {
        style:
          display: 'inline-block'
          marginLeft: 12
      },
        TimeDuration {
          minutes: @state.minutes
          onChange: @onChangeReminderTime
        }

      div {
        onClick: @onDelete,
        className: 'taist-link'
        style:
          position: 'relative'
          top: 1
          left: 3
          width: 11
          height: 11
          backgroundImage: "url(#{awesomeIcons.get 'remove'})"
          backgroundSize: 'contain'
          opacity: 0.6
      }

module.exports = CalendarReminderEditor
