Pod::Spec.new do |s|
  s.name     = 'MMWormhole'
  s.version  = '2.0.0'
  s.license  = 'MIT'
  s.summary  = 'Message passing between apps and extensions.'
  s.homepage = 'https://github.com/mutualmobile/MMWormhole'
  s.authors  = { 'Conrad Stoll' => 'conrad.stoll@mutualmobile.com' }
  s.source   = { :git => 'https://github.com/mutualmobile/MMWormhole.git', :tag => s.version.to_s }
  s.requires_arc = true
  
  s.default_subspec = 'Core'

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
  s.watchos.deployment_target = '2.0'
  
  s.ios.frameworks = 'Foundation', 'WatchConnectivity'
  s.osx.frameworks = 'Foundation'
  s.watchos.frameworks = 'Foundation', 'WatchConnectivity'
  
  s.subspec 'Core' do |core|
    core.ios.source_files = 'Sources/MMWormhole/*.{h,m}'
    core.watchos.source_files = 'Sources/MMWormhole/*.{h,m}'
    core.osx.source_files = 'Sources/MMWormhole/MMWormhole.{h,m}', 'Sources/MMWormhole/MMWormholeFileTransiting.{h,m}', 'Sources/MMWormhole/MMWormholeCoordinatedFileTransiting.{h,m}', 'Sources/MMWormhole/MMWormholeTransiting.h'
  end  
end
