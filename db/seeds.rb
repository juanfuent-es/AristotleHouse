# Admin login. The address is a placeholder used only to sign in. In production the
# password comes from ADMIN_PASSWORD; there is no default.
email = "admin@aristotle-house.com"
password = "password"

admin = User.find_by(email: email)
unless admin
  abort "Set ADMIN_PASSWORD to create the admin user." unless password
  admin = User.create!(email: email, name: "Aristotle House", username: "aristotle", role: "admin", password: password)
  puts "Admin created: #{email}"
end

# Fixed pages. Without text, house and contact show their designed layout.
[
  ["house", "House", "Before he was a statue, he was an observer."],
  ["contact", "Contact", "Tell us what you want people to feel."],
  ["privacy", "Privacy notice", "How Aristotle House handles personal data."],
  ["cookies", "Cookie policy", "How Aristotle House uses cookies."],
  ["terms", "Terms and conditions", "Terms of use for this website."]
].each do |slug, title, description|
  Page.create_with(title: title, description: description, category: "static", publication_state: "published", published_at: Time.current).find_or_create_by!(slug: slug)
end

# The base case: a draft that shows what each part of a project is for. Duplicate its
# structure, then archive it.
unless Page.exists?(slug: "sample-project")
  library = lambda do |file, title, alt|
    Image.find_by(title: title) || File.open(Rails.public_path.join("brand/img", file)) do |tempfile|
      Media::UploadImage.call(upload: ActionDispatch::Http::UploadedFile.new(tempfile: tempfile, filename: file), title: title, alt: alt)
    end
  end
  cover = library.call("isotherm.webp", "Sample cover", "Placeholder: a heat reading of the bust")
  detail = library.call("head-profile.webp", "Sample detail", "Placeholder: the bust in profile")

  Content::CreateDraft.call(author: admin, attributes: {
    title: "Sample project",
    description: "Placeholder. One sentence that says what was built, for whom, and what people did in it.",
    cover_image_id: cover.id,
    facts: { client: "Client name", location: "City, country", year: "Year", scope: "What the House did" },
    tag_list: "Sample",
    content: <<~HTML
      <h2>The question</h2>
      <p>Placeholder. What the brand wanted people to feel, and what nobody knew yet about how they would behave.</p>
      <p>Two short paragraphs are enough. Say where the project started and what made it difficult.</p>
      <img data-image-id="#{detail.id}" alt="">
      <h2>What we built</h2>
      <p>Placeholder. Describe the space, the sequence and the moments that mattered, in the order a visitor met them.</p>
      <ul><li><p>A first decision and the reason behind it.</p></li><li><p>A material, a sound or a light people noticed.</p></li><li><p>What stayed after the event.</p></li></ul>
      <blockquote><p>Placeholder for one line worth remembering.</p></blockquote>
      <h2>What we learned</h2>
      <p>Placeholder. Where people stopped, what they reached for and what they remembered. Use figures only when they were measured.</p>
    HTML
  })
end
