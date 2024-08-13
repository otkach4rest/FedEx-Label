Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  # resources :fedex_labels, only: [:index, :show, :create, :new, :new_label_us_shipper]
  resources :fedex_labels do
    get 'download', on: :member
  end
  root "fedex_labels#index"
  get '/new_fedex_label_with_us_recipient',        :to => 'fedex_labels#new_fedex_label_with_us_recipient',  as: :new_fedex_label_with_us_recipient
  get '/new_fedex_label_with_ca_recipient',        :to => 'fedex_labels#new_fedex_label_with_ca_recipient',  as: :new_fedex_label_with_ca_recipient
  get '/new_fedex_label_with_jp_recipient',        :to => 'fedex_labels#new_fedex_label_with_jp_recipient',  as: :new_fedex_label_with_jp_recipient

  post '/create_international',        :to => 'fedex_labels#create_international',  as: :create_international



end

