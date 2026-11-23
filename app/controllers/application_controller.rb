class ApplicationController < ActionController::Base

	before_action :redirect_nonwww, if: -> { Rails.env.production? }
	# before_filter :redirect_nonwww

	after_action :set_vary_header
	around_action :switch_lang

    # ¿Hay un administrador logueado?
    def authenticate_admin!
		if signed_in?
        	redirect_to root_path if !current_user.admin?
		else
			authenticate_user!
		end
    end

	def switch_lang(&action)
		@lang = "es"
		# Evaluamos si existe el idioma en parámtro
		if params[:lang]
			# Si el idioma es válido se asigna como idioma de sitio
			if locale_valid?(params[:lang])
				@lang = params[:lang].to_s.downcase
			else
				render_not_found
			end
		end
		I18n.with_locale(@lang, &action)
	end

	def render_not_found
		render template: 'errors/not_found', status: 404, layout: "errors"
	end

    private 

	def redirect_nonwww
		if (request.host.include? 'www')
			redirect_to 'https://juanfuent.es' + request.fullpath, :status => 301, allow_other_host: true
		end
	end

	def locale_valid?(locale)
		I18n.available_locales.map(&:to_s).include?(locale)
	end

    def set_vary_header
		response.headers["Vary"] = "accept" if request.xhr?
	end

end