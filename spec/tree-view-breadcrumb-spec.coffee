{WorkspaceView} = require 'atom'
TreeViewBreadcrumb = require '../lib/tree-view-breadcrumb'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "TreeViewBreadcrumb", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.packages.activatePackage('tree-view')
    activationPromise = atom.packages.activatePackage('tree-view-breadcrumb')

  describe "when the tree-view-breadcrumb:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.tree-view-breadcrumb')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.

      waitsForPromise ->
        activationPromise

      runs ->
