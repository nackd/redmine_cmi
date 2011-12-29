module ViewHelper
  def hours(n)
    t :label_f_hour_plural, :value => (n.round(2) rescue n)
  end
end
