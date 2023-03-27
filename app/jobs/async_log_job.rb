class AsyncLogJob < ApplicationJob
  queue_as :default

  def perform(message: "hello")
    AsyncLog.create!(message: message)
  end
end
