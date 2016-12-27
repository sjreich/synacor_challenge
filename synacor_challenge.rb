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
    puts "Exiting at #{self.head_position}"
    exit
  end

  # set_register
  def operation_1
    advance!
    register_number = get_address % 32768
    advance!
    value = get_value
    registers[register_number] = value
    advance!
  end

  # push
  def operation_2
    advance!
    value = get_value
    stack.push(value)
    advance!
  end

  #pop
  def operation_3
    raise 'Can\'t pop from an empty stack' if stack.empty?
    advance!
    address = get_address
    set_value(address, stack.pop)
    advance!
  end

  # eq
  def operation_4
    advance!
    address = get_address
    advance!
    item_1 = get_value
    advance!
    item_2 = get_value

    value = item_1 == item_2 ? 1 : 0
    set_value(address, value)
    advance!
  end

  # greater_than
  def operation_5
    advance!
    address = get_address
    advance!
    item_1 = get_value
    advance!
    item_2 = get_value

    value = item_1 > item_2 ? 1 : 0
    set_value(address, value)
    advance!
  end

  # jump
  def operation_6
    advance!
    self.head_position = get_value
  end

  # jump_true
  def operation_7
    advance!
    switch = get_value
    advance!
    target_address = get_address
    if (switch % 32768) != 0
      self.head_position = target_address
    else
      advance!
    end
  end

  # jump_if_false
  def operation_8
    advance!
    switch = get_value
    advance!
    target_address = get_address
    if (switch % 32768) == 0
      self.head_position = target_address
    else
      advance!
    end
  end

  # add
  def operation_9
    advance!
    address = get_address
    advance!
    item_1 = get_value
    advance!
    item_2 = get_value

    sum = (item_1 + item_2) % 32768

    set_value(address, sum)
    advance!
  end

  # multiply
  def operation_10
    advance!
    address = get_address
    advance!
    item_1 = get_value
    advance!
    item_2 = get_value

    product = (item_1 * item_2) % 32768

    set_value(address, product)
    advance!
  end

  # modulus
  def operation_11
    advance!
    address = get_address
    advance!
    item_1 = get_value
    advance!
    item_2 = get_value

    remainder = item_1 % item_2

    set_value(address, remainder)
    advance!
  end

  # and
  def operation_12
    advance!
    address = get_address
    advance!
    item_1 = get_value
    advance!
    item_2 = get_value

    value = item_1 & item_2
    set_value(address, value)
    advance!
  end

  # or
  def operation_13
    advance!
    address = get_address
    advance!
    item_1 = get_value
    advance!
    item_2 = get_value

    value = item_1 | item_2
    set_value(address, value)
    advance!
  end

  # not
  def operation_14
    advance!
    address = get_address
    advance!
    item = get_value

    value = ~item % 32768
    set_value(address, value)
    advance!
  end

  # copy_from_address (rmem)
  def operation_15
    advance!
    target_address = get_address
    advance!
    source_address = get_value

    value = get_value(source_address)
    set_value(target_address, value)
    advance!
  end

  # copy_from_value (wmem)
  def operation_16
    advance!
    target_address = get_value
    advance!
    value = get_value

    set_value(target_address, value)
    advance!
  end

  # call
  def operation_17
    advance!
    address = get_value
    advance!
    stack.push(self.head_position)
    self.head_position = address
  end

  # print out
  def operation_19
    advance!
    print get_value.chr
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
    puts head_position
    send "operation_#{get_value}"
  end

  def get_value(address = head_position)
    raise "[GET] Invalid Address: #{address}" unless (0..32775).cover? address
    value = address < 32768 ? memory[address] : registers[address % 32768]
    until value < 32768
      value = get_value(value)
    end
    value
  end

  def get_address(address = head_position)
    raise "[GET] Invalid Address: #{address}" unless (0..32775).cover? address
    memory[address]
  end

  def set_value(address, value)
    raise "[SET] Invalid Address: #{address}" unless (0..32775).cover? address
    raise "[SET] Invalid Value: #{value}" unless (0..32775).cover? value
    if address < 32768
      memory[address] = value
    else
      registers[address % 32768] = value
    end
  end

  def raise(*args)
    puts "Raising error at #{head_position}"
    puts args
    super(args)
  end
end

Processor.new(BinReader.array_of_ints).run!
