Rails.application.routes.draw do
  # users
  devise_for :users, path: "", sign_out_via: [:get],
    controllers: { sessions: "users/sessions" },
    path_names: { sign_in: "login", sign_out: "logout" }

  # While the site is in its "coming soon" stage the root is the holding screen.
  # Admins preview the real home at /home.
  root "static#home"
  get "home" => "static#index", as: :home

  # Work. Administrators edit it here, on the page itself.
  resources :projects, only: %i[index show new edit], param: :slug do
    get :preview, on: :member
  end

  get "house" => "static#house", as: :house
  get "technology" => "static#technology", as: :technology
  get "contact" => "static#contact", as: :contact

  # legals
  get "privacy" => "legals#privacy", as: :privacy
  get "cookies" => "legals#cookies", as: :cookies
  get "terms" => "legals#terms", as: :terms

  # fixed pages are edited at their own URL
  scope ":slug", controller: "documents", constraints: { slug: Regexp.union(Content::Location::FIXED) } do
    get "edit", action: :edit, as: :edit_document
    get "preview", action: :preview, as: :preview_document
  end

  # what the editor saves to
  namespace :editor do
    resources :pages, only: :create do
      resource :draft, only: :update
      resource :publication, only: :create
      resource :archive, only: :update
    end
    resources :images, :videos, only: %i[index create] do
      get :preview, on: :member
    end
    get "home-preview/:page_id" => "home_previews#show", as: :home_preview
  end

  # admin
  namespace :admin do
    get "" => "admin#index"
    resources :images, :videos, except: :edit
  end

  # data
  get "manifest.json" => "site_info#manifest", as: :manifest, defaults: { format: :json }
  get "climate" => "climate#show", as: :climate, defaults: { format: :json }
  get "robots" => "site_info#robots"
  get "humans" => "site_info#humans"
  # sitemaps
  get "sitemap" => "sitemaps#index"
  get "sitemap-static" => "sitemaps#static"
  get "images/sitemap" => "sitemaps#images"
  get "videos/sitemap" => "videos#sitemap"

  # internal sandbox, admins only
  get "editor" => "lab#editor", as: :lab_editor
  get "web-lab" => "lab#index", as: :lab
  get "web-lab/:slug" => "lab#show", as: :experiment

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
