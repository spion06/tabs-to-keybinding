require 'yaml'
segments = File.read(ARGV[0]).split(/\n\s*\n/)

scale = %w(C C# D Eb E F F# G G# A Bb B)
full_scale = (3.times.map { scale } + %w(C)).flatten
key_mapping = %w(z x c v b n m a s d f g h j k l q w e r t y u i o p 1 2 3 4 5 6 7 8 9 0 -)

def scale_to_offset(key)
  if ARGV[1]
    @scale_mapping ||= YAML.load_file(ARGV[1])
    @scale_mapping[key].to_i
  else
    key.to_i
  end
end

all_segments = []
segments.each do |segment|
        lines = segment.split("\n").map{|l| { scale: scale_to_offset(l.split('|')[0]), tabs: l.match(/\|(.*)\|/)[1] }}
  if lines.map{|l| l[:tabs].length }.uniq.count > 1
    raise "error parsing segment. characters per segment
    #{lines.map{|l| l[:tabs].length }.inspect} #{segment}"
  end
  vert_segments = lines.map{|l| l[:tabs].length }.first
  converted_segment = []
  vert_segments.times.each do |vs_idx|
    note_mapping = []
    lines.each_with_index do |line,l_idx|
      #offset = full_scale.index(line[:scale])
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
