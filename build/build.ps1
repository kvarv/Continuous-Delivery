$framework = '4.0'

properties {
	$base_dir = resolve-path .\..
	$source_dir = "$base_dir\src"
	$build_artifacts_dir = "$base_dir\build_artifacts"
	$tools_dir = "$base_dir\tools"
	$config = "Debug"
	$test_dir = "$build_artifacts_dir\$config\Tests"
}

task default -depends local
 
task local -depends compile, test

task compile -depends clean {
	exec { msbuild  $source_dir\ContinuousDelivery.sln /t:Clean /t:Build /p:Configuration=$config /v:q /nologo }
}

task clean {
	rd $build_artifacts_dir -recurse -force  -ErrorAction SilentlyContinue | out-null
	mkdir $build_artifacts_dir  -ErrorAction SilentlyContinue  | out-null
}

task test {	
	$testassemblies = get-childitem $test_dir -recurse -include *tests*.dll
	exec { 
		& $tools_dir\NUnit-2.5.10\nunit-console-x86.exe $testassemblies /nologo /nodots /xml=$test_dir\tests_results.xml; 
		Write-Output "##teamcity[importData type='nunit' path=`'buildartifacts\Tests\tests_results.xml`']"
	}
}
