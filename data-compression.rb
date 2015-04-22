require_relative './TextCompressor.rb'
require_relative './Decompressor.rb'
require 'benchmark'
require 'pry'

def usage(message)
  puts "ERROR: #{message} check usage:"
  puts "USAGE: must supply flag and path to file"
  puts "flags: -c <./path/2/file>  ||  compress text file (output file will have '.compressed' file extention)"
  puts "flags: -u <./path/2/file>  ||  decompress text file (removes '.compressed' file extention)"
  exit 1
end

def check_args(flag,in_file)
  usage("passed incorrect information") if flag.nil? || in_file.nil?
  usage("flag: #{flag} unsupported...") unless ["-c","-u"].include?(flag)
  usage("input file not found!")        unless File.file?(in_file)
end

# Begin:
flag     = ARGV[0]
in_file  = ARGV[1]
check_args(flag,in_file)

def bench(&code)
  t1 = Time.now
    yield
  t2 = Time.now
  t2 - t1
end

def get_file_size(file)
  tmp = './tmp.txt'
  File.open(tmp, "w+") do |tmp_file|
    File.read(file).each_char do |char|
      binary_char = char.unpack('B8')[0]
      tmp_file.write binary_char
    end
  end
  size = File.size(tmp).to_f / 8000
  File.delete(tmp)
  size.round(5)
end

def get_decompressed_file_name(in_file)
  out_file = in_file.gsub(/.compressed$/,"")
  if out_file.include?("/")
    insert_index = 0 - (out_file.reverse.index("/") + 1)
    out_file.insert(insert_index, "_") #adds underscore before file name
  else
    out_file = "_"+ out_file
  end
end


###############
##  BEGIN #####
###############

if flag == "-c"
  out_file = in_file + ".compressed"
  compressor = TextCompressor.new(in_file, out_file)
  proc_seconds = bench { compressor.compress_txt_file }
else
  out_file = get_decompressed_file_name(in_file)
  decompressor = Decompressor.new(in_file, out_file)
  proc_seconds = bench { decompressor.decompress_txt_file }
end

################
# CALCULATIONS #
################

old_size = get_file_size(in_file)
new_size = get_file_size(out_file)

percent_change = ((new_size.to_f / old_size) * 100).round(2)
ratio = 1 - (new_size / old_size.to_f).round(3)

adjective = "smaller" if percent_change < 100
adjective = "bigger" if percent_change > 100

puts "#{out_file} created"
puts "________________________________________________________"
puts "Original file name    : #{in_file}"
puts "Compressed file name  : #{out_file}"
puts "Original file size    : #{old_size}KB"
puts "New file size         : #{new_size}KB"
puts "size ratio            : #{ratio} x"
puts "Processing took #{proc_seconds} seconds"
puts "New file is #{percent_change}% #{adjective} than the original size"
puts "________________________________________________________"
