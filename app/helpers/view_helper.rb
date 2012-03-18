# -*- coding: utf-8 -*-
module ViewHelper
  def currency(n)
    number_to_currency n, :locale => Setting.default_language
  end

  def hours(n)
    t :label_f_hour_plural, :value => (n.round(2) rescue n)
  end

  def percent(n)
    "#{n.round(2) rescue n} %"
  end
end
