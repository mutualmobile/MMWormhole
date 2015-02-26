Pod::Spec.new do |s|
  s.name     = 'MMWormhole'
  s.version  = '1.1.1'
  s.license  = 'MIT'
  s.summary  = 'Message passing between apps and extensions.'
  s.homepage = 'https://github.com/mutualmobile/MMWormhole'
  s.authors  = { 'Conrad Stoll' => 'conrad.stoll@mutualmobile.com' }
  s.source   = { :git => 'https://github.com/mutualmobile/MMWormhole.git', :tag => s.version.to_s }
  s.requires_arc = true
  
  s.default_subspec = 'Core'

  s.ios.platform = :ios, '7.0'
  s.osx.platform = :osx, '10.10'
  
  s.frameworks = 'Foundation'
  
  s.subspec 'Core' do |core|
    core.source_files = 'Source/*.{h,m}'
  end  
end
