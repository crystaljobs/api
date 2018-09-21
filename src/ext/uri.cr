class URI
  def http?
    scheme == "http" || scheme == "https"
  end
end
