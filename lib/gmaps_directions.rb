require 'yajl'
require 'yajl/http_stream'
require 'uri'
require 'active_support/core_ext/object/blank'
require 'active_support/configurable'
require 'active_support/ordered_options'
require 'net/http'

module GmapsDirections

  class Config
    DEFAULTS = [:mode, :driving, :units, :metric, :language, :en, :sensor, false, :alternatives, false]

    class <<self
      include ActiveSupport::Configurable
      config_accessor :mode, :units, :language, :sensor, :alternatives

      def config
        @config ||= ActiveSupport::OrderedOptions[*DEFAULTS]
      end

      def reset_to_defaults!
        @config = ActiveSupport::OrderedOptions[*DEFAULTS]
      end

      def to_url_options
        config.inject([]) { |url_options, option| url_options << "#{option.first.to_s}=#{URI.escape(option.last.to_s)}" }.join("&")
      end
    end
  end

  class API
    class <<self
      def find_directions(options = {})
        api_driver = new(:start_address => options[:from], :end_address => options[:to])
        api_driver.call_google
        if api_driver.parsed_directions_response.present? && api_driver.parsed_directions_response["routes"].present?
          return api_driver.parsed_directions_response["routes"].inject([]) do |routes, route_hash|
            routes << Route.new(route_hash, api_driver.parsed_directions_response["status"])
          end
        else
          return []
        end
      end
    end

    DIRECTIONS_API_BASE_URL = "http://maps.googleapis.com/maps/api/directions/json"

    attr_reader :start_address, :end_address, :parsed_directions_response

    def initialize(attributes)
      @start_address = attributes[:start_address]
      @end_address   = attributes[:end_address]
    end

    def call_google
      response = Net::HTTP.get_response(directions_api_url).body
      @parsed_directions_response = Yajl::Parser.parse(response)
    end

    private
      
      def directions_api_url
        URI.parse("#{DIRECTIONS_API_BASE_URL}?origin=#{URI.escape(start_address)}&destination=#{URI.escape(end_address)}&#{Config.to_url_options}")
      end
  end

  class Route
    attr_reader :duration, :formatted_duration, :distance, :formatted_distance,
                :start_address, :end_address, :start_location, :end_location,
                :status
    
    def initialize(gmaps_route_hash, status)
      @duration           = gmaps_route_hash["legs"].first["duration"]["value"]
      @formatted_duration = gmaps_route_hash["legs"].first["duration"]["text"]
      @distance           = gmaps_route_hash["legs"].first["distance"]["value"]
      @formatted_distance = gmaps_route_hash["legs"].first["distance"]["text"]
      @start_address      = gmaps_route_hash["legs"].first["start_address"]
      @end_address        = gmaps_route_hash["legs"].first["end_address"]
      @start_location     = gmaps_route_hash["legs"].first["start_location"]
      @end_location       = gmaps_route_hash["legs"].first["end_location"]
      @status             = status
    end
  end

end
