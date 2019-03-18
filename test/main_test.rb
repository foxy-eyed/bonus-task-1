# frozen_string_literal: true

require 'benchmark'
require 'minitest/autorun'
require_relative '../main'

class MainTest < Minitest::Test
  def test_correct_result
    result = Main.new.run

    assert_equal '0bbe9ecf251ef4131dd43e1600742cfb', result
  end

  def test_execution_time
    time = Benchmark.realtime { Main.new.run }

    assert time <= 7, "Time must be less then or equal to 7 seconds (actual: #{time})"
  end
end
