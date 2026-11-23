class SiteInfoController < ApplicationController
  skip_before_action :hold_until_launch

  def robots
    @base_url = request.base_url
    render formats: :text
  end

  def manifest
    render json: {
      name: site.name,
      short_name: site.short_name,
      description: site.description,
      icons: [
        { src: "/android-chrome-192x192.png", sizes: "192x192", type: "image/png" },
        { src: "/android-chrome-512x512.png", sizes: "512x512", type: "image/png" },
        { src: "/web-app-manifest-192x192.png", sizes: "192x192", type: "image/png", purpose: "maskable" },
        { src: "/web-app-manifest-512x512.png", sizes: "512x512", type: "image/png", purpose: "maskable" }
      ],
      start_url: "/",
      scope: "/",
      display: "standalone",
      theme_color: "#0B0A0F",
      background_color: "#0B0A0F"
    }
  end

  def humans
    render formats: :text
  end
end
