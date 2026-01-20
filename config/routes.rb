# frozen_string_literal: true

Rails.application.routes.draw do
  # =============================================================================
  # Devise Authentication
  # =============================================================================
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  # =============================================================================
  # Public Pages
  # =============================================================================
  root "pages#home"

  get "about", to: "pages#about", as: :about
  get "contact", to: "contact_inquiries#new", as: :contact

  # Public gallery
  resources :works, only: [:index, :show], path: "gallery"
  resources :categories, only: [:show], path: "gallery/category"

  # Contact form
  resources :contact_inquiries, only: [:create], path: "contact"

  # =============================================================================
  # Customer Portal (authenticated customers)
  # =============================================================================
  namespace :portal do
    get "/", to: "dashboard#index", as: :dashboard
    resources :commissions, only: [:index, :show]
  end

  # =============================================================================
  # Admin Area (authenticated admins only)
  # =============================================================================
  namespace :admin do
    root "dashboard#index"

    resources :works do
      member do
        patch :publish
        patch :unpublish
        patch :feature
        patch :unfeature
        delete :remove_image
      end
      collection do
        patch :update_positions
      end
    end

    resources :categories

    resources :commissions do
      member do
        patch :transition  # For state machine transitions
      end
      resources :commission_updates, only: [:create, :edit, :update, :destroy], as: :updates
    end

    resources :contact_inquiries, only: [:index, :show, :update, :destroy] do
      member do
        patch :mark_responded
        patch :archive
      end
    end

    resources :users, only: [:index, :show, :edit, :update]
  end

  # =============================================================================
  # Health Check & System
  # =============================================================================
  get "up" => "rails/health#show", as: :rails_health_check

  # =============================================================================
  # SEO
  # =============================================================================
  get "sitemap.xml", to: "sitemaps#index", defaults: { format: "xml" }
end
