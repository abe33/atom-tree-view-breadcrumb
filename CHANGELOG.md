<a name="v0.8.0"></a>
# v0.8.0 (2015-10-30)

## :sparkles: Features

- Add new positioning setting ([4bb4843c](https://github.com/abe33/atom-tree-view-breadcrumb/commit/4bb4843c046869942c6632dfe9712d3b2275365b))  <br>The breadcrumb can now be positioned above or below the tree view using
  the new setting.

<a name="v0.7.1"></a>
# v0.7.1 (2015-10-15)

## :bug: Bug Fixes

- Fix button style with certain themes ([7aaad116](https://github.com/abe33/atom-tree-view-breadcrumb/commit/7aaad116b1b0fe6778d6225ec3ac40b4cab05922))

<a name="v0.7.0"></a>
# v0.7.0 (2015-10-07)

## :sparkles: Features

- Implement setting to display the current project root name ([e975e5ae](https://github.com/abe33/atom-tree-view-breadcrumb/commit/e975e5aee136b93da92fb2eff1341d48cad49cd3), [#21](https://github.com/abe33/atom-tree-view-breadcrumb/issues/21))

## :bug: Bug Fixes

- Properly remove the breadcrumb when root is always visible ([847e89c0](https://github.com/abe33/atom-tree-view-breadcrumb/commit/847e89c01785d9d82d0b4cc1f2039c5828d20109))

<a name="v.0.6.3"></a>
# v.0.6.3 (2015-09-22)

## :arrow_up: Dependencies Update

- Upgrade atom-utils version ([50327960](https://github.com/abe33/atom-tree-view-breadcrumb/commit/50327960e212d7319587d4b25b8b61b04479d9be))

<a name="v0.6.2"></a>
# v0.6.2 (2015-08-12)

## :bug: Bug Fixes

- Prevent error when asked to scroll to a null item ([2305298f](https://github.com/abe33/atom-tree-view-breadcrumb/commit/2305298f34f38ee3549e0a42633c9ba7324becd8), [#17](https://github.com/abe33/atom-tree-view-breadcrumb/issues/17))

<a name="v0.6.1"></a>
# v0.6.1 (2015-07-08)

## :bug: Bug Fixes

- Prevent error when attaching the breadcrumb and there's no tree-view ([7b3202b1](https://github.com/abe33/atom-tree-view-breadcrumb/commit/7b3202b1cb2004faf40c1ca09ccfe7ac209cf0dd), [#11](https://github.com/abe33/atom-tree-view-breadcrumb/issues/11))
- Fix error raised when there's no selection in the tree view ([32943ef4](https://github.com/abe33/atom-tree-view-breadcrumb/commit/32943ef4a91a5de5beb28e7025e4ae67540a8f63), [#13](https://github.com/abe33/atom-tree-view-breadcrumb/issues/13))

<a name="v0.6.0"></a>
# v0.6.0 (2015-06-05)

## :sparkles: Features

- Add a setting to select the style of the breadcrumb scrollbar ([09930a47](https://github.com/abe33/atom-tree-view-breadcrumb/commit/09930a47cab717432c179e752c990b697b14465d))

<a name="v0.5.0"></a>
# v0.5.0 (2015-06-03)

## :sparkles: Features

- Add a setting to switch the style of the breadcrumb ([f162fb60](https://github.com/abe33/atom-tree-view-breadcrumb/commit/f162fb60a4f734bc89f46d771437d72bd58b426c), [#3](https://github.com/abe33/atom-tree-view-breadcrumb/issues/3))  <br>When this setting is enabled the breadcrumb will take the form of a
  unix path with / as separator.

## :bug: Bug Fixes

- Fix selected entry hidden when breadcrumb appear ([4fe09bfc](https://github.com/abe33/atom-tree-view-breadcrumb/commit/4fe09bfc69213efb630d58f5496e0122a86b8438), [#7](https://github.com/abe33/atom-tree-view-breadcrumb/issues/7))
- Fix a measuring issue on one light/dark theme ([97afd401](https://github.com/abe33/atom-tree-view-breadcrumb/commit/97afd40163c03a33eaaaebf83d9cd6e8768f09a2))
- Prevent error when trying to attach the view in setting callback ([07627ba8](https://github.com/abe33/atom-tree-view-breadcrumb/commit/07627ba8772311856b16f8385a02942fc998a251))
- Prevent errors when opening a window without tree view ([b6abda34](https://github.com/abe33/atom-tree-view-breadcrumb/commit/b6abda3491cc763f1af2df420fe6377b334e8cb3))

<a name="v0.4.1"></a>
# v0.4.1 (2015-02-19)

## :bug: Bug Fixes

- Fix error raised when toggling the tree view ([8c9ea034](https://github.com/abe33/atom-tree-view-breadcrumb/commit/8c9ea0346bb9a21d869b76951712b2148c3a85a0), [#10](https://github.com/abe33/atom-tree-view-breadcrumb/issues/10))

<a name="0.4.0"></a>
# 0.4.0 (2015-01-20)

Includes a rewrite using custom element instead of space-pen views.

## :bug: Bug Fixes

- Fix broken package and deprecations ([463fcccf](https://github.com/abe33/atom-tree-view-breadcrumb/commit/463fcccf22e3187cfd01e82d76c7e8a11729d754))

<a name="0.3.0"></a>
# 0.3.0 (2014-12-07)

## :sparkles: Features

- Add a setting to force the display of the project root ([f93679b7](https://github.com/abe33/atom-tree-view-breadcrumb/commit/f93679b7b520ec5194cd2728b9acb3d438a0c5df))
- Add TravisCI config ([d22b44d4](https://github.com/abe33/atom-tree-view-breadcrumb/commit/d22b44d4fd4880acca2fc6ab0c01bb30448d8ddd))
- Add a setting to force the visibility of the breadcrumb ([bf623d75](https://github.com/abe33/atom-tree-view-breadcrumb/commit/bf623d75fa378d6b7fd89b07e17c266725c5d83e))

## :bug: Bug Fixes

- Fix offset computation with tree-view-open-files ([4c030490](https://github.com/abe33/atom-tree-view-breadcrumb/commit/4c030490cfa5a6e367ac8bcd24228378df57ab5e))
- Fix scrolling tree-view on breadcrumb click ([d3084bbf](https://github.com/abe33/atom-tree-view-breadcrumb/commit/d3084bbf3b32e263f19c3583411df583cf3ffd2d))
- Fix invalid index computation for first visible item ([a5587bd6](https://github.com/abe33/atom-tree-view-breadcrumb/commit/a5587bd6d0b76c3e328276d9b782eb999e849bf3))
- Fix attachment issues without project or tree view hidden ([14d41b6e](https://github.com/abe33/atom-tree-view-breadcrumb/commit/14d41b6e199244a8222eba090c44d678f6a4d2e6))

<a name="v0.2.3"></a>
# v0.2.3 (2014-11-03)

## :bug: Bug Fixes

- Fix breadcrumb button targets and adjust offset based on position of tree view ([75ddc04f](https://github.com/abe33/atom-tree-view-breadcrumb/commit/75ddc04f1a21189186db29f5ad0ee329811be5e0))

<a name="v0.2.2"></a>
# v0.2.2 (2014-10-29)

## :bug: Bug Fixes

- Fix issue with item offset returning null ([021cdce6](https://github.com/abe33/atom-tree-view-breadcrumb/commit/021cdce6b762d8f8731ba9bc14f9d9b40314ccb4))
- Fix layout with tree-view-open-files package ([7a598afe](https://github.com/abe33/atom-tree-view-breadcrumb/commit/7a598afef4881f4ae30212b5933013a03d2838c1))

<a name="v0.2.1"></a>
# v0.2.1 (2014-10-23)

## :bug: Bug Fixes

- Fix breadcrumb not displayed in latest Atom version ([6785eb1b](https://github.com/abe33/atom-tree-view-breadcrumb/commit/6785eb1b0233c50538785ea0cb3b08b187e546b9))
- Fix requiring package by using a promise ([e599969f](https://github.com/abe33/atom-tree-view-breadcrumb/commit/e599969fc36ad651f926d69faf7612cdde9c527c))

<a name="v0.2.0"></a>
# v0.2.0 (2014-08-13)

## :sparkles: Features

- Add `scroll to` click action on breadcrumb buttons ([d2e4bc7b](https://github.com/abe33/atom-tree-view-breadcrumb/commit/d2e4bc7b0d721eda06353728da5c380b40904eee))


<a name="0.1.0"></a>
# 0.1.0 (2014-08-13)

## :sparkles: Features

- Add config to force the breadcrumb to scroll to show the last item ([ff898308](https://github.com/atom/tree-view-breadcrumb/commit/ff898308c5f256e16279778748fafacf79549fe8))
- Add a distinctive style for the last item in the breadcrumb ([58b785a4](https://github.com/atom/tree-view-breadcrumb/commit/58b785a411cbe7c79962b365b204d3b72d8586ae))
