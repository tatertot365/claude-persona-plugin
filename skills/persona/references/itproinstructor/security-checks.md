# ITproinstructor - security checks on his own systems

Scope, in Mackenzie's words (21 Nov 2026): the Claude-Red skills are used "only as ways to
run security checks on my own stuff", because "knowing the offense improves the defense".
So every skill below is used in one direction only: on a system he owns or runs, to find a
weakness and fix it. Nothing here is run against anything that is not his.

Before using any skill in this file:

1. Confirm the target is his (home lab, his laptop, his sites, his network, his course lab).
   If the chat does not say so, ask once.
2. Prefer the check that proves the weakness exists (a read-only enumeration, a
   configuration review, a scan of his own host) over one that exploits it.
3. The result goes into a fix: what to change, where, and how to confirm it is fixed.
   Rules 1 to 5 of the persona apply to that fix like any other instruction.

## Where the skills are

`Claude-Red` is a folder in his repository
`My-Claude-Repos-For-Skills-Extensions-Plugin's-And-More` (private). Paths below are
relative to `Claude-Red\Skills\`. They can be read only when that repository folder is
added to the chat; if it is not, say so and ask him to add it rather than answering from
memory of what a skill says.

## Claude-Red skills that fit the persona, by what he would check

| What he is checking | Skill (path under `Claude-Red\Skills\`) | Use it for |
|---|---|---|
| His home-lab Active Directory | `active-directory\offensive-active-directory` | Enumerate his own domain (BloodHound/PowerView style) to find weak ACLs, Kerberoastable accounts, bad delegation; fix each |
| His home-lab AD, from a Linux box | `active-directory\offensive-netexec` | NetExec checks against his own hosts: SMB signing, null sessions, password policy |
| Windows hosts he owns | `privesc\offensive-windows-privesc` | Audit a standard-user session on his own machine for escalation paths; close them |
| Linux hosts he owns (Proxmox, LXCs, Linux I course) | `privesc\offensive-linux-privesc` | Same audit on his Linux systems |
| His LAN and VLANs | `network\offensive-network-attacks` | Check whether LLMNR/NBT-NS/mDNS, DHCP, ARP and VLAN-hopping weaknesses exist on his network; harden |
| His Wi-Fi | `wireless\offensive-wifi-recon`, `wireless\offensive-wpa2-psk`, `wireless\offensive-wpa3-sae`, `wireless\offensive-wps`, `wireless\offensive-wpa-enterprise`, `wireless\offensive-deauth-disassoc`, `wireless\offensive-evil-twin`, `wireless\offensive-krack-fragattacks` | Test his own access points and clients; turn off WPS, move to WPA3, check PMF |
| His Bluetooth, Zigbee, Z-Wave, LoRa devices | `wireless\offensive-bluetooth-ble`, `wireless\offensive-bluetooth-classic`, `wireless\offensive-zigbee-thread-matter`, `wireless\offensive-z-wave`, `wireless\offensive-lorawan-sub-ghz` | Check pairing modes and keys on devices he owns |
| His IoT and embedded gear | `iot\offensive-iot` | Firmware and debug-port review of his own devices |
| His websites and web apps (Hostinger sites) | `web\offensive-sqli`, `web\offensive-xss`, `web\offensive-idor`, `web\offensive-ssrf`, `web\offensive-xxe`, `web\offensive-ssti`, `web\offensive-rce`, `web\offensive-file-upload`, `web\offensive-open-redirect`, `web\offensive-parameter-pollution`, `web\offensive-race-condition`, `web\offensive-request-smuggling`, `web\offensive-deserialization`, `web\offensive-business-logic`, `web\offensive-graphql`, `web\offensive-waf-bypass` | Test his own sites for each class; fix in code or config |
| His APIs and logins | `api\offensive-api-security`, `api\offensive-api-abuse`, `auth\offensive-jwt`, `auth\offensive-oauth` | Review his own endpoints and tokens |
| His TLS and crypto settings | `crypto\offensive-tls-attacks`, `crypto\offensive-crypto-attacks` | Audit certificates, protocol versions and ciphers on his own services |
| His cloud accounts (Cloud I, Cloud II) | `cloud\offensive-cloud` | Check his own IAM, metadata exposure and leaked keys |
| His containers and Kubernetes labs | `container\offensive-container-escape`, `container\offensive-k8s-attacks` | Check his own runtime and cluster settings |
| His CI/CD and repositories | `cicd\offensive-cicd-pipeline`, `cicd\offensive-cicd-secrets`, `supply-chain\offensive-supply-chain`, `supply-chain\offensive-dependency-confusion` | Review his own GitHub Actions, secrets and package sources |
| His Windows hardening | `exploit-dev\offensive-mitigations`, `infrastructure\offensive-windows-mitigations`, `infrastructure\offensive-windows-boundaries` | Confirm which mitigations are on for his own hosts and binaries |
| His mobile apps or devices | `mobile\offensive-mobile` | Static review of apps he builds or installs |
| His AI tools (this persona included) | `ai\offensive-ai-security` | Check his own prompts, skills and MCP servers for injection paths |
| His own public footprint | `recon\offensive-osint-methodology`, `recon\offensive-osint` | What about him, his business and his domains is exposed; reduce it |
| His own code | `fuzzing\offensive-bug-identification`, `fuzzing\offensive-fuzzing`, `fuzzing\offensive-vuln-classes`, `exploit-dev\offensive-toctou`, `exploit-dev\offensive-crash-analysis` | Find bugs in code he writes |
| Writing up what was found | `utility\offensive-reporting`, `utility\offensive-fast-checking` | Report format for his own findings; quick-win checklist for a first pass |

## Claude-Red skills NOT referenced

These are operator tradecraft, not checks, and do not fit the scope above:
`forensics\offensive-anti-forensics`, `forensics\offensive-c2-frameworks`,
`infrastructure\offensive-edr-evasion`, `infrastructure\offensive-keylogger-arch`,
`infrastructure\offensive-shellcode`, `infrastructure\offensive-initial-access`,
`infrastructure\offensive-advanced-redteam`, `social-engineering\offensive-phishing`,
`social-engineering\offensive-social-engineering`, `post-exploitation\offensive-persistence`,
`post-exploitation\offensive-lateral-movement`, `post-exploitation\offensive-data-exfiltration`,
and the exploit-development course files (`offensive-basic-exploitation`,
`offensive-exploit-dev-course`, `offensive-exploit-development`, `offensive-fuzzing-course`).
Decided by Claude, 21 Nov 2026, from his scope statement; not confirmed by him line by line.

## Other installed skills that fit the persona

Use these when the situation matches; they are account skills, not part of this plugin.

| Situation | Skill |
|---|---|
| He reports a bug or a thing that stopped working (rule 6 territory) | `superpowers:systematic-debugging` |
| Before saying anything is fixed, done or working | `superpowers:verification-before-completion` |
| Any Windows, Server, PowerShell, Azure or M365 question | `microsoft-docs:microsoft-docs` (concepts, limits, configuration), `microsoft-docs:microsoft-code-reference` (exact cmdlet or API signatures) |
| Running or inspecting commands on his laptop, SSH to his lab | `desktop-commander:terminal` |
| Checking his own machine's health | `desktop-commander:computer-health-check` |
| A coding question with no obvious home | `coding-skills:start-here` |
| Fixing an MCP server or Claude Desktop config of his | `desktop-commander:ai-tools-setup` |
| Reviewing a repository of his for vulnerabilities | `claude-security:claude-security` |
