module ApplicationHelper
  def device
    return "mobile" if browser.device.mobile?
    browser.device.tablet? ? "tablet" : "desktop"
  end

  def canonical
    "#{request.base_url}#{request.path}"
  end

  def full_title(title)
    title.blank? ? "#{site.name} · #{site.tagline}" : "#{title} · #{site.name}"
  end

  def meta_image(image)
    "#{request.base_url}#{image.presence || "/brand/share.jpg"}"
  end

  def meta_description(description)
    description.presence || site.description
  end

  # Use the supplied gaze and wordmark masters together.
  def lockup(tone: :light, **options)
    image_tag "/brand/lockup-#{tone}.svg", alt: site.name, width: 720, height: 78, **options
  end

  def seal(tone: :light, **options)
    image_tag "/brand/seal-#{tone}.svg", alt: site.name, width: 40, height: 40, **options
  end

  # Micrographic symbols, drawn in the text colour. Decorative unless labelled.
  def micrograph(name, label: nil, **options)
    aria = label ? { role: "img", "aria-label": label } : { "aria-hidden": true }
    tag.svg(tag.use(href: "/brand/micro.svg##{name}"), **aria, **options, fill: "currentColor")
  end

  def nav_item(label, path, **options)
    active = request.path == path || request.path.start_with?("#{path}/")
    link_to label, path, **options, "aria-current": (active ? "page" : nil)
  end

  # Plain text with paragraphs. Never renders markup from the CMS.
  def paragraphs(text)
    simple_format(h(text.to_s), {}, sanitize: false)
  end
end
