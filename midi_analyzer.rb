require 'midilib/sequence'
require 'midilib/consts'

def note_name(note, include_octave = false)
  note_names = %w[C C# D D# E F F# G G# A A# B]
  octave = note / 12 - 1
  name = note_names[note % 12]
  include_octave ? "#{name}#{octave}" : name
end

def analyze_midi(file)
  seq = MIDI::Sequence.new
  File.open(file, 'rb') { |file| seq.read(file) }

  notes = []
  seq.each { |track| track.each { |event| notes << event if event.is_a?(MIDI::NoteOn) && event.velocity > 0 } }
  notes
end

def split_melody_events(root_note_events, melody_note_events)
  split_events = []
  melody_note_events.each_with_index do |melody_event, i|
    next_melody_event = melody_note_events[i + 1]
    next_root_event = root_note_events.find { |event| event.time_from_start > melody_event.time_from_start }

    if next_root_event && next_melody_event && next_root_event.time_from_start < next_melody_event.time_from_start
      split_events << melody_event.dup
      melody_event.time_from_start = next_root_event.time_from_start
    end

    split_events << melody_event
  end

  split_events
end

root_file_path = './bass.mid'
melody_file_path = './melo.mid'

root_note_events = analyze_midi(root_file_path)
melody_note_events = analyze_midi(melody_file_path)

split_melody_note_events = split_melody_events(root_note_events, melody_note_events)

prev_root_note = nil
prev_group_index = nil
prev_melody_note = nil

split_melody_note_events.each do |melody_event|
  melody_note = melody_event.note

  root_event = root_note_events.reverse_each.find { |event| event.time_from_start <= melody_event.time_from_start }
  root_note = root_event.note
  group_index = root_note_events.index(root_event)

  if prev_group_index == group_index
    root_name = ''
  else
    root_name = note_name(root_note, false)
    prev_group_index = group_index
    puts "\n" unless prev_root_note.nil?
  end

  interval = (melody_note - root_note) % 12
  interval_name = %w[Unison minor\ 2nd Major\ 2nd minor\ 3rd Major\ 3rd Perfect\ 4th Tritone Perfect\ 5th minor\ 6th Major\ 6th minor\ 7th Major\ 7th Octave][interval]

  if prev_melody_note
    melody_interval = (melody_note - prev_melody_note) % 12
    melody_interval_name = %w[Unison minor\ 2nd Major\ 2nd minor\ 3rd Major\ 3rd Perfect\ 4th Tritone Perfect\ 5th minor\ 6th Major\ 6th minor\ 7th Major\ 7th Octave][melody_interval]
  else
    melody_interval_name = ''
  end

  melody_name = note_name(melody_note, false)
  puts "Root: #{root_name}\tMelody: #{melody_name}\tInterval: #{interval_name}\tMelody Interval: #{melody_interval_name}"
  prev_melody_note = melody_note
end

