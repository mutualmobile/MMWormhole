Pod::Spec.new do |s|
  s.name     = 'MMWormhole'
  s.version  = '1.0.0'
  s.license  = 'MIT'
  s.summary  = 'Message passing between iOS apps and extensions.'
  s.homepage = 'https://github.com/mutualmobile/MMWormhole'
  s.authors  = { 'Conrad Stoll' => 'conrad.stoll@mutualmobile.com' }
  s.source   = { :git => 'https://github.com/mutualmobile/MMWormhole.git', :tag => s.version.to_s }
  s.requires_arc = true
  
  s.default_subspec = 'Core'

  s.ios.deployment_target = '7.0'
  s.ios.frameworks = 'Foundation'
  
  s.subspec 'Core' do |core|
    core.source_files = 'Source/*.{h,m}'
  end  
end
