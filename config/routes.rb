Rails.application.routes.draw do

  # users
  devise_for :users, path: "", :sign_out_via => [ :get ],
  controllers: { sessions: 'users/sessions', registrations: 'users/registrations', passwords: 'users/passwords' }, 
  path_names: { sign_in: 'login', sign_out: 'logout', password: 'secret', confirmation: 'verification', registration: 'new', sign_up: 'register' }
  
  # root "pages#profile"
  root "static#home"
  get "profile" => "pages#profile"
  get "contact" => "pages#contact"
  get "portfolio" => "pages#portfolio"
  
  # admin
  
  namespace :admin do
    get '' => 'admin#index'
    resources :ogs, :countries, :pages, :videos, :images, :clients
    # blog
    get "blog" => "pages#blog", as: :blog
  end
  
  # data
  get "manifest.json" => "site_info#manifest"
  get "robots" => "site_info#robots"
  get "humans" => "site_info#humans"
  get "tech" => "site_info#tech"
  # sitemaps
  get "sitemap" => "sitemaps#index"
  get "sitemap-static" => "sitemaps#static"
  get "images/sitemap" => "sitemaps#images"

  get "videos/sitemap" => "videos#sitemap"
  get "videos/:slug/mpd" => "videos#show"

  # examples 
  get 'examples' => 'examples#index'
  get 'examples/font'

  get 'editor' => 'lab#editor', as: :editor
  get 'web-lab' => 'lab#index', as: :lab
  get 'web-lab/:slug' => 'lab#show', as: :experiment

  # legals
  get ':lang/privacy-notice' => 'legals#privacy', as: :privacy
  get ':lang/aviso-de-privacidad' => 'legals#privacy', as: :privacidad
  get ':lang/politica-de-cookies' => 'legals#cookies', as: :cookies
  get ':lang/terms-conditions' => 'legals#terms', as: :terms
  get ':lang/terminos-y-condiciones' => 'legals#terms', as: :terminos
  
  # blog
  get ":lang/blog" => "blog#index", as: :blog
  get ":lang/blog/:id" => "blog#show", as: :page
  get 'tags/:tag', to: 'posts#index', as: :tag
  get 'like/:id' => "posts#like", as: :like
  
  get "docs" => "site_info#docs", as: :documentation
  
  # Errors
  # https://guides.rubyonrails.org/v4.2.0/action_controller_overview.html#custom-errors-page
  match "404", via: :all, to: "errors#not_found"
  match "422", via: :all, to: "errors#unprocessable_entity"
  match "500", via: :all, to: "errors#server_error"
  get 'offline' => 'errors#offline', as: :offline
  

  get ":lang" => "static#home", as: :home
  
  scope format: true, constraints: { format: /jpg|png|gif|webp|JPG|JPEG|jpeg/ } do
		get '/*anything', to: "errors#image_not_found"
	end
  
end