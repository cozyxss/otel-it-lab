<#
.SYNOPSIS
    Creates department file shares for Kaya Resort Hotel.
.DESCRIPTION
    - C:\Shares with one folder per department
    - NTFS: each department group gets Modify on its own folder only
    - Share: open to authenticated users, access controlled by NTFS
    - Access-Based Enumeration: users only see folders they can open
.EXAMPLE
    .\New-HotelShares.ps1
#>

$root      = "C:\Shares"
$shareName = "Shares"
$domain    = (Get-ADDomain).NetBIOSName

$departments = [ordered]@{
    "FrontOffice"  = "GRP-FrontOffice"
    "Housekeeping" = "GRP-Housekeeping"
    "FB"           = "GRP-FB"
    "Accounting"   = "GRP-Accounting"
    "Engineering"  = "GRP-Engineering"
    "IT"           = "GRP-IT"
}

# 1. Root folder: only admins have full control, users can just list it
if (-not (Test-Path $root)) {
    New-Item -Path $root -ItemType Directory | Out-Null
    Write-Host "Created: $root" -ForegroundColor Green
}
icacls $root /inheritance:r /grant:r "SYSTEM:(OI)(CI)F" "Administrators:(OI)(CI)F" "Authenticated Users:(RX)" | Out-Null

# 2. Department folders: each group gets Modify on its own folder
foreach ($folder in $departments.Keys) {
    $path  = Join-Path $root $folder
    $group = $departments[$folder]

    if (-not (Test-Path $path)) {
        New-Item -Path $path -ItemType Directory | Out-Null
        Write-Host "Created: $path" -ForegroundColor Green
    }
    icacls $path /grant "$domain\${group}:(OI)(CI)M" | Out-Null
    Write-Host "NTFS   : $folder -> $group (Modify)"
}

# 3. Network share with Access-Based Enumeration
if (-not (Get-SmbShare -Name $shareName -ErrorAction SilentlyContinue)) {
    New-SmbShare -Name $shareName -Path $root `
        -FullAccess "BUILTIN\Administrators" `
        -ChangeAccess "NT AUTHORITY\Authenticated Users" `
        -FolderEnumerationMode AccessBased | Out-Null
    Write-Host "Shared : \\$env:COMPUTERNAME\$shareName" -ForegroundColor Green
}
else {
    Write-Host "Exists : share $shareName" -ForegroundColor Yellow
}
