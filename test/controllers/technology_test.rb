require "test_helper"

class TechnologyTest < ActionDispatch::IntegrationTest
  setup do
    travel_to Time.zone.local(2026, 11, 23, 10)
    series = (0..48).map { |hour| [(Time.current.beginning_of_day + hour.hours).to_i, 29.0, 62.5, 6.0, 25.0] }
    Climate::STORE.write(Climate::KEY, Climate::Forecast.new(series: series, expires_at: 1.hour.from_now))
  end

  teardown do
    Climate::STORE.clear
    travel_back
  end

  test "launched technology page exposes a forecast reading and active navigation" do
    with_coming_soon(false) do
      get technology_path
      assert_response :success
      assert_select "title", "Technology · Aristotle House"
      assert_select "nav[aria-label='Main'] a[aria-current='page'][href=?]", technology_path
      assert_select "aside.day"
      assert_select "meter[value='0.5']", count: 3
      assert_select "meter[value='0.25']", count: 1
      assert_select "a[href='https://www.met.no/en']", "MET Norway"
    end
  end

  test "day and night previews use the same solar calculation as the scene" do
    with_coming_soon(false) do
      get technology_path(at: "23:00")
      assert_response :success
      assert_select "aside.night", /23:00 GST/
      assert_select "aside a[aria-current='true']", "Night · 23:00"

      get technology_path(at: "13:00")
      assert_response :success
      assert_select "aside.day", /13:00 GST/
      assert_select "aside a[aria-current='true']", "Day · 13:00"

      get technology_path(at: "invalid")
      assert_response :success
      assert_select "aside a[aria-current='true']", "Now"
    end
  end

  test "missing forecast keeps the solar reading without invented weather" do
    Climate::STORE.write(Climate::KEY, Climate::Forecast.new(series: [], expires_at: 1.hour.from_now))
    with_coming_soon(false) do
      get technology_path
      assert_response :success
      assert_select "aside.day", /forecast is unavailable/
      assert_select "meter", count: 0
      assert_select "a[href='https://www.met.no/en']", count: 0
    end
  end

  test "technology enters the sitemap only after launch" do
    with_coming_soon(true) do
      get "/sitemap-static"
      assert_response :success
      assert_select "loc", text: /\/technology\z/, count: 0
    end
    with_coming_soon(false) do
      get "/sitemap-static"
      assert_response :success
      assert_select "loc", text: /\/technology\z/, count: 1
    end
  end
end
