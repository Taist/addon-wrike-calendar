React = require 'react'

{ span } = React.DOM

TimeSelector = require './timeSelector'

TimeIntervalSelector = React.createFactory React.createClass
  render: () ->
    span {},
      TimeSelector { currentValue: @props.startTime }
      TimeSelector { currentValue: @props.endTime, startTime: @props.startTime, duration: true }

module.exports = TimeIntervalSelector
