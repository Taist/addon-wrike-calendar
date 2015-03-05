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
    if props.minutes is 0
      @setState number: 0
    else
      for quantity in @quantities
        unless props.minutes % quantity.size
          result = {
            quantity: quantity.size
            number: props.minutes / quantity.size
          }
      @setState result

  componentWillMount: () ->
    @updateState @props

  componentWillReceiveProps: ( nextProps ) ->
    @updateState nextProps

  onChange: (number, quantity) ->
    minutes = number * quantity
    @updateState { minutes }
    @props.onChange?(minutes)

  onChangeQuantity: (event) ->
    @onChange @state.number, event.target.value

  onChangeNumber: (event) ->
    @onChange event.target.value, @state.quantity

  render: ->
    div {},
      input {
        value: @state.number
        type: 'text'
        onChange: @onChangeNumber
        style:
          textAlign: 'right'
          width: 40
          marginRight: 8
      }

      select { value: @state.quantity, onChange: @onChangeQuantity },
        @quantities.map (q) ->
          option { key: q.name, value: q.size }, q.name

module.exports = TimeDuration
