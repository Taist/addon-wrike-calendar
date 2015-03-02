React = require 'react'

{ div, input, select, option } = React.DOM

TimeDuration = React.createFactory React.createClass
  quantities: [
    { name: 'minutes', size: 1 }
    { name: 'hours', size: 60 }
    { name: 'days', size: 1440 }
    { name: 'weeks', size: ( 1440 * 7 ) }
  ]

  getInitialState: ->
    number: 10

  updateState: (props) ->
    for quantity in @quantities
      unless props.minutes % quantity.size
        result = {
          quantity: quantity.name
          number: props.minutes / quantity.size
        }
    console.log '---', result
    @setState result

  componentWillMount: () ->
    @updateState @props

  componentWillReceiveProps: ( nextProps ) ->
    @updateState nextProps

  onChangeQuantity: (event) ->
    @updateState { minutes }

  render: ->
    console.log @props

    div {},
      input {
        value: @state.number
        type: 'text'
        style:
          textAlign: 'right'
          width: 40
      }

      select { value: @state.quantity, onChange: @onChangeQuantity },
        @quantities.map (q) ->
          option { key: q.name, value: q.name }, q.name

module.exports = TimeDuration
