require "test_helper"

class ClimateTest < ActiveSupport::TestCase
  setup { Climate::STORE.clear }
  teardown { Climate::STORE.clear }

  def store(series)
    Climate::STORE.write(Climate::KEY, Climate::Forecast.new(series: series, expires_at: 1.hour.from_now))
  end

  test "the sun follows Dubai" do
    assert_in_delta 88.2, Climate.new(Time.utc(2026, 6, 21, 8, 21)).sun, 0.5 # solar noon, June solstice
    assert_in_delta 41.4, Climate.new(Time.utc(2026, 12, 21, 8, 17)).sun, 0.6 # solar noon, December solstice
    assert_operator Climate.new(Time.utc(2026, 11, 23, 21)).sun, :<, -50
  end

  test "the page is ink or bone, never in between" do
    values = (0..95).map { |i| Climate.new(Time.utc(2026, 11, 23) + (i * 15).minutes).drive[:day] }
    assert_equal [0.0, 1.0], values.uniq.sort
  end

  test "weather moves between forecast hours" do
    now = Time.current.change(usec: 0)
    store [[now.to_i - 1800, 20.0, 50.0, 2.0, 0.0], [now.to_i + 1800, 30.0, 70.0, 4.0, 100.0]]
    assert_in_delta 25, Climate.new(now).weather[:temperature], 0.01
    assert_in_delta 0.5, Climate.new(now).drive[:cloud], 0.01
  end

  test "humid heat feels hotter than the air" do
    now = Time.current
    store [[now.to_i, 40.0, 60.0, 1.0, 0.0], [now.to_i + 3600, 40.0, 60.0, 1.0, 0.0]]
    assert_operator Climate.new(now).perceived, :>, 45
  end

  test "nothing is invented when there is no forecast" do
    store []
    json = Climate.now.as_json
    assert_nil json[:weather]
    assert_nil json[:source]
    assert_includes 0.0..1.0, json[:drive][:day]
  end

  test "a failed request keeps the last forecast and waits before trying again" do
    now = Time.current
    old = Climate::Forecast.new(series: [[now.to_i, 22.0, 50.0, 1.0, 0.0], [now.to_i + 3600, 22.0, 50.0, 1.0, 0.0]], expires_at: 1.minute.ago)
    Climate::STORE.write(Climate::KEY, old)
    calls = 0
    original = Climate.method(:request)
    Climate.define_singleton_method(:request) { |_| calls += 1; raise Errno::ECONNREFUSED }
    2.times { assert_equal 22.0, Climate.new(now).weather[:temperature] }
    assert_equal 1, calls
  ensure
    Climate.define_singleton_method(:request, original) if original
  end

  test "previews another hour and ignores nonsense" do
    store []
    assert_equal "13:30", Climate.at("13:30").as_json[:clock]
    assert_equal Climate.now.as_json[:clock], Climate.at("99:99<script>").as_json[:clock]
  end
end
