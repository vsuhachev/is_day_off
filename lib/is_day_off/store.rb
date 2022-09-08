# frozen_string_literal: true

require "net/http"

module IsDayOff
  IS_DAY_OFF_HOST = "isdayoff.ru"

  class Store
    def initialize
      @years = {}
    end

    def [](year)
      year = normalize_year(year)
      return @years[year] if @years.key?(year)
      @years[year] = fetch(year)
    end

    def fetch(year)
      response = Net::HTTP.get_response(IS_DAY_OFF_HOST, "/api/getdata?year=#{year}")
      return unless response.code_type == Net::HTTPOK
      return unless (365..366) === response.body.length
      return unless response.body.chars.any? { |item| item != "0" }
      response.body
    end

    def normalize_year(year)
      year.to_i
    end
  end
end
