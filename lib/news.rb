class News
  def call(env)
    [200, {"Content-Type" => "text/html"}, "Hello News!"]
  end
end
