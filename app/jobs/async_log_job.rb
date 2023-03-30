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

  # ジョブのリトライ
  retry_on StandardError, wait: 5.seconds, attempts: 3

  # ジョブの破棄
  discard_on StandardError
  # discard_on SomeError do |job, error|
  #   SomeNotifier.push(error)
  # end

  # 非同期処理時に呼ばれるメソッド
  def perform(message: "hello")
    AsyncLog.create!(message: message)
  end
end
