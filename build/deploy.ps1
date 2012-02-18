$framework = '4.0'

properties {
    $clickonce_dir = "$build_artifacts_dir\ClickOnce"
    $app_path = "$build_artifacts_dir\ContinuousDelivery.WpfApplication"
    $mage_dir = "C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\Bin\NETFX 4.0 Tools"
    $app_executeable = "ContinuousDelivery.WpfApplication.exe"
    $manifest_file = "$app_executeable.manifest"
    $application_name = "Continuous Delivery"
    $application_file = "ContinuousDelivery.application"
    $deployment_url = "$deployment_url\$env"
}

include .\..\tools\psake\teamcity.ps1
include .\..\tools\Replace-Tokens\Replace-Tokens.ps1

task default -depends deploy 

task deploy -depends set_build_number, 
                    validate_build_number, 
                    migrate_database, 
                    change_config_settings,
                    deploy_clickonce_package 

task set_build_number {
    TeamCity-SetBuildNumber $build_number
}

task migrate_database {
    exec { & $tools_dir\RoundhousE\rh.exe /s=$database_server /d=$database_name /f=$database_dir /trx /vf=$database_version_dll /silent} 
}

task validate_build_number -precondition { return $should_not_redeploy -eq 'True'} {
    $webclient = New-Object System.Net.WebClient
    $uri = New-Object System.Uri("http://localhost/guestAuth/app/rest/buildTypes/id:$env:build_configuration_id/builds/status:SUCCESS/number")
    $last_successful_build_number = $webclient.DownloadString($uri)
    if($build_number -eq $last_successful_build_number) {
        Write-Output "##teamcity[buildStatus status='SUCCESS' text='Already deployed.']"
        exit
    }
}

task change_config_settings {
    $config_file = "ContinuousDelivery.WpfApplication.exe.config"
    replace_tokens $app_config_data "$configs_dir\$config_file.template" "$app_path\$config_file"   
}

task create_clickonce_package {
    delete_directory "$clickonce_dir"
    copy_files $app_path "$clickonce_dir" @('*.pdb', '*.xml', '*.application', '*.manifest')
    exec { & $mage_dir\mage.exe -New Application -Processor x86 -ToFile "$clickonce_dir\$app_executeable.manifest" -name "$application_name $env" -Version $build_number -FromDirectory $clickonce_dir }
    exec { msbuild  $build_dir\clickonce.proj /p:"Version=$build_number;DeploymentUrl=$deployment_url;ApplicationName=$application_name;Env=$env;ClickOnceDir=$clickonce_dir;ManifestFile=$manifest_file;ApplicationFile=$application_file" /v:n /nologo }
    exec { & $mage_dir\mage.exe -Update $clickonce_dir\$application_file -Publisher "Gøran Kvarv" }
    get-childItem $clickonce_dir -include *.* -exclude *.manifest,*.application  -Recurse  | rename-item -newname { $_.name+'.deploy' }
}

task deploy_clickonce_package -depends create_clickonce_package {
    delete_directory "$deployment_url"
    copy_files "$clickonce_dir" "$deployment_url"
}