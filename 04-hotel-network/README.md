# Lab 4 – Hotel Network in Packet Tracer

Goal: give every hotel system its own network, and make sure guests can never reach the payment terminals or cameras.

## Topology
```
              HOTEL-RTR  (2911, router-on-a-stick)
                  │ trunk
              SW-CORE    (2960)
           trunk /      \ trunk
       SW-LOBBY          SW-ROOMS
       /      \         /    |     \
 FRONTDESK   POS-01  CCTV  TV-101  GUEST-AP
  (VLAN 10) (VLAN 20) (30)  (40)    (50)
```

## VLANs
| VLAN | Name | Network | Gateway | Devices |
|------|------|---------|---------|---------|
| 10 | STAFF | 192.168.10.0/24 | .1 | Office and front desk PCs, servers |
| 20 | POS | 192.168.20.0/24 | .1 | Restaurant and bar payment terminals |
| 30 | CCTV | 192.168.30.0/24 | .1 | Cameras and recorder |
| 40 | IPTV | 192.168.40.0/24 | .1 | Room TVs |
| 50 | GUEST | 192.168.50.0/24 | .1 | Guest Wi-Fi (`KayaResort-Guest`, WPA2) |

## How it works
- **Access ports** put each device in one VLAN. The device doesn't know its VLAN; the switch port decides.
- **Trunks** between switches and to the router carry all five VLANs on one cable, tagged with 802.1Q.
  Only VLANs 10–50 are allowed on trunks.
- **Router-on-a-stick:** one physical router port with a sub-interface per VLAN. Each sub-interface is that VLAN's gateway,
  so traffic between VLANs has to pass through the router, where the ACLs are.
- **DHCP per VLAN** on the router. The first 20 addresses of each network are kept for fixed-IP devices
  (printers, key card encoders, the NVR).

## Security rules (ACLs)
| ACL | Applied on | Rule |
|-----|-----------|------|
| `GUEST-IN` | VLAN 50, inbound | Guests get DHCP and internet, but no internal network (192.168.0.0/16) |
| `POS-IN` | VLAN 20, inbound | Payment terminals can't reach CCTV, IPTV or guests |

Separating card payment devices from everything else isn't only good practice:
**PCI DSS** requires the card data environment to be isolated.

## Configs
Each file can be pasted into the device's CLI:
[`HOTEL-RTR`](configs/HOTEL-RTR.txt) · [`SW-CORE`](configs/SW-CORE.txt) · [`SW-LOBBY`](configs/SW-LOBBY.txt) · [`SW-ROOMS`](configs/SW-ROOMS.txt)

## Testing
| Test | Expected result |
|------|-----------------|
| `show vlan brief` on SW-LOBBY | Fa0/1 in STAFF, Fa0/2 in POS |
| `show interfaces trunk` on SW-CORE | Gi0/1, Fa0/1, Fa0/2 trunking VLANs 10–50 |
| Devices set to DHCP | Each gets an address from its own VLAN |
| Guest laptop → `ping 192.168.20.x` (POS) | Fails (blocked by GUEST-IN) |
| FRONTDESK-PC → `ping 192.168.20.1` | Succeeds |
| POS-01 → `ping 192.168.30.x` (CCTV) | Fails (blocked by POS-IN) |

## What I learned
- **VLANs split one physical network into separate ones,** so a guest phone and a card terminal can share
  the same cables without seeing each other.
- **ACLs are read top to bottom and end with a hidden "deny all".** That's why each one ends with `permit ip any any`,
  and why DHCP (bootps) is allowed first.
- **Guest Wi-Fi is the least trusted network in a hotel.** It should reach the internet and nothing else.
