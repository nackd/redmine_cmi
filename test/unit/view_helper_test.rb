# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../test_helper'

class ViewHelperTest < ActionView::TestCase
  test "currency" do
    assert_nothing_raised do
      currency '--'
    end

    assert_equal '-- €', currency('--')
    assert_equal '0.01 €', currency(0.012)
    assert_equal '0.0 €', currency(0.001)
  end

  test "hours" do
    assert_nothing_raised do
      hours '--'
    end

    assert_equal '-- hours', hours('--')
    assert_equal '0.01 hours', hours(0.012)
    assert_equal '0.0 hours', hours(0.001)
  end

  test "percent" do
    assert_nothing_raised do
      percent '--'
    end

    assert_equal '-- %', percent('--')
    assert_equal '0.01 hours', hours(0.012)
    assert_equal '0.0 hours', hours(0.001)
  end
end
