class SiteInfoController < ApplicationController

	def robots
	end
	
	def manifest
		render json: {
			"name": "JuanFuent.es",
			"short_name": "JuanFuent.es",
			"description": "",
			"icons": [
				{ "src": "/android-chrome-192x192.png", "sizes": "192x192", "type": "image/png" },
				{ "src": "/android-chrome-512x512.png", "sizes": "512x512", "type": "image/png" }
			],
			"start_url": "/",
			"theme_color": "#000000",
			"background_color": "#000000",
			"display": "standalone",
			"scope": "/"
		}
	end

	def sitemap
		@base_url = "#{request.protocol}#{request.host_with_port}"
		respond_to do |format|
			format.xml
		end
	end

	def humans
	end

	def tech
	end

end