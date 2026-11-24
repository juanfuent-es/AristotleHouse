require "net/http"

# What the air over the House is doing right now, and how the scene should read it.
#
# Weather comes from MET Norway (CC BY 4.0, commercial use allowed; credited in /humans). One forecast is
# kept on disk and reused by every visitor: it is asked for again only when it expires,
# by one request at a time, and an old one is better than none. The sun needs no service.
class Climate
  LATITUDE = 25.2048
  LONGITUDE = 55.2708
  ENDPOINT = URI("https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=#{LATITUDE}&lon=#{LONGITUDE}")
  SOURCE = { name: "MET Norway", url: "https://www.met.no/en" }.freeze
  STORE = ActiveSupport::Cache::FileStore.new(Rails.root.join("tmp/cache/climate", Rails.env))
  KEY = "forecast".freeze
  DAYBREAK = 4 # degrees of sun that turn the page from ink to bone
  MIN_LIFE = 15.minutes
  RETRY = 5.minutes
  STALE = 24.hours

  Forecast = Struct.new(:series, :expires_at, :modified, :fetched_at, keyword_init: true)

  class << self
    def now
      new(Time.current)
    end

    # The next time the clock in Dubai says HH:MM. Lets anyone preview another hour.
    def at(clock)
      match = clock.to_s.match(/\A([01]?\d|2[0-3]):([0-5]\d)\z/)
      return now unless match
      time = Time.current.change(hour: match[1].to_i, min: match[2].to_i)
      new(time < Time.current ? time + 1.day : time)
    end

    def forecast
      cached = STORE.read(KEY)
      return cached if cached && cached.expires_at.future?
      return cached unless STORE.write("lock", true, unless_exist: true, expires_in: 20.seconds)
      fresh = refresh(cached)
      STORE.write(KEY, fresh, expires_in: STALE) if fresh
      fresh
    end

    # MET asks every client to identify itself. Without that, production does not call.
    def user_agent
      ENV["WEATHER_USER_AGENT"].presence || ("weather-client/1.0" unless Rails.env.production?)
    end

    private

    def refresh(cached)
      return cached unless user_agent
      response = request(cached)
      case response
      when Net::HTTPNotModified
        cached.tap { |f| f.expires_at = expiry(response) }
      when Net::HTTPSuccess
        Forecast.new(series: parse(response.body), expires_at: expiry(response), modified: response["last-modified"], fetched_at: Time.current)
      else
        raise "MET answered #{response.code}"
      end
    rescue StandardError => e
      Rails.logger.warn("Climate: #{e.class} #{e.message}")
      (cached || Forecast.new(series: [], modified: nil, fetched_at: nil)).tap { |f| f.expires_at = RETRY.from_now }
    end

    def request(cached)
      headers = { "User-Agent" => user_agent, "Accept" => "application/json" }
      headers["If-Modified-Since"] = cached.modified if cached&.modified
      Net::HTTP.start(ENDPOINT.host, ENDPOINT.port, use_ssl: true, open_timeout: 2, read_timeout: 3) do |http|
        http.get(ENDPOINT.request_uri, headers)
      end
    end

    def expiry(response)
      [Time.httpdate(response["expires"].to_s), MIN_LIFE.from_now].max
    rescue ArgumentError
      MIN_LIFE.from_now
    end

    def parse(body)
      JSON.parse(body).dig("properties", "timeseries").first(60).map do |row|
        details = row.dig("data", "instant", "details")
        [Time.iso8601(row["time"]).to_i, *details.values_at("air_temperature", "relative_humidity", "wind_speed", "cloud_area_fraction").map(&:to_f)]
      end
    end
  end

  attr_reader :time

  def initialize(time)
    @time = time.in_time_zone
  end

  # Interpolated between the hours of the forecast. Nil when there is nothing honest to say.
  def weather
    return @weather if defined?(@weather)
    @weather = interpolate(self.class.forecast&.series || [])
  end

  # Degrees above the horizon (NOAA, short form).
  def sun
    @sun ||= begin
      days = (time.to_f - Time.utc(2000, 1, 1, 12).to_f) / 86_400
      mean = radians(357.529 + 0.98560028 * days)
      ecliptic = radians(280.459 + 0.98564736 * days + 1.915 * Math.sin(mean) + 0.020 * Math.sin(2 * mean))
      tilt = radians(23.439 - 0.00000036 * days)
      ascension = Math.atan2(Math.cos(tilt) * Math.sin(ecliptic), Math.cos(ecliptic))
      declination = Math.asin(Math.sin(tilt) * Math.sin(ecliptic))
      sidereal = radians((18.697374558 + 24.06570982441908 * days) * 15 + LONGITUDE)
      hour = sidereal - ascension
      latitude = radians(LATITUDE)
      Math.asin(Math.sin(latitude) * Math.sin(declination) + Math.cos(latitude) * Math.cos(declination) * Math.cos(hour)) * 180 / Math::PI
    end
  end

  def phase
    return "day" if sun > 8
    return "night" if sun < -6
    time.hour < 12 ? "dawn" : "dusk"
  end

  # Everything the scene moves with, from 0 to 1. Without weather, a mild still evening.
  def drive
    {
      # Ink or bone, never in between: half of each is grey.
      day: sun > DAYBREAK ? 1.0 : 0.0,
      horizon: Math.exp(-((sun - 1) / 6.0)**2),
      warmth: weather ? ramp(12, 46, weather[:temperature]) : 0.45,
      wind: weather ? ramp(0, 12, weather[:wind]) : 0.2,
      haze: weather ? ramp(30, 95, weather[:humidity]) : 0.4,
      cloud: weather ? ramp(0, 100, weather[:cloud]) : 0.0
    }.transform_values { |value| value.round(3) }
  end

  def as_json(*)
    {
      clock: time.strftime("%H:%M"),
      phase: phase,
      sun: sun.round(1),
      weather: weather&.transform_values { |value| value.round(1) },
      drive: drive,
      source: weather && SOURCE
    }
  end

  private

  def interpolate(series)
    after = series.index { |row| row[0] >= time.to_i }
    return if after.nil?
    # The forecast may start a little after now.
    return if after.zero? && series[0][0] - time.to_i > 2.hours
    from = series[[after - 1, 0].max]
    to = series[after]
    span = to[0] - from[0]
    t = span.zero? ? 0.0 : (time.to_i - from[0]) / span.to_f
    values = from.drop(1).zip(to.drop(1)).map { |a, b| a + (b - a) * t }
    %i[temperature humidity wind cloud].zip(values).to_h
  end

  def radians(degrees) = degrees * Math::PI / 180

  def ramp(from, to, value) = ((value - from) / (to - from).to_f).clamp(0.0, 1.0)
end
