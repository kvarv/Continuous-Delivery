$framework = '4.0'

properties {
	$base_dir = resolve-path .\..
	$source_dir = "$base_dir\src"
	$config = "Debug"
}

task default -depends local
 
task local -depends compile

task compile {
	exec { msbuild  $source_dir\ContinuousDelivery.sln /t:Clean /t:Build /p:Configuration=$config /v:n /nologo }
}