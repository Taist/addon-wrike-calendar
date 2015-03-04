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
    @props.onChange?(interval)

  onStartChange: (startTime) ->
    endTime = @state.endTime
    if startTime > endTime
      @setState { endTime: startTime }
    @setState { startTime }, @onChange

  onEndChange: (endTime) ->
    @setState { endTime }, @onChange

  render: () ->
    span {},

      TimeSelector
        width: 60
        currentValue: @state.startTime
        onChange: @onStartChange

      TimeSelector
        width: 60
        currentValue: @state.endTime
        startTime: @state.startTime
        duration: true
        onChange: @onEndChange

module.exports = TimeIntervalSelector
