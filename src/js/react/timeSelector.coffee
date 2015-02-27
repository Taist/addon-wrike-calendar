React = require 'react'

{ div, span, select, option } = React.DOM

TimeSelector = React.createFactory React.createClass
  minimalInterval: 30

  getInitialState: () ->
    startTime: 0
    endTime: "23:59"

  updateState: (props) ->
    @setState
      startTime: props.startTime
      endTime: props.endTime
      currentValue: @timeStringToMinutes( props.currentValue or props.startTime )

  componentWillMount: () ->
    @updateState @props

  componentWillReceiveProps: ( nextProps ) ->
    @updateState nextProps

  timeStringToMinutes: ( time = "" ) ->
    parts = time.toString().match /^(\d{1,2})(\D(\d{2}))?/

    unless parts
      return 0

    hours = parseInt parts[1], 10
    minutes = parseInt( (parts?[3] or 0), 10 )

    hours * 60 + minutes - minutes % @minimalInterval

  minutesToTimeString: ( minutes = 0 ) ->
    "#{Math.floor(minutes / 60)}:#{if minutes % 60 < 10 then 0 else ''}#{minutes % 60}"

  minutesToDuration: ( minutes = 0 ) ->
    duration = if minutes < 60
      "#{minutes} mins"
    else if minutes is 60
      "1 hr"
    else
      "#{ parseFloat (minutes/60).toFixed(1) } hrs"

    " (#{duration})"


  generateOptions: ->
    startMinutes = @timeStringToMinutes( @state.startTime or 0 )
    stopMinutes = @timeStringToMinutes( @state.endTime or "23:59" )

    for min in [startMinutes..stopMinutes] by @minimalInterval
      option { value: min },
        "#{@minutesToTimeString min}#{if @props.duration then @minutesToDuration(min - startMinutes) else ''}"

  render: ->
    select { value: @state.currentValue }, @generateOptions()

module.exports = TimeSelector
