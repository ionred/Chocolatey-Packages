import-module au
$module_name = 'msedge-dev-win-x64'
$download_module_name32 = 'Beta32MSI'
$download_module_name64 = 'Beta64MSI'
$versionpage1 = 'https://msedge.api.cdp.microsoft.com/api/v1/contents/Browser/namespaces/Default/names/'
$versionpage2 = '/versions/latest?action=select'
$downloads = 'https://www.microsoftedgeinsider.com/en-us/enterprise'
$params = '{"targetingAttributes": {}}'

function global:au_SearchReplace {
    @{
        'tools\chocolateyInstall.ps1' = @{
            "(^[$]url64\s*=\s*)('.*')"      = "`$1'$($Latest.URL64)'"
            "(^[$]url32\s*=\s*)('.*')"      = "`$1'$($Latest.URL32)'"
            "(?i)(^\s*checksum32\s*=\s*)('.*')" = "`$1'$($Latest.Checksum32)'"
            "(?i)(^\s*checksum64\s*=\s*)('.*')" = "`$1'$($Latest.Checksum64)'"
        }
     }
}

function global:au_GetLatest {
  
    $version_real=(Invoke-WebRequest "$($versionpage1)$($module_name)$($versionpage2)" -Method POST -ContentType 'application/json' -Body $params | ConvertFrom-Json).ContentID.Version

    if ($version_real.Substring(0,8) -eq '78.0.276') {
        $a = [version]$version_real
        $b = [string]$a.Revision
        $c = [int32]$b.PadRight(10,'0')
        $version = "$($a.Major).$($a.Minor).$($a.Build).$($c)"
    } else {
        $version = $version_real
    }
    $download_page = Invoke-WebRequest -Uri $downloads 
    $url_32 = ($download_page.AllElements | Where-Object data-download-enterpriseid -match $download_module_name32 |Select-Object -first 1 -ExpandProperty data-download-url)
    $url_64 = ($download_page.AllElements | Where-Object data-download-enterpriseid -match $download_module_name64 |Select-Object -first 1 -ExpandProperty data-download-url)
    $url32 = (Invoke-WebRequest -Uri $url_32 -MaximumRedirection 0 -ErrorAction 'Silent').Headers.Location
    $url64 = (Invoke-WebRequest -Uri $url_64 -MaximumRedirection 0 -ErrorAction 'Silent').Headers.Location
    
    $Latest = @{URL32 = $url32; URL64 = $url64; Version = $version; }
    return $Latest
}
write-host 'end'
update