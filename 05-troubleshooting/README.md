# Lab 5 – Troubleshooting

Goal: practise the problems a hotel helpdesk sees every week, and solve them with a method instead of guessing.

## Method: bottom-up
1. **Physical:** cable, port light, Wi-Fi connected?
2. **IP:** does the device have a valid address? (`ipconfig`)
3. **DNS:** can it resolve names? (`nslookup`)
4. **Application / permissions:** is the user in the right group and OU?

## Wireshark
| Filter | What to look for |
|--------|------------------|
| `dhcp` | The 4 messages of getting an IP: **Discover → Offer → Request → Ack** (run `ipconfig /release` and `/renew`) |
| `dns` | A query and its answer. A domain that doesn't exist returns *No such name* |

## Helpdesk tickets
Each ticket was created on purpose in the lab, then solved.
Written the way real tickets are closed: **symptom → checked → cause → fix**.

| # | Symptom | Checked | Cause | Fix |
|---|---------|---------|-------|-----|
| 1 | Front desk PC has no internet | `ipconfig` shows `169.254.x.x` | DHCP scope deactivated | Activate the scope, `ipconfig /renew` |
| 2 | Staff member can't log in | AD: account locked | 5 wrong passwords | Unlock in AD, reset password if needed |
| 3 | Shared folder looks empty | `whoami /groups` | User not in the department group | Add to group, sign out and back in |
| 4 | Websites don't open, but pinging an IP works | `nslookup` fails | Wrong DNS server on the client | Point DNS to DC01 (or set it back to DHCP) |
| 5 | GPO doesn't apply | `gpresult /r` | PC in the wrong OU | Move it to `Front Office/Computers`, `gpupdate /force` |

Ticket 3 first happened by accident in [Lab 1](../01-active-directory/README.md#real-troubleshooting-the-shared-folder-is-empty).

## What I learned
- `169.254.x.x` always means "no DHCP server reached", which points straight at DHCP or the network path.
- "Ping by IP works but websites don't" is almost always DNS.
- Group changes only apply after a new logon, because the access token is built at sign-in.
