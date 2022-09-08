# frozen_string_literal: true

require "date"
require_relative "is_day_off/version"
require_relative "is_day_off/store"

module IsDayOff
  class Error < StandardError; end

  class NoDataError < Error
    attr_reader :date

    def initialize(date)
      @date = date
      super("No dayoff.ru data for given date")
    end
  end

  module Core
    def store
      @@store ||= Store.new
    end

    def clear_store!
      @@store = Store.new
    end

    def day_code(date)
      date = normalize_date(date)
      raise NoDataError.new(date) unless (days = store[date.year])
      days[date.yday - 1]
    end

    def workday?(date)
      day_code(date) == "0"
    end

    def holiday?(date)
      !workday?(date)
    end

    def forward_to_workday(date)
      move(:holiday?, :next_day, date)
    end

    def backward_to_workday(date)
      move(:holiday?, :prev_day, date)
    end

    def forward_to_holiday(date)
      move(:workday?, :next_day, date)
    end

    def backward_to_holiday(date)
      move(:workday?, :prev_day, date)
    end

    private

    def move(guard, direction, date)
      date = normalize_date(date)
      while public_send(guard, date)
        date = date.public_send(direction)
      end
      date
    end

    def normalize_date(value)
      value.to_date
    rescue
      raise ArgumentError, "'date' argument must be a Date"
    end
  end

  extend Core
end
