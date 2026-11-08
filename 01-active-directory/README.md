# Lab 1 – Active Directory, DNS, DHCP

Goal: build the identity core of the hotel, so every staff member logs in
with one account and gets access based on their department.

> Status: Part 1 done (domain, OUs, users, groups). Part 2 in progress (DHCP, file shares, joining the front desk PC).

## Part 1 – Domain and directory structure

### Network setup on DC01
| Adapter | Purpose | IP |
|---------|---------|----|
| NAT-Internet | Internet access | DHCP (10.0.2.15) |
| OTEL-LAN | Hotel internal network | 192.168.10.10/24 (static) |

- Static IP on the internal adapter, because clients must always find the server at the same address.
- DNS points to `127.0.0.1`, since DC01 is its own DNS server.
- *Register this connection's addresses in DNS* is **disabled** on the NAT adapter,
  so clients never receive the unreachable 10.0.2.x address for the domain.
- Time zone set to Istanbul. Kerberos authentication fails if clocks differ by more than 5 minutes.

![Network Setup](screenshots/00-otel-lan.png)

### Domain
- Installed **AD DS, DNS and DHCP** roles.
- Promoted DC01 to the first domain controller of a new forest: `kayaresort.local` (NetBIOS: `KAYARESORT`).

![Roles installed](screenshots/01-roles-installed.png)
![Domain created](screenshots/02-domain-created.png)

### OU structure
All OUs live under the root OU `KayaResort`.

| OU | Sub-OUs | Purpose |
|----|---------|---------|
| Front Office | Users, Computers | Reception staff and front desk PCs |
| Housekeeping | Users, Computers | Room cleaning staff |
| F&B | Users, Computers | Restaurant and bar staff |
| Accounting | Users, Computers | Finance team, most sensitive data |
| Engineering | Users, Computers | Technical service / maintenance |
| IT | Users, Computers | IT team |
| Seasonal | – | Seasonal staff accounts |
| Disabled | – | Accounts of staff who have left |

Created with [`New-HotelOUStructure.ps1`](scripts/New-HotelOUStructure.ps1).

![Script output](screenshots/03-script-output.png)
![OU structure](screenshots/03-ou-structure.png)

### Groups and users
- One security group per department (`GRP-FrontOffice`, `GRP-FB`, ...) – [`New-HotelGroups.ps1`](scripts/New-HotelGroups.ps1)
- One user created manually to learn the GUI (Ayse Yilmaz, Receptionist).
- 10 staff created from [`staff.csv`](scripts/staff.csv) with [`New-HotelStaff.ps1`](scripts/New-HotelStaff.ps1):
  placed in the right OU, added to the department group, password change forced at first logon.

![Users and groups](screenshots/04-users-groups.png)

## What I learned
- **OUs vs groups:** OUs organise objects and are where Group Policy is applied;
  security groups are used to grant permissions. A user lives in one OU but can be in many groups.
- **Scripts should be safe to re-run:** all scripts check if an object exists
  before creating it, so running them twice changes nothing.
- **Never mix create and delete:** cleanup was done once by hand; setup scripts only create.
- **Protected from accidental deletion:** AD protects new OUs by default, because deleting an OU deletes everything inside it.
- **Naming:** English names and no Turkish characters in account names avoid problems in scripts,
  email addresses and other systems. Computer names are limited to 15 characters.
- **Password policy:** the default domain policy requires complexity, so weak initial passwords are rejected.

## Part 2 – coming next
- DHCP scope for the hotel LAN
- Department file shares with NTFS permissions
- Joining FRONTDESK-PC01 to the domain
- Helpdesk tasks: password reset, account unlock
