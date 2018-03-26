@version = "1.0.0"

Pod::Spec.new do |s|
  s.name                  = "LayoutXML"
  s.version               = @version
  s.summary               = "Android styled XML template engine for iOS written in Swift."
  s.homepage              = "https://github.com/naru-jpn/LayoutXML"
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.author                = { "naru" => "tus.naru@gmail.com" }
  s.source                = { :git => "https://github.com/naru-jpn/LayoutXML.git", :tag => @version }
  s.source_files          = 'Sources/LayoutXML/LayoutXML.swift', 'Sources/LayoutXML/R/*', 'Sources/LayoutXML/Inflater/*', 'Sources/LayoutXML/Layouter/*'
  s.ios.deployment_target = '8.0'
end
