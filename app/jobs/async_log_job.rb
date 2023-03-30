class AsyncLogJob < ApplicationJob
  # 「このジョブクラスはasync_logというキューを使ってください」という指定
  # queue_as :async_log

  # Blockにすることでジョブの内容によってキューを選ぶようにもできる
  queue_as do
    case self.arguments.first[:message]
    when "to async_log"
      :async_log
    when "to another_queue"
      :another_queue
    else
      :default
    end
  end

  def perform(message: "hello")
    AsyncLog.create!(message: message)
  end
end
