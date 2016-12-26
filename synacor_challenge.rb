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
    register_number = memory[head_position] % 32768
    advance!
    value = get_value(head_position)
    registers[register_number] = value
    advance!
  end

  # push
  def operation_2
    advance!
    value = get_value(head_position)
    stack.push(value)
    advance!
  end

  #pop
  def operation_3
    raise "Can't pop from an empty stack: #{head_position}" if stack.empty?
    advance!
    address = get_address(head_position)
    set_value(address, stack.pop)
    advance!
  end

  # eq
  def operation_4
    advance!
    address = get_address(head_position)
    advance!
    item_1 = get_value(head_position)
    advance!
    item_2 = get_value(head_position)

    value = item_1 == item_2 ? 1 : 0
    set_value(address, value)

    advance!
  end

  # greater_than
  def operation_5
    advance!
    address = get_address(head_position)
    advance!
    item_1 = get_value(head_position)
    advance!
    item_2 = get_value(head_position)

    value = item_1 > item_2 ? 1 : 0
    set_value(address, value)
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

  # jump_if_false
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
    address = get_address(head_position)
    advance!
    item_1 = get_value(head_position)
    advance!
    item_2 = get_value(head_position)

    sum = (item_1 + item_2) % 32768

    set_value(address, sum)
    advance!
  end

  # multiply
  def operation_10
    advance!
    address = get_address(head_position)
    advance!
    item_1 = get_value(head_position)
    advance!
    item_2 = get_value(head_position)

    product = (item_1 * item_2) % 32768

    set_value(address, product)
    advance!
  end

  # modulus
    # store into <a> the remainder of <b> divided by <c>
  def operation_11
    advance!
    address = get_address(head_position)
    advance!
    item_1 = get_value(head_position)
    advance!
    item_2 = get_value(head_position)

    remainder = item_1 % item_2

    set_value(address, remainder)
    advance!
  end

  # and
  def operation_12
    advance!
    address = get_address(head_position)
    advance!
    item_1 = get_value(head_position)
    advance!
    item_2 = get_value(head_position)

    value = item_1 & item_2
    set_value(address, value)
    advance!
  end

  # or
  def operation_13
    advance!
    address = get_address(head_position)
    advance!
    item_1 = get_value(head_position)
    advance!
    item_2 = get_value(head_position)

    value = item_1 | item_2
    set_value(address, value)
    advance!
  end

  # not
  def operation_14
    advance!
    address = get_address(head_position)
    advance!
    item = get_value(head_position)

    value = ~item % 32768
    set_value(address, value)
    advance!
  end

  # copy_from_address (rmem)
  def operation_15
    advance!
    target_address = get_address(head_position)
    advance!
    source_address = get_address(head_position)
    if source_address < 32768
      value = get_value(source_address)
    else
      value = get_value(get_value(source_address))
    end

    set_value(target_address, value)
    advance!
  end

  # call
  def operation_17
    advance!
    value = get_value(self.head_position)
    advance!
    stack.push(self.head_position)
    self.head_position = value
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
    # puts head_position
    send "operation_#{get_value(head_position)}"
  end

  def get_value(address)
    raise "Get Value: Really Invalid Address: #{address.inspect}" unless (0..32775).cover? address

    value = address < 32768 ? memory[address] : registers[address % 32768]
    raise "Get Value: Really Invalid Value: #{value.inspect}" unless (0..32775).cover? value

    value < 32768 ? value : registers[value % 32768]
  end

  def get_address(address)
    raise "Really Invalid Address: #{address.inspect}" unless (0..32775).cover? address
    memory[address]
  end

  def set_value(address, value)
    raise "Invalid Address: #{address.inspect}" unless (0..32775).cover? address
    raise "Invalid Value: #{value.inspect}" unless (0..32775).cover? value
    
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
