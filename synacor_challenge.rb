require 'pry'
require_relative 'bin_reader'

class Processor
  attr_accessor :memory, :registers, :stack, :head_position

  def initialize(instructions)
    # can hold up to 32768 values
    @memory = Hash.new(0)
    @memory = instructions

    @registers = Array.new(8, 0)

    @stack = []

    @head_position = 0
  end

  def run!
    loop do
      execute!
    end
  end

  # halt
  def operation_0
    exit
  end

  # eq
  def operation_4
    advance!
    storage_location = get_value(head_position)
    advance!
    item_1 = get_value(head_position)
    advance!
    item_2 = get_value(head_position)

    memory[storage_location] = item_1 == item_2
    advance!
  end

  # jump
  def operation_6
    advance!
    self.head_position = get_value(self.head_position)
  end

  # jump_true
  def operation_7
    advance!
    switch = get_value(head_position)
    advance!
    target = get_value(head_position)
    if (switch % 32768) != 0
      self.head_position = target
    else
      advance!
    end
  end

  # jump_false
  def operation_8
    advance!
    switch = get_value(head_position)
    advance!
    target = get_value(head_position)
    if (switch % 32768) == 0
      self.head_position = target
    else
      advance!
    end
  end

  # add
  def operation_9
    advance!
    storage_location = get_address(head_position)
    advance!
    item_1 = get_value(head_position)
    advance!
    item_2 = get_value(head_position)

    sum = (item_1 + item_2) % 32768

    set_value(storage_location, sum)
    advance!
  end

  # out
  def operation_19
    advance!
    print get_value(head_position).chr
    advance!
  end

  # noop
  def operation_21
    advance!
  end

  private

  def advance!
    self.head_position += 1
  end

  def execute!
    send "operation_#{get_value(head_position)}"
  end

  def get_value(address)
    raise "Really Invalid Address: #{address.inspect}" unless (0..65535).cover? address
    value = memory[address]
    raise "Really Invalid Value: #{value.inspect}" unless (0..65535).cover? value
    return value if (0..32767).cover? value
    return registers[value % 32768] if (32768..32775).cover? value
    raise "Invalid Value: #{value.inspect}"
  end

  def get_address(address)
    raise "Really Invalid Address: #{address.inspect}" unless (0..65535).cover? address
    memory[address]
  end

  def set_value(address, value)
    raise "Really Invalid Address: #{address.inspect}" unless (0..65535).cover? address
    raise "Really Invalid Value: #{value.inspect}" unless (0..65535).cover? value
    raise "Invalid Address: #{address.inspect}" unless (0..32775).cover? address
    raise "Invalid Value: #{value.inspect}" unless (0..32775).cover? value
    
    if (0..32767).cover? address
      memory[address] = value
    elsif (32768..32775).cover? address
      registers[address % 32768] = value
    end
  end
end

Processor.new(BinReader.array_of_ints).run!
