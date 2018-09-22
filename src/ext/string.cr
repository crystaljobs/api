class String
  def lower_camelcase
    s = camelcase.sub(&.downcase)
  end
end
