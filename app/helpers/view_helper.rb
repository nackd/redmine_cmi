# -*- coding: utf-8 -*-
module ViewHelper
  def currency(n)
    # TODO other currencies
    "#{n.round(2) rescue n} €"
  end

  def hours(n)
    t :label_f_hour_plural, :value => (n.round(2) rescue n)
  end

  def percent(n)
    "#{n.round(2) rescue n} %"
  end
end
