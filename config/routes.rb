Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  get "about" => "about#show", :as => :about
  get "custom-prices" => "custom_prices#index", :as => :custom_prices
  put "custom-prices" => "custom_prices#update"
  delete "custom-prices" => "custom_prices#destroy"
  get "custom-skills" => "custom_skills#index", :as => :custom_skills
  put "custom-skills" => "custom_skills#update"
  get "experience-table" => "experience_table#show", :as => :experience_table

  root to: "items#index"
end
