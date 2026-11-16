# Lab 2 – Group Policy for Front Desk PCs

Goal: secure the PCs that sit in front of guests and are shared by several receptionists on every shift.

## Design
| GPO | Linked to | Purpose |
|-----|-----------|---------|
| `GPO-FrontOffice-Computer` | `KayaResort/Front Office/Computers` | Device rules: screen lock, USB block, loopback |
| `GPO-FrontOffice-User` | `KayaResort/Front Office/Users` | User rules: Control Panel, wallpaper, mapped drive |

**Loopback processing (Merge)** is enabled on the computer GPO. Front desk PCs are shared, so user
restrictions should apply to *anyone* who logs in there, not only Front Office staff.

## Settings
| Setting | Path | Value | Why |
|---------|------|-------|-----|
| Screen lock | Computer › Policies › Windows Settings › Security Settings › Local Policies › Security Options › *Interactive logon: Machine inactivity limit* | 300 seconds | A guest at the desk must never see an unlocked screen |
| USB storage | Computer › Policies › Administrative Templates › System › Removable Storage Access › *All Removable Storage classes: Deny all access* | Enabled | Stops data leaving on USB sticks and malware coming in |
| Loopback | Computer › Policies › Administrative Templates › System › Group Policy › *Configure user Group Policy loopback processing mode* | Merge | Shared PCs get the same restrictions for every user |
| Control Panel | User › Policies › Administrative Templates › Control Panel › *Prohibit access to Control Panel and PC settings* | Enabled | Staff can't change network or system settings |
| Wallpaper | User › Policies › Administrative Templates › Desktop › Desktop › *Desktop Wallpaper* | Hotel logo from a share | Consistent, branded front desk screens |
| Mapped drive | User › Preferences › Windows Settings › Drive Maps | `P:` → `\\DC01\Shares\FrontOffice` | Staff find their department folder without typing paths |
| Account lockout | Default Domain Policy (done in Lab 1) | 5 failed attempts | Slows down password guessing |

## Testing
On FRONTDESK-PC01:

```
gpupdate /force
gpresult /r
```

Expected results:
- `gpresult /r` lists both GPOs under *Applied Group Policy Objects*
- The screen locks after 5 minutes
- A USB stick can't be opened
- Control Panel shows a "restricted" message
- `P:` appears in File Explorer

## What I learned
- **Computer vs user settings:** computer settings follow the PC's OU, user settings follow the user's OU.
  Loopback lets a shared PC apply its own user rules to everyone.
- **GPO not applying?** First check the OU of the computer or user, then `gpresult /r`. This is the most common cause.
- **Policies refresh** every ~90 minutes; `gpupdate /force` applies them immediately.
