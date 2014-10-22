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
  configDefaults:
    scrollToLastItem: true

  activate: (state) ->
    requirePackages('tree-view').then ([treeView]) =>
      @breadcrumbView = new BreadcrumbView(treeView)

  deactivate: ->
    @breadcrumbView?.destroy()

  serialize: ->
    breadcrumbState: @breadcrumbView?.serialize()
