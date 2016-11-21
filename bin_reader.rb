require 'pry'

class BinReader
  class << self
    def array_of_ints
      contents = File.read('challenge.bin')
      output = []
      contents.chars.each_slice(2) do |pair|
        output << pair.map { |byte| byte.unpack('b8')[0].reverse }.reverse.join.to_i(2)
      end
      output
    end
  end
end
