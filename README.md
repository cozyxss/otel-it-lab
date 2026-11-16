# Kaya Resort Hotel – IT Home Lab

A virtual IT infrastructure for a fictional resort hotel, built to practise
the systems a hotel IT team manages every day.

> Status: complete (November 2026)

## Lab environment
- VirtualBox on Windows (32 GB RAM host)
- DC01 – Windows Server 2022 (AD DS, DNS, DHCP)
- FRONTDESK-PC01 – Windows 10 Pro (front desk client)
- Cisco Packet Tracer, Wireshark

## Labs

> 🗺️ Want to build it yourself? Follow the step-by-step [ROADMAP](ROADMAP.md).

| # | Lab | Status |
|---|-----|--------|
| 0 | [Lab environment setup](00-setup/README.md) | ✅ Done |
| 1 | [Active Directory, DNS, DHCP, department OUs](01-active-directory/README.md) | ✅ Done |
| 2 | [Group Policy for front desk PCs](02-group-policy/README.md) | ✅ Done |
| 3 | [PowerShell: seasonal staff automation](03-powershell-automation/README.md) | ✅ Done |
| 4 | [Hotel network: VLANs, guest Wi-Fi, ACL](04-hotel-network/README.md) | ✅ Done |
| 5 | [Troubleshooting: Wireshark + helpdesk tickets](05-troubleshooting/README.md) | ✅ Done |

## Highlights
- Department-based Active Directory for a hotel, with a domain-joined front desk PC and DHCP
- Department file shares with NTFS permissions and Access-Based Enumeration
- Group Policy that locks down shared front desk PCs (screen lock, USB block, loopback)
- PowerShell automation for the full seasonal staff lifecycle, from hiring to offboarding with a report
- Hotel network with separate VLANs for staff, POS, CCTV, IPTV and guest Wi-Fi, isolated with ACLs (PCI DSS)
- A real troubleshooting case documented step by step
