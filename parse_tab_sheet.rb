require 'yaml'

scale = %w(C C# D Eb E F F# G G# A Bb B)
full_scale = (3.times.map { scale } + %w(C)).flatten
key_mapping = %w(z x c v b n m a s d f g h j k l q w e r t y u i o p 1 2 3 4 5 6 7 8 9 0 -)



def scale_to_offset(key)
  if ARGV[1]
    raise "No mapping found for #{key} in #{ARGV[1]}" unless config_file.keys.include?(key)
    config_file[key].to_i
  else
    key.to_i
  end
end

def config_file
  @config_file ||= YAML.load_file(ARGV[1].to_s)
rescue Errno::ENOENT
  @config_file={}
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

def note_length_mapping(note)
  unless config_file['timings']
    mapping = {
      W: 7,
      H: 3,
      Q: 1,
      E: 0
    }
    mapping[note.to_sym].to_i
  else
    config_file['timings'][note].to_i
  end
end

segments = File.read(ARGV[0]).split(/\n\s*\n/)
all_segments = []
segments.each do |segment|
  begin
  lines = segment.split("\n").map{|l| { scale: scale_to_offset(l.split('|')[0].strip), tabs: l.match(/\|(.*)\|\s*$/)[1].scan(/(\d+|[a-zA-Z\/-]| )/).flatten }}
  rescue Exception => e
    puts segment.inspect
    raise e
  end
  unless valid_tabs?(lines)
    lines.each do |line|
      line[:tabs] = fix_double_digits(line[:tabs])
    end
    unless valid_tabs?(lines)
      raise "error parsing segment. characters per segment
        #{lines.map{|l| l[:tabs].count }.inspect} #{lines.map{|l| l[:tabs].join}} #{segment}"
    end
  end
  vert_segments = lines.map{|l| l[:tabs].length }.first
  converted_segment = []
  if config_file['note_length_line']
    note_length_line ||= lines.delete_at(0)
  else
    note_length_line = nil
  end
  vert_segments.times.each do |vs_idx|
    note_mapping = []
    lines.each_with_index do |line,l_idx|
      offset = line[:scale]
      matchdata = line[:tabs][vs_idx].match(/([0-9]+)/)
      note_length_symbol = note_length_line.nil? ? 'Z' : note_length_line[:tabs][vs_idx]
      if matchdata
        note_idx = matchdata[1].to_i + offset
        note_mapping << key_mapping.fetch(note_idx) + note_length_mapping(note_length_symbol).times.map{' '}.to_a.join
      end
    end
    segment_value = case note_mapping.count
                    when 0
                      config_file['note_length_line'] ? '' : '-'
                    when 1
                      note_mapping.first
                    else
                      note_mapping.first
                    end
    converted_segment << segment_value
  end
  all_segments << converted_segment.join('').gsub('-',' ')
end
puts all_segments.join
