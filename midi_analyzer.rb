require 'midilib/sequence'
require 'midilib/consts'

# ノート番号からノート名を取得するユーティリティ関数
def note_name(note, include_octave = false)
  note_names = %w[C C# D D# E F F# G G# A A# B]
  octave = note / 12 - 1
  name = note_names[note % 12]
  include_octave ? "#{name}#{octave}" : name
end

# MIDIファイルを解析する関数
def analyze_midi(file)
  seq = MIDI::Sequence.new
  File.open(file, 'rb') { |file| seq.read(file) }

  # ノートオンイベントだけを抽出する
  notes = []
  seq.each { |track| track.each { |event| notes << event if event.is_a?(MIDI::NoteOn) && event.velocity > 0 } }
  notes
end

# MIDIファイルのパスを設定
root_file_path = './bass.mid'
melody_file_path = './melo.mid'

# MIDIファイルを解析する
root_note_events = analyze_midi(root_file_path)
melody_note_events = analyze_midi(melody_file_path)

# 初期化
prev_root_note = nil
prev_group_index = nil

melody_note_events.each do |melody_event|
  melody_note = melody_event.note

  # ルート音を検索する
  root_event = root_note_events.reverse_each.find { |event| event.time_from_start <= melody_event.time_from_start }
  root_note = root_event.note
  group_index = root_note_events.index(root_event)

  # 前回と同じグループかどうかを確認する
  if prev_group_index == group_index
    root_name = ''
  else
    root_name = note_name(root_note, false)
    prev_group_index = group_index
    puts "\n" unless prev_root_note.nil?
  end

  # ルート音に対する主旋律の度数を出力する
  interval = (melody_note - root_note) % 12
  interval_name = %w[Unison minor\ 2nd Major\ 2nd minor\ 3rd Major\ 3rd Perfect\ 4th Tritone Perfect\ 5th minor\ 6th Major\ 6th minor\ 7th Major\ 7th Octave][interval]

  # 出力する
  melody_name = note_name(melody_note, false)
  puts "Root: #{root_name}\tMelody: #{melody_name}\tInterval: #{interval_name}"
  prev_root_note = root_note
end
puts "\n" unless prev_root_note.nil?
