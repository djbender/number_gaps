require 'csv'

puts "Welcome to contiguous number gaps finder!"

gaps = []
group_start = nil
last = nil

class Gap
  attr_reader :f, :l

  def initialize(f:, l:)
    @f = f
    @l = l
  end

  def pair
    [f, l]
  end

  def inspect
    "#<Gap f:#{f} l:#{l}>"
  end
end

$stdout.sync = true
print 'Now calculating...'
CSV.foreach('test.csv') do |row|
  print '.'

  next if row.compact.empty?
  current = Integer(row.first)
  group_start ||= current

  #  1 == 1                        1.succ != 1
  #  1 != 2                        1.succ == 2
  #  1 != 10                       5.succ != 10
  unless group_start == current || last.succ == current
    gaps << Gap.new(f: last.succ, l: current.pred)
  end
  last = current # always
end
print "\n\n"
$stdout.sync = false

if gaps.empty?
  puts "No gaps found."
else
  @precision = gaps.last&.l.digits.count

  def fmt(val)
    sprintf("%0#{@precision}d", val)
  end

  puts "Gaps were found:"
  gaps.each do |gap|
    if gap.f == gap.l
      puts "  #{fmt(gap.f)}"
    else
      puts "  #{fmt(gap.f)}-#{fmt(gap.l)}"
    end
  end
end
