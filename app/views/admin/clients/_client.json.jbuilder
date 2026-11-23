json.extract! client, :id, :name, :description, :url, :email, :logo, :country_id, :address, :created_at, :updated_at
json.url client_url(client, format: :json)
