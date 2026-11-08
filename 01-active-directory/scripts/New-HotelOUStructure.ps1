<#
.SYNOPSIS
    Creates the Active Directory OU structure for Kaya Resort Hotel.

.DESCRIPTION
    Builds one OU per hotel department, each with Users and Computers
    sub-OUs, plus Seasonal and Disabled OUs for seasonal staff.
    Safe to run more than once: existing OUs are skipped, nothing is deleted.

.EXAMPLE
    .\New-HotelOUStructure.ps1
#>

$domain      = (Get-ADDomain).DistinguishedName
$root        = "OU=KayaResort,$domain"
$departments = @("Front Office", "Housekeeping", "F&B", "Accounting", "Engineering", "IT")

function New-OUIfMissing {
    param(
        [string]$Name,
        [string]$Path
    )
    $dn = "OU=$Name,$Path"
    if (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$dn'") {
        Write-Host "Exists : $dn" -ForegroundColor Yellow
    }
    else {
        New-ADOrganizationalUnit -Name $Name -Path $Path
        Write-Host "Created: $dn" -ForegroundColor Green
    }
}

# Root OU for the hotel
New-OUIfMissing -Name "KayaResort" -Path $domain

# Department OUs with Users and Computers
foreach ($d in $departments) {
    New-OUIfMissing -Name $d           -Path $root
    New-OUIfMissing -Name "Users"      -Path "OU=$d,$root"
    New-OUIfMissing -Name "Computers"  -Path "OU=$d,$root"
}

# Seasonal staff lifecycle
New-OUIfMissing -Name "Seasonal" -Path $root
New-OUIfMissing -Name "Disabled" -Path $root