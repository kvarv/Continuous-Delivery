$framework = '4.0'

properties {
	$base_dir = resolve-path .\..
	$source_dir = "$base_dir\src"
	$build_artifacts_dir = "$base_dir\build_artifacts"
	$tools_dir = "$base_dir\tools"
	$config = "Debug"
	$test_dir = "$build_artifacts_dir\$config\tests"
}

task default -depends local
 
task local -depends compile, test

task ci -depends compile, test, create_build_number_file

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
		Write-Output "##teamcity[importData type='nunit' path=`'$test_dir\tests_results.xml`']"
	}
}

task create_build_number_file {
	"$env:build_number"  | out-file "$base_dir\build.version" -encoding "ASCII" -force  
}

task deploy -depends set_build_number{
    Write-Output "deploying to test!"
}

task set_build_number {
	$script:build_no = get-content "$base_dir\build.version"
	TeamCity-SetBuildNumber $script:build_no
}