class AsyncLogJob < ApplicationJob
  # 「このジョブクラスはasync_logというキューを使ってください」という指定
  queue_as :async_log

  def perform(message: "hello")
    AsyncLog.create!(message: message)
  end
end
