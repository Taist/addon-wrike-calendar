React = require 'react'

{ div } = React.DOM

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
    div { style: display: 'inline-block' },
      div { style: marginLeft: 12, display: 'inline-block' },
        TimeSelector
          width: 68
          currentValue: @state.startTime
          onChange: @onStartChange
      div { style: marginLeft: 8, display: 'inline-block' },
        TimeSelector
          width: 68
          currentValue: @state.endTime
          startTime: @state.startTime
          duration: true
          onChange: @onEndChange

module.exports = TimeIntervalSelector
