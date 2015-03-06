React = require 'react'

{ div, input, select, option } = React.DOM

CustomSelect = require './customSelect'

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
            quantity: quantity
            number: props.minutes / quantity.size
          }
      @setState result

  componentWillMount: () ->
    @updateState @props

  componentWillReceiveProps: ( nextProps ) ->
    @updateState nextProps

  onChange: (number, quantity) ->
    minutes = number * quantity.size
    @updateState { minutes }
    @props.onChange?(minutes)

  onChangeQuantity: (selectedOption) ->
    @onChange @state.number, size: selectedOption.id

  onChangeNumber: (event) ->
    @onChange event.target.value, @state.quantity

  onInputFocus: (event) ->
    event.target.select()

  render: ->
    div {},
      input {
        value: @state.number
        type: 'text'
        onChange: @onChangeNumber
        onFocus: @onInputFocus
        style:
          textAlign: 'right'
          width: 40
          marginRight: 4
      }

      CustomSelect {
        selected: { id: @state.quantity.size, value: @state.quantity.name }
        onChange: @onChangeQuantity
        options: @quantities.map (q) -> { id: q.size, value: q.name }
        width: 80
      }

module.exports = TimeDuration
