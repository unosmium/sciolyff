# frozen_string_literal: true

require 'minitest/test'
require 'set'

module SciolyFF
  # Tests that also serve as the specification for the sciolyff file format
  #
  class Events < Minitest::Test
    def setup
      skip unless SciolyFF.rep.instance_of? Hash
      @events = SciolyFF.rep['Events']
      skip unless @events.instance_of? Array
    end

    def test_has_valid_events
      @events.each do |event|
        assert_instance_of Hash, event
      end
    end

    def test_each_event_does_not_have_extra_info
      @events.select { |e| e.instance_of? Hash }.each do |event|
        info = Set.new %w[name trial trialed scoring tiers]
        assert Set.new(event.keys).subset? info
      end
    end

    def test_each_event_has_valid_name
      @events.select { |e| e.instance_of? Hash }.each do |event|
        assert_instance_of String, event['name']
      end
    end

    def test_each_event_has_valid_trial
      @events.select { |e| e.instance_of? Hash }.each do |event|
        assert_includes [true, false], event['trial'] if event.key? 'trial'
      end
    end

    def test_each_event_has_valid_trialed
      @events.select { |e| e.instance_of? Hash }.each do |event|
        assert_includes [true, false], event['trialed'] if event.key? 'trialed'
      end
    end

    def test_each_event_has_valid_scoring
      @events.select { |e| e.instance_of? Hash }.each do |event|
        assert_includes %w[high low], event['scoring'] if event.key? 'scoring'
      end
    end

    def test_each_event_has_valid_tiers
      @events.select { |e| e.instance_of? Hash }.each do |event|
        assert_instance_of Integer, event['tiers'] if event.key? 'tiers'
        assert_includes (1..), event['tiers'] if event.key? 'tiers'
      end
    end

    def test_each_event_has_unique_name
      names = @events.select { |e| e.instance_of? Hash }
                     .map { |e| e['name'] }
      assert_nil names.uniq!
    end
  end
end
