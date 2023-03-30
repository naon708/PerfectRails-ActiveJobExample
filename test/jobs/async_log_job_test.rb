require 'test_helper'

class AsyncLogJobTest < ActiveJob::TestCase
  include ActiveJob::TestHelper

  test "Enqueue AsyncLogJob" do
    assert_enqueued_with(job: AsyncLogJob) do
      AsyncLogJob.perform_later(message: "from test")
      perform_enqueued_jobs
    end

    assert_equal AsyncLog.last.message, "from test"
  end
end
