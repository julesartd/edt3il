Rails.application.routes.draw do

  ############# API SCOPE #################

  namespace :api, module: :api, defaults: { format: :json } do
    resources :schedule, only: [:index]
  end

end
