Rails.application.routes.draw do
  devise_for :users

  root to: "reservations#index"

  resources :reservations, only: [:index, :create_or_update] do
    collection do
      put :create_or_update
    end
  end

  namespace :admin do
    resources :room_lock_pin_codes, only: [:reset, :resend] do
      member do
        put :resend
        put :reset
      end
    end
  end
end
