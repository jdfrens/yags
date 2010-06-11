Dir[Rails.root.join('vendor', 'plugins', '*', 'rake', '*.rake')].each do |plugin|
  load plugin
end
