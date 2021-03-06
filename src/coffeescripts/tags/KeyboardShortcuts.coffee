###* @jsx React.DOM ###

# Setup some global event bindings for keyboard shortcuts, like
# navigating blocks and activating edit mode, etc.
# All communication back to the editor should be through publishing
# on the makona channel


##############################
### Includes and Constants ###
##############################
require("mousetrap")
require("../mousetrap-bind-global")  # this isnt in npm darn it
Blocks  = require("../blocks")
Channel = postal.channel("makona")


# Trigger re-render by sending new block up via the makona postal channel. Like so:
# ...
# newBlock = <block with changes>
# Channel.publish "block.change", { block: newBlock }


KeyboardShortcuts = React.createClass


  ##############################
  ### Construction           ###
  ##############################
  displayName: "KeyboardShortcuts"
  propTypes:
    blocks: React.PropTypes.array.isRequired


  ##############################
  ### Render                 ###
  ##############################
  render: -> `<div></div>`


  ##############################
  ### Life Cycle             ###
  ##############################
  # componentWillMount
  # componentWillReceiveProps
  # shouldComponentUpdate
  # componentWillUpdate
  # componentDidUpdate
  # componentWillUnmount

  componentDidMount: () ->
    Mousetrap.bind 'up',          (e) => @focusPrevious()
    Mousetrap.bind 'down',        (e) => @focusNext()
    Mousetrap.bind 'shift+up',    (e) => @movePrevious()
    Mousetrap.bind 'shift+down',  (e) => @moveNext()
    Mousetrap.bind 'enter',       (e) => @handleEnter()
    Mousetrap.bind 'm',           (e) => @addBlock('markdown')
    Mousetrap.bind 'c',           (e) => @addBlock('code')
    Mousetrap.bindGlobal 'esc',   (e) => @handleEscape()


  ##############################
  ### Custom Methods         ###
  ##############################

  handleEscape: ->
    newBlocks = _.map @props.blocks, (block) ->
      block.mode = 'preview'
      block
    Channel.publish "block.change", {blocks: newBlocks}

  focusNext: ->
    curSel = _.findIndex(@props.blocks, {focus: true})
    newBlocks = _.map @props.blocks, (block, i) ->
      block.focus = (i == curSel+1) ? true : false
      block
    Channel.publish "block.change", {blocks: newBlocks}

  focusPrevious: ->
    curSel = _.findIndex(@props.blocks, {focus: true})
    newBlocks = _.map @props.blocks, (block, i) ->
      block.focus = (i == curSel-1) ? true : false
      block
    Channel.publish "block.change", {blocks: newBlocks}

  moveNext: () ->
    newBlocks = @props.blocks.slice()
    curIndex = _.findIndex(newBlocks, {focus: true})
    return if curIndex >= newBlocks.length
    x = newBlocks[curIndex]
    newBlocks[curIndex] = newBlocks[curIndex+1]
    newBlocks[curIndex+1] = x
    Channel.publish "block.reorder", {blocks: newBlocks}

  movePrevious: () ->
    newBlocks = @props.blocks.slice()
    curIndex = _.findIndex(newBlocks, {focus: true})
    return if curIndex < 1
    x = newBlocks[curIndex]
    newBlocks[curIndex] = newBlocks[curIndex-1]
    newBlocks[curIndex-1] = x
    Channel.publish "block.reorder", {blocks: newBlocks}


  addBlock: (type) ->
    newBlock = Blocks.newBlock(type)
    focusPosition = _.findWhere(@props.blocks, {focus: true}).position
    Channel.publish "block.add", {block: newBlock, position: (focusPosition)}

  handleEnter: ->
    newBlock = _.find(@props.blocks, {focus: true})
    newBlock = _.extend(newBlock, {mode: 'edit'})
    Channel.publish "block.change", {block: newBlock}
    Channel.publish "block.caret", {block: newBlock}


# Export to make available
module.exports = KeyboardShortcuts
