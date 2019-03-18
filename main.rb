# frozen_string_literal: true

require 'benchmark'
require_relative 'lib/client'
require_relative 'lib/thread_pool'

# Есть три типа эндпоинтов API
# Тип A:
#   - работает 1 секунду
#   - одновременно можно запускать не более трёх
# Тип B:
#   - работает 2 секунды
#   - одновременно можно запускать не более двух
# Тип C:
#   - работает 1 секунду
#   - одновременно можно запускать не более одного

class Main
  def initialize(client = Client.new('https://localhost:9292'), logfile = 'tmp/log.txt')
    @client = client
    @endpoint_pools = {
      a: ThreadPool.new(size: 3),
      b: ThreadPool.new(size: 2),
      c: ThreadPool.new(size: 1)
    }
    @log = File.new(logfile, 'w')
  end

  def run
    responses = {}
    jobs = [
      { key: :a11, endpoint: :a, run: ->(_) { a(11) } },
      { key: :a12, endpoint: :a, run: ->(_) { a(12) } },
      { key: :a13, endpoint: :a, run: ->(_) { a(13) } },
      { key: :b1,  endpoint: :b, run: ->(_) { b(1) } },
      { key: :b2,  endpoint: :b, run: ->(_) { b(2) } },
      { key: :a21, endpoint: :a, run: ->(_) { a(21) } },
      { key: :a22, endpoint: :a, run: ->(_) { a(22) } },
      { key: :a23, endpoint: :a, run: ->(_) { a(23) } },
      { key: :b3,  endpoint: :b, run: ->(_) { b(3) } },
      { key: :a31, endpoint: :a, run: ->(_) { a(31) } },
      { key: :a32, endpoint: :a, run: ->(_) { a(32) } },
      { key: :a33, endpoint: :a, run: ->(_) { a(33) } },
      {
        key: :c1,
        endpoint: :c,
        await_keys: %i[a11 a12 a13 b1],
        run: ->(result) { c("#{collect_sorted([result[:a11], result[:a12], result[:a13]])}-#{result[:b1]}") }
      },
      {
        key: :c2,
        endpoint: :c,
        await_keys: %i[a21 a22 a23 b2],
        run: ->(result) { c("#{collect_sorted([result[:a21], result[:a22], result[:a23]])}-#{result[:b2]}") }
      },
      {
        key: :c3,
        endpoint: :c,
        await_keys: %i[a31 a32 a33 b3],
        run: ->(result) { c("#{collect_sorted([result[:a31], result[:a32], result[:a33]])}-#{result[:b3]}") }
      },
      {
        key: :result,
        endpoint: :a,
        await_keys: %i[c1 c2 c3],
        run: ->(result) { a(collect_sorted([result[:c1], result[:c2], result[:c3]])) }
      }
    ]

    loop do
      job = jobs.shift

      if job[:await_keys] && !(not_ready = job[:await_keys] - responses.keys).empty?
        @log.puts "job '#{job[:key]}' waits for #{not_ready}"
        jobs.push(job)
        next
      end

      @endpoint_pools[job[:endpoint]].schedule do
        @log.puts "job '#{job[:key]}' pushed to queue"
        responses[job[:key]] = job[:run].call(responses)
      end

      break if jobs.empty?
    end

    @endpoint_pools.each do |_endpoint, pool|
      pool.shutdown
    end

    responses[:result]
  end

  private

  def a(value)
    @client.request('/a', value: value)
  end

  def b(value)
    @client.request('/b', value: value)
  end

  def c(value)
    @client.request('/c', value: value)
  end

  def collect_sorted(arr)
    arr.sort.join('-')
  end
end

time = Benchmark.realtime do
  result = Main.new.run
  puts "\nRESULT = #{result}"
end
puts "Execution complete in *#{time.round(2)} seconds*"
