BreadcrumbElement = require './breadcrumb-element'
{requirePackages} = require 'atom-utils'

module.exports =
  breadcrumbElement: null
  config:
    scrollToLastItem:
      type: 'boolean'
      default: true
      description: 'When the breadcrumb content is wider than its container, does it scroll horizontally to make the last item visible.'

    keepBreadcrumbVisible:
      type: 'boolean'
      default: false
      description: "Keep the breadcrumb container visible even when there's no content."

    displayProjectRoot:
      type: 'boolean'
      default: false
      description: "Display the project root as an icon in the breadcrumb."

  activate: (state) ->
    requirePackages('tree-view').then ([treeView]) =>
      @breadcrumbElement = new BreadcrumbElement
      @breadcrumbElement.initialize(treeView)
    .catch (reason)->
      console.log reason

  deactivate: ->
    @breadcrumbElement?.destroy()
    @breadcrumbElement = null
