param(

    [Parameter(
        Mandatory = $true,
        HelpMessage = "apps.csv"
    )
    ]
    [String]
    $appsFile,

    [Parameter(
        Mandatory = $true,
        HelpMessage = "https://myTenant.sharepoint.com"
    )
    ]
    [String]
    $siteUrl,

    [Parameter(
        Mandatory = $true,
        HelpMessage = "https://myTenant.sharepoint.com/sites/apps"
    )
    ]
    [String]
    $appCatalogUrl

)

#===================================================================================
# Set Path
#===================================================================================

$scriptPath = $MyInvocation.MyCommand.Path
$execPath = Split-Path $scriptPath
Set-Location $execPath

#===================================================================================
# Load Apps to App Catalog
#===================================================================================

write-host -ForegroundColor Yellow "Login to App Catalog"
Connect-PnPOnline -Url $appCatalogUrl

write-host -ForegroundColor Yellow "Adding all apps"

Import-Csv $execPath\$appsFile -Encoding Default | Foreach-Object {

    try {

        write-host -ForegroundColor White "Adding app: $($_."Title")"
        $app = Add-PnPApp -Path ./packages/$($_."Name") -Overwrite
        write-host -ForegroundColor White "Completed"

        write-host -ForegroundColor White "Publishing app"
        Publish-PnPApp -Identity $app.Id
        write-host -ForegroundColor White "Completed adding app: $($_."Title")"

    }
    catch {
        write-host -ForegroundColor Red "An error occurred when adding app: $($_."Title"). The error details are: $($_)"
    }
}

write-host -ForegroundColor Yellow "Completed adding all apps"

#===================================================================================
# Install Apps
#===================================================================================

write-host -ForegroundColor Yellow "Login to target site"
Connect-PnPOnline -Url $siteUrl

write-host -ForegroundColor Yellow "Installing all apps"

Import-Csv $execPath\$appsFile -Encoding Default | Foreach-Object {

    try {

        write-host -ForegroundColor White "Getting info for app: $($_."Title")"
        $appTitle = $($_."Title");
        $app = Get-PnPApp | where { $_.Title -eq  $appTitle}
        write-host -ForegroundColor White "Completed"

        write-host -ForegroundColor White "Installing app"
        Install-PnPApp -Identity $app.Id
        write-host -ForegroundColor White "Completed installing app: $($_."Title")"

    }
    catch {
        write-host -ForegroundColor Red "An error occurred when installing app: $($_."Title"). The error details are: $($_)"
    }
}



