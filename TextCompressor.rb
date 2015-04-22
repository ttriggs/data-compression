class TextCompressor
  def initialize(in_file, out_file)
    @in_file  = in_file
    @out_file = out_file
    @characters     = read_characters_stream
    @character_data = init_character_data
    @tree_data      = init_tree_data
    sort_tree_data_by_count
    init_orig_tree_order
  end

  def read_characters_stream
    File.read(@in_file).chars
  end

  def init_character_data
    hash = {}
    @characters.group_by {|x| x}.map do |character, occurances|
      hash[character] = {count: occurances.count, encoding: "", orig_index: ""}
    end
    hash
  end

  def init_tree_data
    @character_data.map {|char,hash| [[char],hash[:count]]}
  end

  def sort_tree_data_by_count
    @tree_data.sort_by! {|node, count| count }.map {|x| x}
  end

  def init_orig_tree_order
    @tree_data.each_with_index do |char, index|
      key = char[0].first
      @character_data[key][:orig_index] = index
    end
  end

  def array_average(array)
    array.inject{ |sum, element| sum + element }.to_f / array.size
  end

  def get_left_right_branches
    branch_one, branch_two = @tree_data.shift, @tree_data.shift
    # puts "b1: #{branch_one} b2: #{branch_two}"
    indecies_b1 = []
    indecies_b2 = []
    indecies_b1 = branch_one[0].map do |char|
      @character_data[char][:orig_index] unless @character_data[char].nil?
    end
    indecies_b2 = branch_two[0].map do |char|
      @character_data[char][:orig_index] unless @character_data[char].nil?
    end
    average_b1 = array_average(indecies_b1)
    average_b2 = array_average(indecies_b2)
    if average_b1 < average_b2
      @left_branch = branch_one
      @right_branch = branch_two
    else
      @left_branch = branch_two
      @right_branch = branch_one
    end
  end

  def create_new_node
    @left_chars,  left_count  = @left_branch
    @right_chars, right_count = @right_branch
    combine_chars = []
    [*@left_chars, *@right_chars].each { |char| combine_chars << char }
    new_node = [combine_chars, left_count + right_count]
    @tree_data << new_node
    # puts "new node: #{new_node}"
  end

  def append_encoding
    # puts "Left: #{@left_chars} Right: #{@right_chars}"
    [[0, @left_chars], [1, @right_chars]].each do |bit, character_keys|
      character_keys.each do |key|
        @character_data[key][:encoding].insert(0, bit.to_s)
      end
    end
  end


  def write_alphabet_to_file
    alphabet = @character_data.map {|char, hash| [char, hash[:encoding]] }
    File.open(@out_file, "w+") do |file|
      alphabet.each do |char, encoding|
        file.write "#{char.inspect},#{encoding},"
      end
      file.puts "\n"
    end
  end

  def write_binary_to_file
    @characters.each do |character|
      File.open(@out_file,"a") do |file|
        # binary = [@character_data[character][:encoding]].pack("H*")
        binary = [@character_data[character][:encoding]].pack("H*")
        # binding.pry
        # file.write binary
        
      end
    end
  end

  def finished_tree?
    @tree_data.length == 1
  end

  def generate_encoding
    until finished_tree?
      sort_tree_data_by_count
      get_left_right_branches
      create_new_node
      append_encoding
    end
  end

  def compress_txt_file
    generate_encoding
    write_alphabet_to_file
    write_binary_to_file
  end
end
