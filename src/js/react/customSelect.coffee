React = require 'react'

{ div, input } = React.DOM

CustomSelectOption = React.createFactory React.createClass
  getInitialState: ->
    backgroundColor: ''

  onClick: ->
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
    document.addEventListener 'keyup', @onKeyUp
    document.addEventListener "click", @onClickOutside

  componentWillUnmount: ->
    document.removeEventListener 'keyup', @onKeyUp
    document.removeEventListener "click", @onClickOutside

  onClickOutside: (event) ->
    if event.target.dataset.reactid?.indexOf @.getDOMNode().dataset.reactid
      #target is not a child of the component
      @onClose()

  onKeyUp: (event) ->
    if event.keyCode is 27
      @onClose()

  onClose: ->
    @setState { mode: 'view' }

  updateState: (newProps) ->
    @setState
      selected: newProps.selected
      mode: 'view'

  componentWillMount: ->
    @updateState @props

  componentWillReceiveProps: (nextProps) ->
    @updateState nextProps

  onSelectOption: (selectedOption) ->
    @setState { value: selectedOption.value, mode: 'view' }
    @props.onChange?(selectedOption)

  onClickOnInput: ->
    @setState { mode: 'select' }, =>
      optionRect = @refs.selectedOption.getDOMNode().getBoundingClientRect()

      container = @refs.optionsContainer.getDOMNode()
      containerRect = container.getBoundingClientRect()

      container.scrollTop = Math.max(
        optionRect.top - optionRect.height * 2 - containerRect.top , 0
      )

  render: ->
    controlWidth = @props.width or 160

    div {
      onClick: @onClickInside
      style:
        display: 'inline-block'
        width: controlWidth
    },
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
          ref: 'optionsContainer'
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
            div { key: o.id }, CustomSelectOption {
              ref: if o.id is @state.selected.id then 'selectedOption' else undefined
              id: o.id
              value: o.value
              onSelect: @onSelectOption
            }

module.exports = CustomSelect
