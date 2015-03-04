React = require 'react'

{ div, input } = React.DOM

CustomSelectOption = React.createFactory React.createClass
  getInitialState: ->
    backgroundColor: ''

  onClick: ->
    console.log 'onClickOption'
    @props.onSelect?(@props)

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
        padding: "2px 16px 2px 4px"
        backgroundColor: @state.backgroundColor
        whiteSpace: 'nowrap'
    }, @props.value

CustomSelect = React.createFactory React.createClass
  componentDidMount: ->
    document.body.addEventListener 'keyup', @onKeyUp

  componentWillUnmount: ->
    document.body.removeEventListener 'keyup', @onKeyUp

  onKeyUp: (event) ->
    if event.keyCode is 27
      @onClose()

  onClose: () ->
    @setState { mode: 'view' }

  updateState: (newProps) ->
    @setState
      selected: newProps.selected
      mode: 'view'

  componentWillMount: () ->
    @updateState @props

  componentWillReceiveProps: (nextProps) ->
    @updateState nextProps

  onSelectOption: (selectedOption) ->
    @setState { value: selectedOption.value, mode: 'view' }
    @props.onChange?(selectedOption)

  onClickOnInput: () ->
    @setState { mode: 'select' }

  onClick: () ->
    console.log 'onClick'

  render: ->
    controlWidth = @props.width or 160

    div { onClick: @onClick, style: display: 'inline-block', width: controlWidth },
      div {}
        input {
          value: @state.selected.value
          style:
            width: controlWidth
          onClick: @onClickOnInput
          onClose: @onClose
          readOnly: true
        }
      if @state.mode is 'select'
        div {
          style:
            position: 'absolute'
            border: '1px solid silver'
            minWidth: controlWidth
            cursor: 'pointer'
            backgroundColor: 'white'
            zIndex: 1024
            maxHeight: 128
            overflowY: 'auto'
            overflowX: 'hidden'
        },
          @props.options.map (o) =>
            div { key: o.id }, CustomSelectOption { id: o.id, value: o.value, onSelect: @onSelectOption }

module.exports = CustomSelect
