BreadcrumbView = require './breadcrumb-view'

module.exports =
  breadcrumbView: null

  activate: (state) ->
    if atom.workspaceView.find('.tree-view')
      @breadcrumbView = new BreadcrumbView(state.breadcrumbState)

  deactivate: ->
    @breadcrumbView?.destroy()

  serialize: ->
    breadcrumbState: @breadcrumbView?.serialize()
