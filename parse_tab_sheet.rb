require 'yaml'
segments = File.read(ARGV[0]).split(/\n\s*\n/)

scale = %w(C C# D Eb E F F# G G# A Bb B)
full_scale = (3.times.map { scale } + %w(C)).flatten
key_mapping = %w(z x c v b n m a s d f g h j k l q w e r t y u i o p 1 2 3 4 5 6 7 8 9 0 -)

def scale_to_offset(key)
  if ARGV[1]
    @scale_mapping ||= YAML.load_file(ARGV[1])
    raise "No mapping found for #{key} in #{ARGV[1]}" unless @scale_mapping.keys.include?(key)
    @scale_mapping[key].to_i
  else
    key.to_i
  end
end

def fix_double_digits(input)
  idxs = input.map.with_index{|n,i| i if n.match(/\d{2,}/)}.compact
  idxs.each_with_index do |idx,offset|
    insert_idx = idx + offset + 1
    input.insert(insert_idx,'-')
  end
  input
end

def valid_tabs?(lines)
  lines.map{|l| l[:tabs].count }.uniq.count == 1
end

all_segments = []
segments.each do |segment|
  lines = segment.split("\n").map{|l| { scale: scale_to_offset(l.split('|')[0]), tabs: l.match(/\|(.*)\|/)[1].scan(/(\d+|[a-z\/-])/).flatten }}
  puts lines.inspect
  unless valid_tabs?(lines)
    lines.each do |line|
      line[:tabs] = fix_double_digits(line[:tabs])
    end
    unless valid_tabs?(lines)
      raise "error parsing segment. characters per segment
        #{lines.map{|l| l[:tabs].count }.inspect} #{segment}"
    end
  end
  vert_segments = lines.map{|l| l[:tabs].length }.first
  converted_segment = []
  vert_segments.times.each do |vs_idx|
    note_mapping = []
    lines.each_with_index do |line,l_idx|
      offset = line[:scale]
      matchdata = line[:tabs][vs_idx].match(/([0-9])/)
      if matchdata
        note_idx = matchdata[1].to_i + offset
        note_mapping << key_mapping.fetch(note_idx)
      end
    end
    segment_value = case note_mapping.count
                    when 0
                      '-'
                    when 1
                      note_mapping.first
                    else
                      '?'
                    end
    converted_segment << segment_value
  end
  all_segments << converted_segment.join('').gsub('-',' ')
end
puts all_segments.join
