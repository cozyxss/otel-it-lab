<#
.SYNOPSIS
    Creates seasonal staff accounts from a CSV file.

.DESCRIPTION
    For every row in the CSV:
    - creates the user in the Seasonal OU
    - sets the account to expire the day after EndDate
    - adds the user to their department group
    - forces a password change at first logon
    Existing users are skipped, so the script is safe to re-run.

.PARAMETER CsvPath
    CSV with the columns FirstName, LastName, Department, Title, EndDate (yyyy-MM-dd).

.EXAMPLE
    .\New-SeasonalStaff.ps1 -CsvPath .\seasonal.csv
#>

param(
    [string]$CsvPath = ".\seasonal.csv"
)

$domain = Get-ADDomain
$ou     = "OU=Seasonal,OU=KayaResort,$($domain.DistinguishedName)"

$groupMap = @{
    "Front Office" = "GRP-FrontOffice"
    "Housekeeping" = "GRP-Housekeeping"
    "F&B"          = "GRP-FB"
    "Accounting"   = "GRP-Accounting"
    "Engineering"  = "GRP-Engineering"
    "IT"           = "GRP-IT"
}

# Never store passwords in the CSV or the script
$password = Read-Host "Initial password for seasonal staff" -AsSecureString

foreach ($u in Import-Csv $CsvPath) {
    $sam = "$($u.FirstName).$($u.LastName)".ToLower()

    if (Get-ADUser -Filter "SamAccountName -eq '$sam'") {
        Write-Host "Exists : $sam" -ForegroundColor Yellow
        continue
    }

    if (-not $groupMap.ContainsKey($u.Department)) {
        Write-Host "Skipped: $sam (unknown department '$($u.Department)')" -ForegroundColor Red
        continue
    }

    # The account expires at the start of the given day, so add one day
    # to let the person work on their last day.
    $endDate = [datetime]::ParseExact($u.EndDate, 'yyyy-MM-dd', [Globalization.CultureInfo]::InvariantCulture)

    New-ADUser -Name "$($u.FirstName) $($u.LastName)" `
        -GivenName $u.FirstName -Surname $u.LastName `
        -SamAccountName $sam -UserPrincipalName "$sam@$($domain.DNSRoot)" `
        -Department $u.Department -Title $u.Title `
        -Description "Seasonal staff until $($u.EndDate)" `
        -Path $ou -AccountExpirationDate $endDate.AddDays(1) `
        -AccountPassword $password -ChangePasswordAtLogon $true -Enabled $true

    Add-ADGroupMember -Identity $groupMap[$u.Department] -Members $sam
    Write-Host "Created: $sam ($($u.Department), until $($u.EndDate))" -ForegroundColor Green
}
