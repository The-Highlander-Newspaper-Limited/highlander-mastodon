# frozen_string_literal: true

resources :categories, except: [:show]

resources :accounts, only: [] do
  scope module: :accounts do
    resource :categories, only: [:show, :update]
  end
end
