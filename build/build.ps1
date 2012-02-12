$framework = '4.0'

properties {
	$base_dir = resolve-path .\..
	$build_dir = "$base_dir\build"
	$configs_dir = "$build_dir\configs"
	$properties_dir = "$build_dir\properties"
	$source_dir = "$base_dir\src"
	$build_artifacts_dir = "$base_dir\build_artifacts"
	$tools_dir = "$base_dir\tools"
	$configuration = "Debug"
	$test_dir = "$build_artifacts_dir\$configuration\tests"
	
	. "$properties_dir\$env.ps1"
}

include .\..\tools\psake\teamcity.ps1

task default -depends local
 
task local -depends compile, test

task ci -depends compile, test

task compile -depends clean {
	exec { msbuild  $source_dir\ContinuousDelivery.sln /t:Clean /t:Build /p:Configuration=$configuration /v:q /nologo }
	Write-Output "Integrating database changes for $env at $database_server"
}

task clean {
	rd $build_artifacts_dir -recurse -force  -ErrorAction SilentlyContinue | out-null
	mkdir $build_artifacts_dir  -ErrorAction SilentlyContinue  | out-null
}

task test {	
	$testassemblies = get-childitem $test_dir -recurse -include *tests*.dll
	exec { 
		& $tools_dir\NUnit-2.5.10\nunit-console-x86.exe $testassemblies /nologo /nodots /xml=$test_dir\tests_results.xml; 
		Write-Output "##teamcity[importData type='nunit' path=`'$test_dir\tests_results.xml`']"
	}
}

task deploy {
	invoke-psake .\deploy.ps1 -properties $properties -parameters $parameters
}