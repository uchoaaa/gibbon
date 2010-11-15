require 'httparty'
require 'json'

module Gibbon
  class API
    include HTTParty

    attr_accessor :apikey

    def initialize(apikey = nil, extra_params = {})
      @apikey = apikey
      @default_params = {:apikey => apikey}.merge(extra_params)
    end

    def apikey=(value)
      @apikey = value
      @default_params = @default_params.merge({:apikey => @apikey})
    end

    def base_api_url
      dc = @apikey.blank? ? '' : "#{@apikey.split("-").last}."
      "https://#{dc}api.mailchimp.com/1.3/?method="
    end

    def call(method, params = {})
      url = base_api_url + method
      params = params.merge(@default_params)
      response = API.post(url, :body => params.to_json)

      begin
        response = JSON.parse(response.body)
      rescue
        response = response.body
      end
      response
    end

    def method_missing(method, *args)
      method = method.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase } #Thanks for the gsub, Rails
      method = method[0].chr.downcase + method[1..-1].gsub(/aim$/i, 'AIM')
      args = {} unless args.length > 0
      args = args[0] if (args.class.to_s == "Array")
      call(method, args)
    end
  end
end