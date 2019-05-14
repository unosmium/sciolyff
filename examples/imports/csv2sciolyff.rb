#!/usr/bin/env ruby
# frozen_string_literal: true

# Kinda converts a specific CSV format to SciolyFF
# The sections Tournament and Penalties still need to be added manually
#
require 'csv'
require 'yaml'

if ARGV.empty?
  puts 'needs a file to convert'
  exit 1
end

csv = CSV.read(ARGV.first)

events = csv.first.drop(2).map do |csv_event|
  event = { 'name' => csv_event[/^[^(]+/].strip,
            'trial' => csv_event.end_with?('(Trial)'),
            'trialed' => csv_event.end_with?('(Trialed)') }

  event.delete('trial') if event['trial'] == false
  event.delete('trialed') if event['trialed'] == false

  event
end

teams = csv.drop(1).map { |r| r[0..1] }.map do |csv_team|
  { 'school' => csv_team.last[/^[^(]+/].strip,
    'number' => csv_team.first.to_i,
    'state' => csv_team.last[/\([A-Z]{2}\)/][/[A-Z]{2}/] }
end

placings = csv.drop(1).map do |csv_row|
  csv_row.drop(2).each_with_index.map do |csv_place, col_index|
    placing = { 'event' => events[col_index]['name'],
                'team' => csv_row.first.to_i,
                'place' => csv_place.to_i }

    if placing['place'] > teams.count
      placing.store('participated', false) if placing['place'] == teams.size + 1
      placing.store('disqualified', true) if placing['place'] == teams.size + 2
      placing.delete('place')
    end

    placing
  end
end.flatten

# Identify and fix placings that are just participations points
events.map { |e| e['name'] }.each do |event_name|
  last_place_placings = placings.select do |p|
    p['event'] == event_name &&
      p['place'] == teams.count
  end
  next unless last_place_placings.count > 1

  last_place_placings.each do |placing|
    placing.store('participated', true)
    placing.delete('place')
  end
end

rep = { 'Events' => events,
        'Teams' => teams,
        'Placings' => placings }

puts YAML.dump(rep)
