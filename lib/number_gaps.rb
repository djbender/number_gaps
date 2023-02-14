require 'csv'
require_relative 'number_gaps/gap'

class NumberGaps
  def self.run!(file:)
    gaps = []
    group_start = nil
    last = nil

    CSV.foreach(file) do |row|
      next if row.compact.empty?
      current = row.first.delete("^0-9").to_i
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
