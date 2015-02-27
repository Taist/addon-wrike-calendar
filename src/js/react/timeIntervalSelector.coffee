React = require 'react'

{ span } = React.DOM

TimeSelector = require './timeSelector'

TimeIntervalSelector = React.createFactory React.createClass
  render: () ->
    span {},
      TimeSelector { }
      TimeSelector { stopTime: '17:00' }

module.exports = TimeIntervalSelector
