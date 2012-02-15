function global:delete_directory($directory_name)
{
  rd $directory_name -recurse -force  -ErrorAction SilentlyContinue | out-null
}

function global:delete_file($file)
{
    if($file) {
        remove-item $file  -force  -ErrorAction SilentlyContinue | out-null} 
}

function global:create_directory($directory_name)
{
  mkdir $directory_name  -ErrorAction SilentlyContinue  | out-null
}

function global:copy_files($source, $destination, $exclude = @(), $include = @()) {
    create_directory $destination
    Get-ChildItem $source -Recurse -Exclude $exclude -Include $include | Copy-Item -Destination {Join-Path $destination $_.FullName.Substring($source.length)} 
}

function global:create_common_assembly_info($version, $filename)
{
    "using System.Reflection;

[assembly: AssemblyVersion(""$version"")]
[assembly: AssemblyFileVersion(""$version"")]"  | out-file $filename -encoding "ASCII" -force    
}

