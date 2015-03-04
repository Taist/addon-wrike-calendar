React = require 'react'

{ div, input } = React.DOM

CustomSelectOption = React.createFactory React.createClass
  getInitialState: ->
    backgroundColor: ''

  onClick: ->
    @props.onSelect?(@props.id)

  onMouseEnter: ->
    @setState backgroundColor: '#ddd'

  onMouseLeave: ->
    @setState backgroundColor: ''

  render: ->
    div {
      onClick: @onClick
      onMouseEnter: @onMouseEnter
      onMouseLeave: @onMouseLeave
      style:
        padding: 2
        backgroundColor: @state.backgroundColor
    }, @props.value

CustomSelect = React.createFactory React.createClass
  componentDidMount: ->
    document.body.addEventListener 'click', @onClose
    document.body.addEventListener 'keyup', @onKeyUp

  componentWillUnmount: ->
    document.body.removeEventListener 'click', @onClose
    document.body.removeEventListener 'keyup', @onKeyUp

  handleClick: (event) ->
    event.preventPropagation()

  onKeyUp: (event) ->
    if event.keyCode is 27
      @onClose()

  onClose: () ->
    console.log 'onClose'
    @setState { mode: 'view' }

  updateState: (newProps) ->
    @setState
      selected: newProps.selected
      mode: 'view'

  componentWillMount: () ->
    @updateState @props

  componentWillReceiveProps: (nextProps) ->
    @updateState nextProps

  onSelectOption: (selectedOptionId) ->
    option = @props.options.filter( (o) -> o.id is selectedOptionId )[0]
    @setState { value: option.value, mode: 'view' }
    @props.onChange?(option.id)

  onClickOnInput: () ->
    @setState { mode: 'select' }

  render: ->
    console.log @props
    controlWidth = @props.width or 160

    div { style: display: 'inline-block', width: controlWidth },
      div {}
        input {
          value: @state.selected.value
          style:
            width: controlWidth
          onClick: @onClickOnInput
          readOnly: true
        }
      if @state.mode is 'select'
        div {
          style:
            position: 'absolute',
            border: '1px solid silver',
            width: controlWidth
            cursor: 'pointer'
        },
          @props.options.map (o) =>
            div { key: o.id }, CustomSelectOption { id: o.id, value: o.value, onSelect: @onSelectOption }

module.exports = CustomSelect
