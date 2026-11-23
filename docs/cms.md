# CMS

The database schema is the template's, unchanged. Content is organised by convention.

| Content | Stored as |
| --- | --- |
| Project | `Page` with category `project` or `project_draft` |
| Article | `Page` with category `article` or `article_draft` |
| Site page (house, contact, legal) | `Page` with category `static` and `restricted` |
| Cover and share image | `pages.og_image` |
| Summary | `pages.og_description` |
| Introduction or text | `pages.content`, plain text |
| Tags | `Tag` through `Tagging` |
| Language versions | `pages.versionable` (not used yet: the site is in English) |

## Blocks

`blocks.category` says how a block is read. Order is `blocks.number`.

| Category | `title` | `content` |
| --- | --- | --- |
| `text` | Heading | Paragraphs |
| `quote` | Who said it | The line |
| `fact` | Label: Client, Location, Year, Scope | Value |
| `metric` | Label | Value |
| `image` | Caption | Id of an `Image` |
| `video` | Caption | Id of a `Video` |

Everything is escaped when rendered. `css`, `js`, `html` and `glsl` blocks belong to the
internal sandbox and never appear on a project or an article.

## Publishing

A draft can be incomplete. Publishing needs a title and a summary. Admins preview drafts
at their final URL; visitors get a 404.

## Limits of keeping the schema

- A published project is edited live: there is no draft next to the published version.
- A project names its client as a fact. `clients` is a separate address book with no link to projects.
- Slugs are unique across every kind of page.
- There is no manual order: the newest project goes first.
- There is no publication date of its own: `created_at` is shown.
