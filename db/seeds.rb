# Admin login. The address is a placeholder used only to sign in.
email = ENV.fetch("ADMIN_EMAIL", "admin@aristotlehouse.com")
password = "password"
abort "Set ADMIN_PASSWORD to seed the admin user in production." if password.blank?

admin = User.find_or_initialize_by(email: email)
if admin.new_record?
  admin.update!(name: "Aristotle House", username: "aristotle", role: "admin", password: password, password_confirmation: password)
  puts "Admin created: #{email}"
end

# Clients belong to a country.
[
  ["United Arab Emirates", "Emiratos Árabes Unidos", "971", "ae", "are", "asia", "western asia"],
  ["Saudi Arabia", "Arabia Saudita", "966", "sa", "sau", "asia", "western asia"],
  ["Qatar", "Catar", "974", "qa", "qat", "asia", "western asia"],
  ["Kuwait", "Kuwait", "965", "kw", "kwt", "asia", "western asia"],
  ["Bahrain", "Baréin", "973", "bh", "bhr", "asia", "western asia"],
  ["Oman", "Omán", "968", "om", "omn", "asia", "western asia"]
].each do |name_en, name_es, code, alpha_2, alpha_3, continent, sub_continent|
  Country.find_or_create_by!(alpha_2: alpha_2) do |c|
    c.assign_attributes(name_en: name_en, name_es: name_es, code: code, alpha_3: alpha_3, continent: continent, sub_continent: sub_continent)
  end
end

# Editable static pages. `restricted` keeps them from being deleted.
[
  ["house", "House", "Before he was a statue, he was an observer."],
  ["contact", "Contact", "Tell us what you want people to feel."],
  ["privacy", "Privacy notice", "How Aristotle House handles personal data."],
  ["cookies", "Cookie policy", "How Aristotle House uses cookies."],
  ["terms", "Terms and conditions", "Terms of use for this website."]
].each do |slug, title, description|
  Page.find_or_create_by!(slug: slug) do |page|
    page.assign_attributes(title: title, og_title: title, og_description: description, category: "static", restricted: true, lang: "en")
  end
end
