# Changelog

## [1.4.0](https://github.com/JacobPEvans/nix-home/compare/v1.3.0...v1.4.0) (2026-03-14)


### Features

* migrate flake.lock updates to Renovate nix manager ([#73](https://github.com/JacobPEvans/nix-home/issues/73)) ([1e0430f](https://github.com/JacobPEvans/nix-home/commit/1e0430f6aed962908419ac6b76d913accca2cbe9))


### Bug Fixes

* **ci:** upgrade ci-gate.yml to Merge Gatekeeper pattern ([#70](https://github.com/JacobPEvans/nix-home/issues/70)) ([4360274](https://github.com/JacobPEvans/nix-home/commit/4360274ffe986d82a74afeebc75a75abff0f8697))

## [1.3.0](https://github.com/JacobPEvans/nix-home/compare/v1.2.0...v1.3.0) (2026-03-14)


### Features

* make python3 resolve to Python 3.14 via overlay ([#68](https://github.com/JacobPEvans/nix-home/issues/68)) ([47c8e9a](https://github.com/JacobPEvans/nix-home/commit/47c8e9afdb9f613c110c86b72f40798b25056128))

## [1.2.0](https://github.com/JacobPEvans/nix-home/compare/v1.1.0...v1.2.0) (2026-03-14)


### Features

* replace background processes with native source configs ([#66](https://github.com/JacobPEvans/nix-home/issues/66)) ([af489d1](https://github.com/JacobPEvans/nix-home/commit/af489d11e5e61973e1b1933cfb479da30bb59129))

## [1.1.0](https://github.com/JacobPEvans/nix-home/compare/v1.0.0...v1.1.0) (2026-03-13)


### Features

* add automated flake.lock update workflow ([#47](https://github.com/JacobPEvans/nix-home/issues/47)) ([7c7229c](https://github.com/JacobPEvans/nix-home/commit/7c7229ce50b5b733899aa2b86f7f135e74282576))
* add daily repo health audit agentic workflow ([#55](https://github.com/JacobPEvans/nix-home/issues/55)) ([1bf8cae](https://github.com/JacobPEvans/nix-home/commit/1bf8cae8f76103e58238b784c54954e8060d5a06))
* add dev shell eval smoke tests and remove redundant markdownlint config ([#22](https://github.com/JacobPEvans/nix-home/issues/22)) ([ff1884a](https://github.com/JacobPEvans/nix-home/commit/ff1884aadb58610402b58358d3b9381bbc4e9984))
* add GitHub Agentic Workflows ([#29](https://github.com/JacobPEvans/nix-home/issues/29)) ([263ce9c](https://github.com/JacobPEvans/nix-home/commit/263ce9c10758c8d821daa793fcb3f16277e4d2e3))
* add scheduled AI workflow callers ([#36](https://github.com/JacobPEvans/nix-home/issues/36)) ([9ea7e66](https://github.com/JacobPEvans/nix-home/commit/9ea7e667134ffd90379058b9d3df99b0f56d01c9))
* consolidate package updates into single workflow job ([#46](https://github.com/JacobPEvans/nix-home/issues/46)) ([7eb38c1](https://github.com/JacobPEvans/nix-home/commit/7eb38c1a63313ffa86aafa416de17f0d6e635e29))
* disable automatic triggers on Claude-executing workflows ([df000b1](https://github.com/JacobPEvans/nix-home/commit/df000b1a0a90aa71716a5fa17b93c6cf9a166c56))
* Python 3.14 overlay, HF_HOME volume, and MLX aliases ([#57](https://github.com/JacobPEvans/nix-home/issues/57)) ([0548954](https://github.com/JacobPEvans/nix-home/commit/0548954ceb48420e6b4c7081afc47dc74024aee0))
* replace shells/ with per-repo templates, trim global packages ([#25](https://github.com/JacobPEvans/nix-home/issues/25)) ([10b3ae6](https://github.com/JacobPEvans/nix-home/commit/10b3ae673082101affc3f6e7baae61e03c379d01))


### Bug Fixes

* add concurrency groups to prevent duplicate PR creation ([#37](https://github.com/JacobPEvans/nix-home/issues/37)) ([f3989fa](https://github.com/JacobPEvans/nix-home/commit/f3989faf77c581fb23d9793e177b7d70c9b341c3))
* add concurrency guard to release-please caller workflow ([5d2568c](https://github.com/JacobPEvans/nix-home/commit/5d2568ca15b0e7f9d36b14e21cb18ee06b72108d))
* add missing pygments and tabulate deps to grip package ([#58](https://github.com/JacobPEvans/nix-home/issues/58)) ([9301351](https://github.com/JacobPEvans/nix-home/commit/9301351a4898ffc043052ad8bf8e412435f6e8ca))
* bump ci-fail-issue workflow to v0.6.1 ([#26](https://github.com/JacobPEvans/nix-home/issues/26)) ([3e1df2f](https://github.com/JacobPEvans/nix-home/commit/3e1df2f78b61dbd50aeb4a13debb9d7649f3c6ad))
* **ci:** use GitHub App token for release-please to trigger CI Gate ([#61](https://github.com/JacobPEvans/nix-home/issues/61)) ([411a3bd](https://github.com/JacobPEvans/nix-home/commit/411a3bdb61fd7e6ad7d3795d4628d92e3cbe2105))
* complete changelog-sections for full Conventional Commits coverage ([effaccc](https://github.com/JacobPEvans/nix-home/commit/effacccbe8a1813fb523954443d4c0385c90d8b5))
* correct best-practices permissions and add ref-scoped concurrency ([#38](https://github.com/JacobPEvans/nix-home/issues/38)) ([f2493b1](https://github.com/JacobPEvans/nix-home/commit/f2493b1c754952ce4ca5b9bb539f5c9b47a7e50b))
* correct misleading auto-merge comment in deps-update-flake.yml ([#49](https://github.com/JacobPEvans/nix-home/issues/49)) ([e893bfc](https://github.com/JacobPEvans/nix-home/commit/e893bfc00b47f34161c6a409432f460f9a04456c))
* disable hash pinning for trusted actions, use version tags ([#40](https://github.com/JacobPEvans/nix-home/issues/40)) ([9f869c3](https://github.com/JacobPEvans/nix-home/commit/9f869c32338234f86055f739051831b73cafe5cc))
* **grip:** list Python dependencies explicitly to avoid self-referential overlay cycle ([#53](https://github.com/JacobPEvans/nix-home/issues/53)) ([a412e42](https://github.com/JacobPEvans/nix-home/commit/a412e42f22565001488402fafc942f9ac8ba0c3c))
* pass python-prev to grip overlay to break infinite recursion ([#52](https://github.com/JacobPEvans/nix-home/issues/52)) ([80bb1fa](https://github.com/JacobPEvans/nix-home/commit/80bb1fa0c9b8c0dee96a4feaaa505905dcd66837))
* remove blanket auto-merge workflow ([#39](https://github.com/JacobPEvans/nix-home/issues/39)) ([9ddc2fc](https://github.com/JacobPEvans/nix-home/commit/9ddc2fc763210c55a754c88ddca47e54bbf5fed8))
* remove soft-fail patterns from deps-update-packages workflow ([#51](https://github.com/JacobPEvans/nix-home/issues/51)) ([a609a72](https://github.com/JacobPEvans/nix-home/commit/a609a723e61dc2d5446926e424279b362d8b3892))
* rename GH_APP_ID secret to GH_ACTION_JACOBPEVANS_APP_ID ([#48](https://github.com/JacobPEvans/nix-home/issues/48)) ([b74734e](https://github.com/JacobPEvans/nix-home/commit/b74734e3b99e6f90bafcfab4a4549feb0b0668ab))
