# Porto Alegre Bitdevs

Simple Jekyll site for hosting all of the links from meetups past and future.

## Development

You'll need [Ruby & Jekyll](https://jekyllrb.com/docs/installation/) to run the
site locally. Once they're setup:

* Clone the repository and go into the directory
* Run `bundle install`
* Run `jekyll serve`
* Go to http://localhost:4000

## Making a Post

To make a new post, make a new file in `_posts/` with a title of
`YYYY-MM-DD-title-goes-here`. At the top of the file you'll want to provide the
following information:

```md
---
layout: post # Always post
type: socratic # or whitepaper for a whitepaper series
title: "Name of the Post"
meetup: https://www.meetup.com/BitDevsNYC/events/[event id here]/
---
```

After that, it's just simple markdown. The site will auto-generate the rest.

## Changing Site Data

All site configurations are either contained in `_config.yml` or
`_data/settings.yml`. Some data is duplicated between the two due to the way
Jekyll injects variables, so be sure to update both.

## Deploying & Previews

The site is built and published by GitHub Actions to the `gh-pages` branch
(GitHub Pages source) — do not edit `gh-pages` directly, it's regenerated on
every push.

* Every pull request from a branch of this repository (forks aren't
  supported yet) gets an automatic preview published at
  `/pr-preview/pr-<number>/`, with a link posted as a PR comment and
  updated on every push.
* Merging to `master` rebuilds production from the current `master` HEAD
  and publishes it to the root of `gh-pages`.
* Closing a PR (merged or not) removes its preview.

See [ADR 0002](docs/adr/0002-preview-e-producao-via-actions-gh-pages.md) for
the full design and rationale.

## Attributions

Thanks to [LeNPaul](https://github.com/LeNPaul/jekyll-starter-kit) for the
Jekyll starter kit this was forked from.
