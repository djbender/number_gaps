require 'csv'
require_relative 'number_gaps/gap'

class NumberGaps
  def self.run!(file:, column: 1, headers: false)
    gaps = []
    group_start = nil
    last = nil

    require 'byebug'
    # byebug
    CSV.foreach(file, headers:,) do |row|

      next if row.compact.empty?
      index = column - 1 # usually 0
      current = row[index].delete("^0-9").to_i
      group_start ||= current

      #  1 == 1                        1.succ != 1
      #  1 != 2                        1.succ == 2
      #  1 != 10                       5.succ != 10
      unless group_start == current || last.succ == current
        gaps << Gap.new(f: last.succ, l: current.pred)
      end
      last = current # always
    end

    gaps
  end
end
