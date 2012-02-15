$framework = '4.0'

properties {
	$base_dir = resolve-path .\..
	$build_dir = "$base_dir\build"
	$configs_dir = "$build_dir\configs"
	$properties_dir = "$build_dir\properties"
	$source_dir = "$base_dir\src"
	$build_artifacts_dir = "$base_dir\build_artifacts"
	$tools_dir = "$base_dir\tools"
	$test_dir = "$build_artifacts_dir\tests"
	$database_dir = "$base_dir\database"
	. "$properties_dir\$env.ps1"
}

include .\..\tools\psake\teamcity.ps1
include .\modules\functions.ps1

task default -depends local
 
task local -depends recreate_database, compile, test

task ci -depends recreate_database, create_common_assembly_info, compile, test

task compile -depends clean {
	exec { msbuild  $source_dir\ContinuousDelivery.sln /t:Clean /t:Build /p:Configuration=$build_configuration /v:q /nologo }
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

task update_database {
	exec { & $tools_dir\RoundhousE\rh.exe /s=$database_server /d=$database_name /f=$database_dir /silent} 
}

task recreate_database -depends drop_database, update_database

task drop_database {
	exec { & $tools_dir\RoundhousE\rh.exe /s=$database_server /d=$database_name /drop /silent} 
}

task deploy {
	invoke-psake .\deploy.ps1 -properties $properties -parameters $parameters
}

task create_common_assembly_info {
	create_common_assembly_info $build_number "$source_dir\ContinuousDelivery.WpfApplication\CommonAssemblyInfo.cs"
}