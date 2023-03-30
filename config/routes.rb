Rails.application.routes.draw do
  if Rails.env.development?
    require "sidekiq/web"
    mount Sidekiq::Web => "/sidekiq"
  end
end
