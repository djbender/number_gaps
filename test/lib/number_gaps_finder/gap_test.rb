require "minitest/autorun"
require_relative "../../../lib/number_gaps_finder/gap"

class NumberGapsFinder::GapTest < Minitest::Test
  def test_initializes_with_first_and_last_values
    gap = NumberGapsFinder::Gap.new(f: 5, l: 10)

    assert_equal 5, gap.f
    assert_equal 10, gap.l
  end

  def test_provides_access_to_first_value_through_f_attribute
    gap = NumberGapsFinder::Gap.new(f: 42, l: 99)

    assert_equal 42, gap.f
  end

  def test_provides_access_to_last_value_through_l_attribute
    gap = NumberGapsFinder::Gap.new(f: 42, l: 99)

    assert_equal 99, gap.l
  end

  def test_pair_method_returns_array_of_first_and_last_values
    gap = NumberGapsFinder::Gap.new(f: 3, l: 7)

    assert_equal [3, 7], gap.pair
  end

  def test_pair_method_works_with_same_first_and_last_values
    gap = NumberGapsFinder::Gap.new(f: 5, l: 5)

    assert_equal [5, 5], gap.pair
  end

  def test_inspect_provides_readable_string_representation
    gap = NumberGapsFinder::Gap.new(f: 10, l: 15)

    assert_equal "#<Gap f:10 l:15>", gap.inspect
  end

  def test_inspect_works_with_zero_values
    gap = NumberGapsFinder::Gap.new(f: 0, l: 0)

    assert_equal "#<Gap f:0 l:0>", gap.inspect
  end

  def test_inspect_works_with_negative_values
    gap = NumberGapsFinder::Gap.new(f: -5, l: -1)

    assert_equal "#<Gap f:-5 l:-1>", gap.inspect
  end

  def test_inspect_works_with_large_numbers
    gap = NumberGapsFinder::Gap.new(f: 999999, l: 1000000)

    assert_equal "#<Gap f:999999 l:1000000>", gap.inspect
  end

  def test_handles_single_number_gap
    gap = NumberGapsFinder::Gap.new(f: 42, l: 42)

    assert_equal 42, gap.f
    assert_equal 42, gap.l
    assert_equal [42, 42], gap.pair
    assert_equal "#<Gap f:42 l:42>", gap.inspect
  end

  def test_can_create_multiple_gap_instances_independently
    gap1 = NumberGapsFinder::Gap.new(f: 1, l: 5)
    gap2 = NumberGapsFinder::Gap.new(f: 10, l: 15)

    assert_equal 1, gap1.f
    assert_equal 5, gap1.l
    assert_equal 10, gap2.f
    assert_equal 15, gap2.l

    refute_equal gap1.pair, gap2.pair
  end

  def test_f_and_l_attributes_are_read_only
    gap = NumberGapsFinder::Gap.new(f: 5, l: 10)

    assert_raises(NoMethodError) { gap.f = 99 }
    assert_raises(NoMethodError) { gap.l = 99 }
  end

  def test_works_with_string_representations_of_numbers
    # Note: The Gap class expects integers, but testing edge case behavior
    gap = NumberGapsFinder::Gap.new(f: "5", l: "10")

    assert_equal "5", gap.f
    assert_equal "10", gap.l
    assert_equal ["5", "10"], gap.pair
    assert_equal "#<Gap f:5 l:10>", gap.inspect
  end

  def test_initializing_requires_both_f_and_l_parameters
    assert_raises(ArgumentError) { NumberGapsFinder::Gap.new(f: 5) }
    assert_raises(ArgumentError) { NumberGapsFinder::Gap.new(l: 10) }
    assert_raises(ArgumentError) { NumberGapsFinder::Gap.new }
  end

  def test_works_with_keyword_arguments_in_different_order
    gap1 = NumberGapsFinder::Gap.new(f: 1, l: 5)
    gap2 = NumberGapsFinder::Gap.new(l: 5, f: 1)

    assert_equal gap1.f, gap2.f
    assert_equal gap1.l, gap2.l
    assert_equal gap1.pair, gap2.pair
    assert_equal gap1.inspect, gap2.inspect
  end

  def test_handles_nil_values_gracefully
    gap = NumberGapsFinder::Gap.new(f: nil, l: nil)

    assert_nil gap.f
    assert_nil gap.l
    assert_equal [nil, nil], gap.pair
    assert_equal "#<Gap f: l:>", gap.inspect
  end

  def test_pair_method_returns_new_array_each_time
    gap = NumberGapsFinder::Gap.new(f: 1, l: 2)

    pair1 = gap.pair
    pair2 = gap.pair

    assert_equal pair1, pair2
    refute_same pair1, pair2
  end

  def test_can_be_used_in_collections
    gaps = [
      NumberGapsFinder::Gap.new(f: 1, l: 3),
      NumberGapsFinder::Gap.new(f: 10, l: 12),
      NumberGapsFinder::Gap.new(f: 20, l: 25)
    ]

    assert_equal 3, gaps.length
    assert_equal 1, gaps.first.f
    assert_equal 25, gaps.last.l
  end

  def test_supports_comparison_operations_indirectly_through_attributes
    gap1 = NumberGapsFinder::Gap.new(f: 1, l: 5)
    gap2 = NumberGapsFinder::Gap.new(f: 10, l: 15)

    assert gap1.f < gap2.f
    assert gap1.l < gap2.l
  end
end
