React = require 'react'

{ span } = React.DOM

TimeSelector = require './timeSelector'

TimeIntervalSelector = React.createFactory React.createClass
  updateState: (props) ->
    @setState
      startTime: props.startTime
      endTime: props.endTime

  componentWillMount: () ->
    @updateState @props

  componentWillReceiveProps: ( nextProps ) ->
    @updateState nextProps

  onChange: () ->
    interval =
      startTime: @state.startTime
      endTime: @state.endTime
    console.log interval

  onStartChange: (startTime) ->
    endTime = @state.endTime
    if startTime.length >= endTime.length and startTime > endTime
      @setState { endTime: startTime }
    @setState { startTime }, @onChange

  onEndChange: (endTime) ->
    @setState { endTime }, @onChange

  render: () ->
    span {},

      TimeSelector
        currentValue: @state.startTime
        onChange: @onStartChange

      TimeSelector
        currentValue: @state.endTime
        startTime: @state.startTime
        duration: true
        onChange: @onEndChange

module.exports = TimeIntervalSelector
