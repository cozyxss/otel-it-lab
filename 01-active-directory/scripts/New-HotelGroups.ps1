<#
.SYNOPSIS
    Creates one security group per hotel department.

.DESCRIPTION
    Groups are used for permissions (file shares, apps).
    Existing groups are skipped.

.EXAMPLE
    .\New-HotelGroups.ps1
#>

$root = "OU=KayaResort,$((Get-ADDomain).DistinguishedName)"

$groups = @{
    "Front Office" = "GRP-FrontOffice"
    "Housekeeping" = "GRP-Housekeeping"
    "F&B"          = "GRP-FB"
    "Accounting"   = "GRP-Accounting"
    "Engineering"  = "GRP-Engineering"
    "IT"           = "GRP-IT"
}

foreach ($dept in $groups.Keys) {
    $name = $groups[$dept]
    if (Get-ADGroup -Filter "Name -eq '$name'") {
        Write-Host "Exists : $name" -ForegroundColor Yellow
    }
    else {
        New-ADGroup -Name $name -GroupScope Global -GroupCategory Security `
            -Path "OU=$dept,$root" -Description "All $dept staff"
        Write-Host "Created: $name" -ForegroundColor Green
    }
}