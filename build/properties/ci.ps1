$build_configuration = "Release"
$database_server = "localhost"
$database_name = "ContinuousDelivery_ci"
$deployment_url = "C:\ContinuousDelivery"

$app_config_data = @{
    "database_connection_string" = "Data Source=$database_server;Initial Catalog=$database_name;Integrated security = true";
}