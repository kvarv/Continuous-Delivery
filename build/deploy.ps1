$framework = '4.0'

include .\..\tools\psake\teamcity.ps1

task default -depends deploy

task deploy -depends set_build_number{
	Write-Output "deploying to $env => database is deployed to $database_server"
}

task set_build_number {
    TeamCity-SetBuildNumber $build_number
}