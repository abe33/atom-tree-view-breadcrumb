BreadcrumbElement = require './breadcrumb-element'
{requirePackages} = require 'atom-utils'

module.exports =
  breadcrumbElement: null
  config:
    scrollToLastItem:
      type: 'boolean'
      default: true
      description: 'When the breadcrumb content gets wider than its container, it will scroll horizontally to display the last directory in the path.'

    keepBreadcrumbVisible:
      type: 'boolean'
      default: false
      description: "Keep the breadcrumb container visible even when there's no content."

    displayProjectRoot:
      type: 'boolean'
      default: false
      description: "Display the project root as an icon in the breadcrumb."

    displayProjectRootName:
      type: 'boolean'
      default: false
      description: "Display the current project root name next to the root icon in the breadcrumb. This setting will only works if `Display Project Root` is also enabled"

    pathStyle:
      type: 'boolean'
      default: false
      description: "Display the breadcrumb using the style of unix paths with `/` as separator."

    scrollbarStyle:
      type: 'string'
      default: 'system'
      enum: ['system', 'thin']
      description: 'Changes the style of the breadcrumb scrollbar'

    breadcrumbPosition:
      type: 'string'
      default: 'top'
      enum: ['top','bottom']
      description: 'Position of the breadcrumb relatively to the tree view'

  activate: (state) ->
    requirePackages('tree-view').then ([treeView]) =>
      @breadcrumbElement = new BreadcrumbElement
      @breadcrumbElement.initialize(treeView)
    .catch (reason)->
      console.log reason

  deactivate: ->
    @breadcrumbElement?.destroy()
    @breadcrumbElement = null
