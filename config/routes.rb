Rails.application.routes.draw do
  get 'about' => 'about#show', :as => :about
  get 'custom-prices' => 'custom_prices#index', :as => :custom_prices
  put 'custom-prices' => 'custom_prices#update'
  delete 'custom-prices' => 'custom_prices#destroy'
  get 'custom-skills' => 'custom_skills#index', :as => :custom_skills
  put 'custom-skills' => 'custom_skills#update'
  get 'experience-table' => 'experience_table#show', :as => :experience_table

  root :to => 'items#index'
end
