module ApplicationHelper

	def device
		require "browser"
		if browser.device.mobile?
			return "mobile"
		elsif browser.device.tablet?
			return "tablet"
		else
			return "desktop"
		end
	end

	def canonical
		# "https://#{request.host_with_port}/#{request.original_url}"
		request.original_url.gsub('http','https').gsub('www','')
	end

	def lang_link(lang='es')
		return "/#{lang}#{request.path.gsub("/#{@lang}",'')}"
	end

	def texto(_copy, _lang="es")
		return "<p>Undefined</p>".html_safe if _copy.nil?
		case _lang
        when "en"
            return _copy.en
        when "pt"
            return _copy.pt
        else
            return _copy.es
        end
	end

	def full_title title
		base_title = 'Web Craft Developer'
		if title.empty?
			base_title
		else
			"#{title} | #{base_title}"
		end
	end

	def meta_image image
		_url = image.empty? ? "/juanfuent.es-share.png" : image
		return "#{request.protocol}#{request.host_with_port}#{_url}"
	end

	def meta_description description
		return description.empty? ? "Diseño y desarrollo digital desde cero." : description
	end

	def breadcrumb(_url="")
		urls = ["Root"]
		urls << _url if _url.present?
		return urls.join(" > ")
	end

	def meta_keys keys
		return keys.empty? ? "" : ""
	end

end