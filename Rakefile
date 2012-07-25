# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'swifftest'
  
  app.libs << "/usr/lib/libz.dylib"
  app.libs << "/usr/lib/libxml2.dylib"
  
  app.frameworks += ['AVFoundation']
    
  app.vendor_project( "vendor/SwiffCore", :xcode,
    :xcodeproj => "SwiffCore.xcodeproj", :target => "SwiffCore", :products => ["libSwiffCore.a"],
    :headers_dir => "Source")
    
  
  app.interface_orientations = [:landscape_left, :landscape_right]
  
end
