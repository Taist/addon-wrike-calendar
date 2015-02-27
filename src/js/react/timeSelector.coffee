React = require 'react'

{ div, span, select, option } = React.DOM

TimeSelector = React.createFactory React.createClass
  minimalInterval: 30

  getInitialState: () ->
    startTime: 0
    stopTime: "23:59"

  updateState: (props) ->
    @setState
      startTime: props.startTime
      stopTime: props.stopTime
      currentValue: props.currentValue or props.startTime

  componentWillMount: () ->
    @updateState @props

  componentWillReceiveProps: ( nextProps ) ->
    @updateState nextProps

  timeStringToMinutes: (time) ->
    parts = time.toString().match /^(\d{1,2})(\D(\d{2}))?/

    unless parts
      return 0

    hours = parseInt parts[1], 10
    minutes = parseInt( (parts?[3] or 0), 10 )

    hours * 60 + minutes - minutes % @minimalInterval

  minutesToTimeString: (minutes = 0) ->
    "#{Math.floor(minutes / 60)}:#{if minutes % 60 < 10 then 0 else ''}#{minutes % 60}"

  generateOptions: ->
    startMinutes = @timeStringToMinutes( @state.startTime or 0 )
    stopMinutes = @timeStringToMinutes( @state.stopTime or "23:59" )

    for min in [startMinutes..stopMinutes] by @minimalInterval
     option { value: min }, @minutesToTimeString min

  render: ->
    select {}, @generateOptions()

module.exports = TimeSelector
