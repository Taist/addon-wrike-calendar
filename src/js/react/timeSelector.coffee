React = require 'react'

{ div, span, select, option } = React.DOM

CustomSelect = require './customSelect'

TimeSelector = React.createFactory React.createClass
  minimalInterval: 30

  getInitialState: () ->
    startTime: 0
    endTime: "23:59"

  updateState: (props) ->
    currentValue = props.currentValue or props.startTime

    @setState
      startTime: props.startTime
      endTime: props.endTime
      currentValue: { id: currentValue, value: @minutesToTimeString currentValue }

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
    tempDate = new Date(2015, 3, 26, Math.floor(minutes / 60), minutes % 60, 0)
    timeOptions =
      hour: 'numeric'
      minute: '2-digit'
    language = navigator.language or 'en'
    time = tempDate.toLocaleString(language, timeOptions)
    time.toLowerCase();

  minutesToDuration: ( minutes = 0 ) ->
    duration = if minutes < 60
      "#{minutes} mins"
    else if minutes is 60
      "1 hr"
    else
      "#{ parseFloat (minutes/60).toFixed(1) } hrs"

    " (#{duration})"

  onChange: (currentValue) ->
    @setState { currentValue }
    @props.onChange?( currentValue.id )

  generateOptions: ->
    startMinutes = @state.startTime or 0
    stopMinutes = @state.endTime or (1440 - 1)

    for min in [startMinutes..stopMinutes] by @minimalInterval
      { id: min, value: "#{@minutesToTimeString min}#{if @props.duration then @minutesToDuration(min - startMinutes) else ''}" }

  render: ->
    CustomSelect {
      width: @props.width
      selected: @state.currentValue
      onChange: @onChange
      options: @generateOptions()
    }

module.exports = TimeSelector
