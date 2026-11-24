# Content

Projects and fixed pages are edited on the page itself. `/admin` is an overview and the
library of images and videos.

| Where | What |
| --- | --- |
| `/projects` | The collection. Administrators also see drafts, archived projects and New project |
| `/projects/:slug/edit` | The case, written in place |
| `/projects/:slug/preview` | The draft as visitors would see it |
| `/house/edit`, `/contact/edit`, `/privacy/edit`, `/cookies/edit`, `/terms/edit` | Fixed pages |
| `/admin/images`, `/admin/videos` | The library |

## How it works

- `Page` holds projects and fixed pages. Its columns are what visitors see; `draft_content`
  is the edit in progress. Only `Content::Publish` moves one to the other.
- A draft can be incomplete. Publishing a project needs a title, a summary and text under
  the headings.
- `lock_version` stops one tab from overwriting another: the save answers 409 and keeps
  what was typed.
- `facts` is the line under the cover: client, location, year, scope.
- The text is sanitised HTML. Images and videos carry their library id; their address is
  worked out when the page renders.
- Uploads are private (`storage/editorial`). Publishing copies what the page uses to
  `public/media`. Keep both folders between deploys.
- "Show on home" places a project on home when it is published, newest choice first.
- Archiving hides a project and keeps its content.
- `bin/rails editorial:prune_uploads` lists uploads unused for a week; `DRY_RUN=0` deletes them.

The seed adds the draft "Sample project", with placeholder text that explains each part.
