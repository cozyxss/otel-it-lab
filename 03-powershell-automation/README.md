# Lab 3 – PowerShell: Seasonal Staff Automation

Goal: resort hotels hire many seasonal staff every spring and let them go every autumn.
Automate the whole account lifecycle instead of clicking through it one person at a time.

## Lifecycle
| Stage | Script | What happens |
|-------|--------|--------------|
| Hiring (spring) | [`New-SeasonalStaff.ps1`](scripts/New-SeasonalStaff.ps1) | Accounts created in `Seasonal` from [`seasonal.csv`](scripts/seasonal.csv), with an expiry date and the right department group |
| During the season | Active Directory | On the expiry date the account stops working on its own |
| End of season | [`Disable-ExpiredSeasonal.ps1`](scripts/Disable-ExpiredSeasonal.ps1) | Expired accounts removed from groups, disabled, moved to `Disabled`, CSV report saved |

## Design decisions
- **Account expiration date** is set at creation. Even if nobody runs the offboarding script on time,
  the account can't be used after the season.
- **Expiry is EndDate + 1 day,** because AD expires the account at the *start* of the given day.
- **Passwords are never stored** in the CSV or the script. The initial password is asked with `Read-Host -AsSecureString`,
  and users must change it at first logon.
- **Safe to re-run:** existing users are skipped; unknown departments are reported instead of guessed.
- **Disable, don't delete:** accounts are kept in `Disabled` with a report, so access can be audited later
  and returning staff can be re-enabled next season.

## Usage
```powershell
# Spring
.\New-SeasonalStaff.ps1 -CsvPath .\seasonal.csv

# End of season (or weekly with Task Scheduler)
.\Disable-ExpiredSeasonal.ps1 -ReportFolder C:\Reports
```

To test offboarding without waiting for October, set one test user's expiry in the past:
```powershell
Set-ADAccountExpiration -Identity can.yildiz -DateTime (Get-Date).AddDays(-1)
```

## What I learned
- Search-ADAccount finds expired, locked or inactive accounts in one line, which helps with regular cleanups.
- A report of every automated change matters as much as the change itself: "who was disabled and when?"
- Scheduling the offboarding script with Task Scheduler turns a once-a-year manual job into a safe routine.
