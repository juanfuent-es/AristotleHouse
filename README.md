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
(`field.frag.glsl`) and the glass word (`glass.js`), which follows the real `h1` of the
page. Without WebGL, the poster in `public/brand` and the text remain.

## Content

Projects (`/work`), articles (`/thinking`) and static pages are stored in `pages` and
`blocks`, with no schema changes. See [docs/cms.md](docs/cms.md).

## Design

[DESIGN.md](DESIGN.md) is the design contract. Source material is in `design/toolkit`.

## Test

    bin/rails test

## Credits

Code and design by [JuanFuent.es](https://juanfuent.es)
