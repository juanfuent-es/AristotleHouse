Rails.application.routes.draw do
  # users
  devise_for :users, path: "", sign_out_via: [:get],
    controllers: { sessions: "users/sessions" },
    path_names: { sign_in: "login", sign_out: "logout" }

  # While the site is in its "coming soon" stage the root is the holding screen.
  # Admins preview the real home at /home.
  root "static#home"
  get "home" => "static#index", as: :home

  resources :projects, path: "work", only: %i[index show], param: :slug
  resources :articles, path: "thinking", only: %i[index show], param: :slug
  get "house" => "static#house", as: :house
  get "contact" => "static#contact", as: :contact

  # admin
  namespace :admin do
    get "" => "admin#index"
    resources :projects, :articles, :pages, except: :show
    resources :images, :videos, :ogs
    resources :clients, except: :show
  end

  # data
  get "manifest.json" => "site_info#manifest", as: :manifest, defaults: { format: :json }
  get "robots" => "site_info#robots"
  get "humans" => "site_info#humans"
  # sitemaps
  get "sitemap" => "sitemaps#index"
  get "sitemap-static" => "sitemaps#static"
  get "images/sitemap" => "sitemaps#images"
  get "videos/sitemap" => "videos#sitemap"
  get "videos/:slug/mpd" => "videos#show"

  # internal sandbox, admins only
  get "editor" => "lab#editor", as: :editor
  get "web-lab" => "lab#index", as: :lab
  get "web-lab/:slug" => "lab#show", as: :experiment

  # legals
  get "privacy" => "legals#privacy", as: :privacy
  get "cookies" => "legals#cookies", as: :cookies
  get "terms" => "legals#terms", as: :terms

  # Errors
  # https://guides.rubyonrails.org/v4.2.0/action_controller_overview.html#custom-errors-page
  match "404", via: :all, to: "errors#not_found"
  match "422", via: :all, to: "errors#unprocessable_entity"
  match "500", via: :all, to: "errors#server_error"
  get "offline" => "errors#offline", as: :offline

  scope format: true, constraints: { format: /jpg|png|gif|webp|JPG|JPEG|jpeg/ } do
    get "/*anything", to: "errors#image_not_found"
  end
end
