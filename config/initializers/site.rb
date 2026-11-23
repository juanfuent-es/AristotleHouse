# Single source for everything that names the House in views, metadata and mail.
# Values that are not decided yet (domain, contact, social) come from ENV and
# stay blank until they exist: views hide whatever is blank.
Rails.application.config.x.site = ActiveSupport::OrderedOptions.new.merge!(
  name: "Aristotle House",
  short_name: "Aristotle",
  tagline: "Experiential intelligence",
  description: "Aristotle House is an experiential agency in Dubai. We read people before we build for them.",
  city: "Dubai",
  country: "UAE",
  coordinates: ["25.2048° N", "55.2708° E"],
  established: "2027",
  host: ENV["APP_HOST"].presence,
  contact_email: ENV["CONTACT_EMAIL"].presence,
  mail_from: ENV["MAIL_FROM"].presence || "no-reply@example.com",
  instagram_url: ENV["INSTAGRAM_URL"].presence,
  linkedin_url: ENV["LINKEDIN_URL"].presence,
  gtm_id: ENV["GTM_ID"].presence,
  # While true, visitors only see the holding screen. Admins can browse everything.
  coming_soon: ENV.fetch("COMING_SOON", "true") != "false"
)
