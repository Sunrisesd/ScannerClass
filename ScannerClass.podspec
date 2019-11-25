Pod::Spec.new do |s| 
  s.name         = "ScannerClass"				#SDK名称
  s.version      = "1.0.0"                        		#版本号
  s.homepage     = "https://github.com/Sunrisesd"  		#工程主页地址
  s.summary      = "用于扫描二维码和条形码"  			#项目的简单描述
  s.license  	 = "MIT"  					#协议类型
  s.author       = { "Sunrisesd" => "w325731718@163.com" }	#作者及联系方式
  s.platform     = :ios  					#支持的平台
  s.platform     = :ios, "9.0"   				#平台及版本
  s.ios.deployment_target = "9.0"     				#最低系统版本
  s.swift_version = "5.0"	 				#支持swift版本
  s.source       = { :git => "https://github.com/Sunrisesd/ScannerClass.git" ,:tag => "#{s.version}"}   						#工程地址及版本号
  s.requires_arc = true   					#是否必须arc
  s.source_files = ["Source/**/*.swift"]  			#SDK实际的重要文件路径
  s.resource	 = "Source/Resource/*.{bundle,png,xcassets}"	#图片资源


end