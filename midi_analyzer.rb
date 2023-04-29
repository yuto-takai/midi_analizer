require 'midilib/sequence'
require 'midilib/consts'

def note_name(note)
  note_names = %w[C C# D D# E F F# G G# A A# B]
  octave = note / 12 - 1
  name = note_names[note % 12]
  "#{name}#{octave}"
end

def interval_name(interval)
  interval_names = %w[Unison minor\ 2nd Major\ 2nd minor\ 3rd Major\ 3rd Perfect\ 4th Tritone Perfect\ 5th minor\ 6th Major\ 6th minor\ 7th Major\ 7th Octave]
  interval_names[interval % 12]
end

def analyze_midi(file)
  seq = MIDI::Sequence.new
  File.open(file, 'rb') { |file| seq.read(file) }

  notes = []
  seq.each { |track| track.each { |event| notes << event.note if event.is_a?(MIDI::NoteOn) } }
  notes
end

chords_file = './chord.mid'
melody_file = './melody.mid'

chords_notes = analyze_midi(chords_file)
melody_notes = analyze_midi(melody_file)

chords_notes.each_with_index do |chord_note, index|
  melody_note = melody_notes[index]
  puts "Chord: #{note_name(chord_note)}, Melody: #{note_name(melody_note)}, Interval: #{interval_name(melody_note - chord_note)}"
end
