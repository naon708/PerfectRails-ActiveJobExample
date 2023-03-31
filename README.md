# Active Job

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

## ジョブへ渡す引数の制限
- ARオブジェクトをジョブへ渡すことができる
- シリアライズ/デシリアライズの処理にGlobal IDが使われる
- Grobal IDでモデルオブジェクトの情報をURI文字列に変換してからキューに保存する
- URI文字列からGlobalID::Locatorを使ってモデルオブジェクトへ復元してキューから取り出す
- この時findメソッドが使われるので、キューに追加〜非同期実行の間にレコードが変更されるケースに注意する
```ruby
puts AsyncLog.last.to_global_id

#=> gid://active-job-example/AsyncLog/3
```

## ジョブの実行
### キューに追加
```shell
% AsyncLogJob.perform_later(message: "from sidekiq")

Enqueued AsyncLogJob (Job ID: 761e0609-7624-43af-b758-8d09131dffb6) to Sidekiq(default) with arguments: {:message=>"from sidekiq"}

=> <AsyncLogJob:0x00007fc257ae3f00 @arguments=[{:message=>"from sidekiq"}], @job_id="761e0609-7624-43af-b758-8d09131dffb6", @queue_name="default", @priority=nil, @executions=0, @exception_executions={}, @provider_job_id="29777483e35223f687cffc1d">


# キューに入ったJobはまだ実行されてない(モデルはまだ更新されてない)
% AsyncLog.last
```

### sidekiqプロセスを起動するとJobが実行される
```shell
% bundle exec sidekiq

pid=86736 tid=ovcendd3g 
INFO: 
	Booted Rails 6.0.3 application in development environment
	Starting processing, hit Ctrl-C to stop

pid=86736 tid=ovcerei3k class=AsyncLogJob jid=29777483e35223f687cffc1d 
	INFO: start

Performing AsyncLogJob (Job ID: 761e0609-7624-43af-b758-8d09131dffb6) from Sidekiq(default) enqueued at 2023-03-29T00:56:46Z with arguments: {:message=>"from sidekiq"}

Performed AsyncLogJob

pid=86736 tid=ovcerei3k class=AsyncLogJob jid=29777483e35223f687cffc1d elapsed=0.393 
	INFO: done


# モデルが更新された
AsyncLog.last
```

### Docker(redis)止めてみた
```
% AsyncLogJob.perform_later(message: "stop docker")

Enqueued AsyncLogJob (Job ID: 1d26ffec-8961-44ee-955f-4819faa20466) to Sidekiq(default) with arguments: {:message=>"stop docker"}
....
Redis::CannotConnectError (Error connecting to Redis on 127.0.0.1:6379 (Errno::ECONNREFUSED))
```
- sidekiqはジョブキューの管理にredisを使用していて、redisがインストールされていない場合はsidekiqを実行できない
- asyncアダプターはアプリケーションのプロセス内で動作するためキューイングにredisを必要としない
- アプリケーションをスケールアウトさせる場合は、複数のプロセスでアプリケーションを実行する必要があるのでredisなどの外部ストレージが必要になってくる

## ジョブのテスト
- [https://railsguides.jp/testing.html#ジョブをテストする](https://railsguides.jp/testing.html#%E3%82%B8%E3%83%A7%E3%83%96%E3%82%92%E3%83%86%E3%82%B9%E3%83%88%E3%81%99%E3%82%8B)
- perform_enqueued_jobsで明示的にJobを実行する
    - [https://api.rubyonrails.org/classes/ActiveJob/TestHelper.html](https://api.rubyonrails.org/classes/ActiveJob/TestHelper.html)
