# README

### Active Job

```shell
% bin/rails g job async_log

invoke  test_unit
create    test/jobs/async_log_job_test.rb
create  app/jobs/async_log_job.rb
```

```shell
% AsyncLogJob.perform_later

Enqueued AsyncLogJob (Job ID: d6ef7806-1b42-4fce-8f7c-4ac13763fc81) to Async(default)
=> #<AsyncLogJob:0x00007f8dbdcdf558 @arguments=[], @job_id="d6ef7806-1b42-4fce-8f7c-4ac13763fc81", @queue_name="default", @priority=nil, @executions=0, @exception_executions={}, @provider_job_id="9b798372-5751-4cb3-9210-3321dac057ac">
irb(main):004:0> Performing AsyncLogJob (Job ID: d6ef7806-1b42-4fce-8f7c-4ac13763fc81) from Async(default) enqueued at 2023-03-27T12:20:19Z
   (0.9ms)  SELECT sqlite_version(*)
   (0.1ms)  begin transaction
  AsyncLog Create (2.1ms)  INSERT INTO "async_logs" ("message", "created_at", "updated_at") VALUES (?, ?, ?)  [["message", "hello"], ["created_at", "2023-03-27 12:20:20.166637"], ["updated_at", "2023-03-27 12:20:20.166637"]]
   (1.2ms)  commit transaction
Performed AsyncLogJob (Job ID: d6ef7806-1b42-4fce-8f7c-4ac13763fc81) from Async(default) in 73.92ms
```

```shell
# 10秒後にジョブ実行
% AsyncLogJob.set(wait: 10.seconds).perform_later(message: "delay")
```
- https://api.rubyonrails.org/classes/ActiveJob/Enqueuing.html

### ジョブへ渡す引数の制限
- ARオブジェクトをジョブへ渡すことができる
- シリアライズ/デシリアライズの処理にGlobal IDが使われる
- Grobal IDでモデルオブジェクトの情報をURI文字列に変換してからキューに保存する
- URI文字列からGlobalID::Locatorを使ってモデルオブジェクトへ復元してキューから取り出す
- この時findメソッドが使われるので、キューに追加〜非同期実行の間にレコードが変更されるケースに注意する
```ruby
puts AsyncLog.last.to_global_id

#=> gid://active-job-example/AsyncLog/3
```
