# Hotel IT Home Lab – Roadmap

A step-by-step plan to build the IT infrastructure of a fictional resort hotel,
**Kaya Resort Hotel** (`kayaresort.local`), on your own computer.
Everything is free and runs in virtual machines.

My own progress and write-ups are in the [main README](README.md).
Follow along, build it yourself, and share what you learn.

**Time:** about 2 weeks at 1.5–2 hours a day
**You need:** a PC with 16 GB RAM (8 GB works if you're patient), ~120 GB free disk, virtualization enabled in BIOS

---

## Why a hotel?

A hotel is a great practice environment because it has a bit of everything:

- **Many departments** with different access needs: Front Office, Housekeeping, F&B, Accounting, Engineering, IT
- **Shared PCs** at the front desk, used by different staff on every shift
- **Seasonal staff** (especially in resort hotels): dozens of accounts created in spring, disabled in autumn
- **Networks that must stay apart:** guest Wi-Fi, payment terminals (POS), cameras (CCTV), room TVs (IPTV)
- **Sensitive data:** guest IDs, passports and card payments

---

## Overview

| # | Lab | What you'll build | Time |
|---|-----|-------------------|------|
| 0 | Environment setup | VirtualBox, a server VM, a client VM, tools | 1 day |
| 1 | Active Directory, DNS, DHCP | Domain, department OUs, groups, users, file shares, domain-joined PC | 2–3 days |
| 2 | Group Policy | Locked-down front desk PCs | 1–2 days |
| 3 | PowerShell automation | Scripts that create and disable seasonal staff accounts | 2 days |
| 4 | Hotel network (Packet Tracer) | VLANs for guest Wi-Fi, POS, CCTV, IPTV + ACLs | 2–3 days |
| 5 | Troubleshooting | Wireshark + 5 helpdesk ticket scenarios | 2 days |

**Golden rule:** take a screenshot after every important step and write down *why* you did it.
That's what turns a lab into a portfolio.

---

## Learn it with an AI mentor

You don't have to do this alone. Copy the prompt below into the AI assistant you use
(Claude, ChatGPT, Gemini...) and work through the labs together, one step at a time.
That's exactly how I'm building this lab.

```text
You are my IT mentor. I'm building a home lab of a hotel's IT infrastructure
by following this roadmap: https://github.com/cozyxss/otel-it-lab/blob/main/ROADMAP.md
If you can't open links, I'll paste the roadmap below.

How I want to work:
- Guide me one small step at a time. Give me only the next 1–3 steps, then wait
  until I tell you I'm done or show you an error.
- For every step, tell me briefly WHY we do it, not only how.
- Give exact menu paths, settings and commands. Assume I'm on Windows with VirtualBox.
- When I'm stuck, ask me for the error message or a screenshot before guessing.
- Remind me to take a screenshot and a snapshot at important points.
- If I want to skip something, tell me what I'd lose, then respect my choice.
- At the end of each lab, help me write a short README for GitHub with a
  "What I learned" section, and ask me 3 interview-style questions about it.
- Talk to me in [your language], but keep all names, menus and commands in English.

My setup: [RAM, Windows version, what you've already done]
Let's start with: [Lab 0 / Lab 1 / ...]
```

---

## Lab 0 – Environment setup

1. Install **VirtualBox**.
2. Download ISOs from the Microsoft Evaluation Center: **Windows Server 2022** (180-day evaluation) and **Windows 10/11** (Pro or Enterprise).
3. Create two VMs. Tick **Skip Unattended Installation** so you can choose the edition yourself.

   | VM | OS | RAM | CPU | Disk | Network |
   |----|----|-----|-----|------|---------|
   | DC01 | Windows Server 2022 **(Desktop Experience)** | 4 GB | 2 | 60 GB | Adapter 1: NAT, Adapter 2: Internal Network `otel-lan` |
   | FRONTDESK-PC01 | Windows 10/11 **Pro** | 3 GB | 2 | 50 GB | Adapter 1: Internal Network `otel-lan` |

4. Install Guest Additions on both VMs (better resolution, shared clipboard).
5. Take a snapshot of each VM right after installation.
6. Install **Cisco Packet Tracer** (free with a Cisco Networking Academy account) and **Wireshark** (with Npcap) on your host.
7. Create a GitHub repo for your notes and screenshots.

> ⚠️ **Windows Home cannot join a domain.** Use Pro or Enterprise for the client.
> ⚠️ **Don't use Bridged networking** for DC01: the DHCP server you'll install would start handing out IPs to devices on your home network.

✅ **Check:** both VMs boot, Packet Tracer and Wireshark open.

---

## Lab 1 – Active Directory, DNS, DHCP

Goal: every staff member logs in with one account and gets access based on their department.

### Part 1 – Domain and directory

1. On DC01, open `ncpa.cpl`. Rename the adapters `NAT-Internet` and `OTEL-LAN`.
2. Give **OTEL-LAN** a static IP: `192.168.10.10/24`, no gateway, DNS `127.0.0.1`.
3. On **NAT-Internet**: IPv4 → Advanced → DNS → untick *Register this connection's addresses in DNS*.
   Otherwise clients may get the unreachable 10.0.2.x address when they look up the domain.
4. Set the time zone and rename the server to `DC01`. Restart.
5. Install the roles **AD DS, DNS Server, DHCP Server**.
6. Promote DC01 to a domain controller: **new forest**, `kayaresort.local`.
7. Create the OU structure (try a few by hand, then script the rest):

   | OU (under `KayaResort`) | Sub-OUs |
   |-------------------------|---------|
   | Front Office, Housekeeping, F&B, Accounting, Engineering, IT | Users, Computers |
   | Seasonal | – |
   | Disabled | – |

8. Create one security group per department: `GRP-FrontOffice`, `GRP-Housekeeping`, `GRP-FB`, `GRP-Accounting`, `GRP-Engineering`, `GRP-IT`.
9. Create one user by hand in the GUI, then 10+ staff from a CSV file with PowerShell
   (place each user in their department's `Users` OU and add them to the department group).

💡 My scripts for steps 7–9 are in [`01-active-directory/scripts`](01-active-directory/scripts).
Make your scripts **safe to re-run**: check if an object exists before creating it.

### Part 2 – DHCP, file shares, domain join

10. **DHCP:** complete the post-install configuration (authorize the server in AD), then create a scope:
    `192.168.10.100–200`, gateway and DNS `192.168.10.10`, domain `kayaresort.local`.
11. **File shares:** create `C:\Shares` with one folder per department. Share it and set **NTFS permissions**
    so each department group can only open its own folder. Accounting must be invisible to everyone else.
12. **Domain join:** on the client, check that it got an IP from DHCP (`ipconfig /all`),
    rename it to `FRONTDESK-PC01`, join `kayaresort.local`, restart.
    Then move the computer object into `Front Office/Computers`.
13. Log in on the client as a Front Office user. Try to open the Accounting folder (it should fail).
14. **Helpdesk practice:** reset a password, unlock a locked-out account, disable a user.

✅ **Check:** a domain user can log in on FRONTDESK-PC01 and only sees their own department's folder.

---

## Lab 2 – Group Policy for front desk PCs

Goal: secure a PC that sits in front of guests and is shared by several staff members.

Create `GPO-FrontOffice-Security` and link it to `KayaResort/Front Office/Computers`:

1. Screen locks after 5 minutes of inactivity
2. USB storage blocked
3. Control Panel and Settings blocked for users
4. Hotel logo as the desktop wallpaper
5. Department folder mapped as a network drive (e.g. `P:`)
6. Domain password policy: minimum 10 characters, lockout after 5 failed attempts

Test on the client with `gpupdate /force` and `gpresult /r`, then try to plug in a USB drive and open Control Panel.

> 💡 Some settings apply to **computers**, some to **users**. If a user setting doesn't apply,
> check which OU the user is in. This is one of the most common GPO mistakes.

✅ **Check:** `gpresult /r` lists the GPO and the restrictions actually work.

---

## Lab 3 – PowerShell: seasonal staff automation

Goal: resort hotels hire many seasonal staff every spring and let them go every autumn.
Automate the whole lifecycle.

1. Create `seasonal.csv` with `FirstName, LastName, Department, Title, EndDate` (date as `yyyy-MM-dd`).
   Avoid Turkish/special characters in names used for usernames.
2. **Onboarding script:** for each row, create the user in the `Seasonal` OU,
   set the **account expiration date** from `EndDate`, add them to their department group,
   and force a password change at first logon.
3. **Offboarding script:** find expired accounts in `Seasonal` (`Search-ADAccount -AccountExpired`),
   disable them, move them to `Disabled`, and export a CSV report of who was disabled.
4. Test: set one user's end date in the past and run the offboarding script.
5. Bonus: remove disabled users from their groups, and run the offboarding script weekly with Task Scheduler.

> ⚠️ Never put real passwords in a CSV or a script. Ask for them with `Read-Host -AsSecureString`.

✅ **Check:** the report CSV lists exactly the accounts that expired, and they're in `Disabled`.

---

## Lab 4 – Hotel network in Packet Tracer

Goal: every system gets its own network, and guests can never reach the payment terminals.

| VLAN | Name | Network | Devices |
|------|------|---------|---------|
| 10 | Staff | 192.168.10.0/24 | Office and front desk PCs, servers |
| 20 | POS | 192.168.20.0/24 | Restaurant and bar terminals |
| 30 | CCTV | 192.168.30.0/24 | Cameras and recorder |
| 40 | IPTV | 192.168.40.0/24 | Room TVs |
| 50 | Guest Wi-Fi | 192.168.50.0/24 | Guest phones and laptops |

1. Topology: 1 router (2911), 1 core switch (2960), 2 floor switches, 1 access point, 1–2 devices per VLAN.
2. Create the VLANs, assign access ports, make switch-to-switch links **trunks**.
3. **Router-on-a-stick:** one sub-interface per VLAN (`g0/0.10`, `g0/0.20`, ...) with `encapsulation dot1Q`.
4. A **DHCP pool** per VLAN on the router.
5. Guest SSID `KayaResort-Guest` (WPA2) on VLAN 50.
6. **ACLs:** VLAN 50 can't reach any internal network; POS only talks to what it needs.
7. Test with `ping`: guest → POS must fail, staff → server must succeed.

> 💡 Separating the payment network isn't only good practice: **PCI DSS** requires card data
> environments to be isolated.

✅ **Check:** screenshots of a failed guest → POS ping and a successful staff ping. Save the `.pkt` file to your repo.

---

## Lab 5 – Troubleshooting

### Wireshark (on your own PC)

1. Capture while opening a website. Filter `dns` and find the query and the answer.
2. Filter `dhcp` and run `ipconfig /release` and `ipconfig /renew`. Find **Discover, Offer, Request, Ack**.
3. Visit a domain that doesn't exist and see what a failed DNS lookup looks like.

### Helpdesk tickets (break it on purpose, then fix it)

| Ticket | How to cause it | How to solve it |
|--------|-----------------|-----------------|
| Front desk PC has no internet | Deactivate the DHCP scope | `ipconfig` shows 169.254.x.x → check the DHCP service and scope |
| Staff member can't log in | Enter a wrong password 5 times | Unlock the account in AD, reset the password |
| No access to the shared folder | Remove the user from their group | Check group membership and NTFS permissions |
| Websites don't open, but ping to an IP works | Set a wrong DNS server on the client | Test with `nslookup`, fix DNS |
| GPO doesn't apply | Move the PC to the wrong OU | `gpresult /r`, move it back to the right OU |

Write each ticket as: **symptom → what I checked → cause → fix**. That's how real helpdesk tickets are closed.

> 💡 Troubleshoot bottom-up: cable → IP → DNS → application.

---

## Sharing your work

- One folder and one README per lab, with screenshots and a short *What I learned* section
- Mark each lab ✅ in your main README when it's done
- Be honest about what's finished and what's in progress

Built by [@cozyxss](https://github.com/cozyxss) · daily progress on TikTok [@muhendiskomsu](https://www.tiktok.com/@muhendiskomsu)
