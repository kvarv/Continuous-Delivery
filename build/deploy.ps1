$framework = '4.0'

include .\..\tools\psake\teamcity.ps1
include .\..\tools\Replace-Tokens\Replace-Tokens.ps1

task default -depends deploy

task deploy -depends set_build_number{
	Write-Output "deploying to $env => database is deployed to $database_server"
    $app_path = "$build_artifacts_dir\Debug\ContinuousDelivery.WpfApplication"
    $config_file = "ContinuousDelivery.WpfApplication.exe.config"
    replace_tokens $app_config_data "$configs_dir\$config_file.template" "$app_path\$config_file"
}

task set_build_number {
    TeamCity-SetBuildNumber $build_number
}