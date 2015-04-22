class Decompressor

  def initialize(in_file,out_file)
    @in_file  = in_file
    @out_file = out_file
    @alphabet, @binary_string = get_encoded_data
  end

  def unescape_escapes(s)
    s.gsub!("\\\\", "\\") #Backslash
    s.gsub!('\\"', '"')  #Double quotes
    s.gsub!("\\'", "\'")  #Single quotes
    s.gsub!("\\r", "\r")  #Carriage Return
    s.gsub!("\\n", "\n")  #New Line
    s.chomp('"').reverse.chomp('"')
  end

  def get_encoded_data
    alphabet = []
    alphabet_raw = open(@in_file).each_line.take(1).last
    binary_data  = open(@in_file).each_line.take(2).last.unpack("H*")

    alphabet_raw.gsub!('","',"tyler")
    alphabet_raw.split(",").each_slice(2) do |char, encode|
      char = "," if char == "tyler"
      if !char.nil? && !encode.nil?
        alphabet << [unescape_escapes(char), encode]
      end
    end
    return [alphabet, *binary_data]
  end

  def finished_decoding?
    @binary_string.empty?
  end

  def get_alphabet_match(binary_string)
    @alphabet.each do |char, encode|
      return char if binary_string == encode
    end
    false
  end

  def decompress_txt_file
      test_string = ""
      raise "ERROR... alphabet incomplete" if test_string.length == 1000
      file = File.new(@out_file,"w")
      @binary_string.each_char do |bit|
        test_string += bit
        match = get_alphabet_match(test_string)
        if match
          file.write "#{match}"
          test_string = ""
        end
      end
      file.close
  end
end
