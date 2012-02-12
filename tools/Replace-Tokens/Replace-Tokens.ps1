function global:replace_tokens_with_file($data_file, $template_file, $output_file) {
	replace_tokens (. $data_file) $template_file $output_file
}

function global:replace_tokens($template_data, $template_file, $output_file) {
	Test-ExistenceOfFiles $template_file $output_file
	Replace-Values $template_data
}

function Replace-Values($template_data) {
	Write-Output "Replacing tokens for $template_file..."
	$template_text = Get-Content $template_file

	foreach ($item in $template_data.Keys) {
		if(-not($template_text | Select-String "#{$item}" -quiet)) {
			Write-Output "	-> Could not find token #{$item} in template"
		}
		$template_text = $template_text -replace "#{$item}", $template_data.Get_Item($item).Trim()
	}
	
	$nonreplaced_tokens = $template_text | Select-String -Pattern "#\{.*\}" -AllMatches | % { $_.Matches } | % { $_.Value }
	
	if($nonreplaced_tokens) {
		Write-Output "	-> Could not find the tokens $nonreplaced_tokens in template data"
	}
	
	$output_dir = Split-Path $output_file
	if (!(Test-Path $output_dir)) {
		mkdir $output_dir  -ErrorAction SilentlyContinue  | out-null
	}
	
	$template_text | sc -path $output_file
	Write-Output "Output written to $output_file"
}

function Test-ExistenceOfFiles($template_file, $output_file){
	if (!$template_file) { 
		throw "Path to template file was not provided"        
	}
	if (!(Test-Path $template_file)) {
		throw "Template file could not be found --" + $template_file
	}
	if (!$output_file) {
		throw "Output file was not provided"        
	}
}