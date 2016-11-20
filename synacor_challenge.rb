require 'pry'

class Processor
  attr_accessor :memory, :registers, :stack, :head_position

  def initialize(instructions)
    # can hold up to 32768 values
    @memory = Hash.new(0)
    @memory = instructions

    @registers = Array.new(8, 0)
    @registers[1] = 100

    @stack = []

    @head_position = 0
  end

  def run!
    loop do
      execute!
      advance!
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
  end

  # out
  def operation_19
    advance!
    p get_value(head_position).chr
  end

  # noop
  def operation_21
  end

  private

  def advance!
    self.head_position += 1
  end

  def execute!
    send "operation_#{get_value(head_position)}"
  end

  def get_value(address)
    raise 'Really Invalid Address' unless (0..65535).cover? address
    value = memory[address]
    raise 'Really Invalid Value' unless (0..65535).cover? value
    return value if (0..32767).cover? value
    return registers[value % 32768] if (32768..32775).cover? value
    raise 'Invalid Value'
  end

  def get_address(address)
    raise 'Really Invalid Address' unless (0..65535).cover? address
    memory[address]
  end

  def set_value(address, value)
    raise 'Really Invalid Address' unless (0..65535).cover? address
    raise 'Really Invalid Value' unless (0..65535).cover? value
    raise 'Invalid Address' unless (0..32775).cover? address
    raise 'Invalid Value' unless (0..32775).cover? value
    
    if (0..32767).cover? address
      memory[address] = value
    elsif (32768..32775).cover? address
      registers[address % 32768] = value
    end
  end
end

Processor.new([9,32768,32769,4,19,32768,0]).run!
