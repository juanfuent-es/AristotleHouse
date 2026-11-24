# Aristotle House

Website and CMS for Aristotle House, an experiential agency in Dubai. Built on DomGl on Rails.

## Run it

Requires Ruby 3.2+, Node 22.12+, Bundler 2.7.1, PostgreSQL, ImageMagick and FFmpeg.

    bundle install
    npm ci
    bin/rails db:create db:schema:load db:seed
    bin/dev

The seed creates the admin `admin@aristotlehouse.com`. That address is a placeholder
used only to sign in at `/login`. In development the password is `aristotle-dev`;
anywhere else set `ADMIN_PASSWORD` before seeding. Every setting is listed in
[.env.example](.env.example).

## Coming soon

Until launch, visitors only see the holding screen at `/`. Signed-in admins browse the
whole site, starting at `/home`. Set `COMING_SOON=false` to open it.

The scene is in `app/javascript/scene`: the bust read for heat (`bust.*.glsl`), the room
(`field.frag.glsl`) and the glass word (`glass.js`, `variable_glyph.js`), a variable-weight extrusion that follows the real `h1` of the
page. Without WebGL, the poster in `public/brand` and the text remain.

## Climate

`Climate` (`app/models/climate.rb`) keeps one MET Norway forecast on disk for all
visitors and renews it when it expires, at most every 15 minutes. If the service fails,
the last forecast stays for up to 24 hours. The sun is calculated locally. In production
set `WEATHER_USER_AGENT`: without it no request is made and only the sun drives the
scene. Preview any hour with `/?at=17:30`.

## Content

Projects (`/work`), articles (`/thinking`) and static pages are stored in `pages` and
`blocks`, with no schema changes. See [docs/cms.md](docs/cms.md).

## Design

[DESIGN.md](DESIGN.md) is the design contract. Source material is in `design/toolkit`.

Favicons follow the browser colour scheme using the two gaze masters. Run
`npm run brand:icons` after changing those masters to rebuild the SVG, ICO and app
icons (requires ImageMagick). The social preview source is `design/share.html`;
capture it at 1280 × 640 after `document.fonts.ready` and export it as
`public/brand/share.jpg`.

## Test

    bin/rails test

## Credits

Code and design by [JuanFuent.es](https://juanfuent.es)
