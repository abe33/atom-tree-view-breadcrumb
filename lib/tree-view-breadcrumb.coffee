BreadcrumbView = require './breadcrumb-view'

requirePackages = (packages...) ->
  new Promise (resolve, reject) ->
    required = []
    promises = []
    failures = []
    remains = packages.length

    solved = ->
      remains--
      return unless remains is 0
      return reject(failures) if failures.length > 0
      resolve(required)

    packages.forEach (pkg, i) ->
      promises.push(atom.packages.activatePackage(pkg)
      .then (activatedPackage) ->
        required[i] = activatedPackage.mainModule
        solved()
      .fail (reason) ->
        failures[i] = reason
        solved()
      )

module.exports =
  breadcrumbView: null
  config:
    scrollToLastItem:
      type: 'boolean'
      default: true
      description: 'When the breadcrumb content is wider than its container, does it scroll horizontally to make the last item visible.'

    keepBreadcrumbVisible:
      type: 'boolean'
      default: false
      description: "Keep the breadcrumb container visible even when there's no content."

  activate: (state) ->
    requirePackages('tree-view').then ([treeView]) =>
      @breadcrumbView = new BreadcrumbView(treeView)

  deactivate: ->
    @breadcrumbView?.destroy()

  serialize: ->
    breadcrumbState: @breadcrumbView?.serialize()
