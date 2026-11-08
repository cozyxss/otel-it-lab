<#
.SYNOPSIS
    Creates permanent hotel staff accounts from a CSV file.

.DESCRIPTION
    Each user is placed in their department's Users OU, added to the
    department group, and must change the password at first logon.
    Existing users are skipped.

.EXAMPLE
    .\New-HotelStaff.ps1 -CsvPath .\staff.csv
#>

param(
    [string]$CsvPath = ".\staff.csv"
)

$domain = Get-ADDomain
$root   = "OU=KayaResort,$($domain.DistinguishedName)"

$groupMap = @{
    "Front Office" = "GRP-FrontOffice"
    "Housekeeping" = "GRP-Housekeeping"
    "F&B"          = "GRP-FB"
    "Accounting"   = "GRP-Accounting"
    "Engineering"  = "GRP-Engineering"
    "IT"           = "GRP-IT"
}

$password = Read-Host "Initial password for new users" -AsSecureString

foreach ($u in Import-Csv $CsvPath) {
    $sam = "$($u.FirstName).$($u.LastName)".ToLower()

    if (Get-ADUser -Filter "SamAccountName -eq '$sam'") {
        Write-Host "Exists : $sam" -ForegroundColor Yellow
        continue
    }

    New-ADUser -Name "$($u.FirstName) $($u.LastName)" `
        -GivenName $u.FirstName -Surname $u.LastName `
        -SamAccountName $sam -UserPrincipalName "$sam@$($domain.DNSRoot)" `
        -Department $u.Department -Title $u.Title `
        -Path "OU=Users,OU=$($u.Department),$root" `
        -AccountPassword $password -ChangePasswordAtLogon $true -Enabled $true

    Add-ADGroupMember -Identity $groupMap[$u.Department] -Members $sam
    Write-Host "Created: $sam ($($u.Department))" -ForegroundColor Green
}