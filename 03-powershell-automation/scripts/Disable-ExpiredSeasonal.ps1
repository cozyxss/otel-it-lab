<#
.SYNOPSIS
    Offboards seasonal staff whose accounts have expired.

.DESCRIPTION
    Finds expired accounts in the Seasonal OU and for each one:
    - removes it from all groups (except Domain Users)
    - disables it
    - moves it to the Disabled OU
    Writes a CSV report of everything it changed.

.PARAMETER ReportFolder
    Where to save the CSV report. Defaults to the current folder.

.EXAMPLE
    .\Disable-ExpiredSeasonal.ps1 -ReportFolder C:\Reports
#>

param(
    [string]$ReportFolder = "."
)

$base       = (Get-ADDomain).DistinguishedName
$seasonalOU = "OU=Seasonal,OU=KayaResort,$base"
$disabledOU = "OU=Disabled,OU=KayaResort,$base"

$expired = Search-ADAccount -AccountExpired -UsersOnly -SearchBase $seasonalOU

if (-not $expired) {
    Write-Host "No expired seasonal accounts." -ForegroundColor Yellow
    return
}

$report = foreach ($u in $expired) {
    $groups = Get-ADPrincipalGroupMembership -Identity $u |
        Where-Object { $_.Name -ne "Domain Users" }

    foreach ($g in $groups) {
        Remove-ADGroupMember -Identity $g -Members $u -Confirm:$false
    }

    Disable-ADAccount -Identity $u
    Move-ADObject -Identity $u.DistinguishedName -TargetPath $disabledOU

    Write-Host "Disabled: $($u.SamAccountName)" -ForegroundColor Green

    [pscustomobject]@{
        Name           = $u.Name
        SamAccountName = $u.SamAccountName
        Expired        = $u.AccountExpirationDate
        RemovedGroups  = ($groups.Name -join ";")
        DisabledOn     = Get-Date -Format "yyyy-MM-dd"
    }
}

$file = Join-Path $ReportFolder "disabled_$(Get-Date -Format yyyyMMdd).csv"
$report | Export-Csv -Path $file -NoTypeInformation -Encoding UTF8
Write-Host "Report : $file"
