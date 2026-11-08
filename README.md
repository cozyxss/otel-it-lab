# Kaya Resort Hotel – IT Home Lab

A virtual IT infrastructure for a fictional resort hotel, built to practise
the systems a hotel IT team manages every day.

> Status: in progress (started November 2026)

## Lab environment
- VirtualBox on Windows (32 GB RAM host)
- DC01 – Windows Server 2022 (AD DS, DNS, DHCP)
- FRONTDESK-PC01 – Windows 10 Pro (front desk client)
- Cisco Packet Tracer, Wireshark

## Labs
| # | Lab | Status |
|---|-----|--------|
| 0 | [Lab environment setup](00-setup/README.md) | ✅ Done |
| 1 | [Active Directory, DNS, DHCP, department OUs](01-active-directory/README.md) | 🔄 Part 1 done |
| 2 | Group Policy for front desk PCs | ⏳ |
| 3 | PowerShell: seasonal staff automation | ⏳ |
| 4 | Hotel network: VLANs, guest Wi-Fi, ACL | ⏳ |
| 5 | Troubleshooting: Wireshark + helpdesk tickets | ⏳ |

## Highlights so far
- Department-based Active Directory structure for a hotel (Front Office, Housekeeping, F&B, Accounting, Engineering, IT)
- PowerShell scripts that are safe to re-run, creating OUs, groups and staff accounts from CSV
