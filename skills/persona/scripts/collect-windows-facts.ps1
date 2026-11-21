<#
.SYNOPSIS
Collects read-only facts from this Windows computer for the ITproinstructor persona.

.DESCRIPTION
Prints facts a Network Administrator would otherwise have to ask for: Windows build and
last updates, last start-up time, domain role, adapter and DNS server settings, Group
Policy result, and recent crash events. It changes nothing and needs no elevation.
Sections that need elevation say so in their own output.

.PARAMETER Area
All (default), Os, Network, Gpo or Hardware.

.EXAMPLE
pwsh -NoProfile -ExecutionPolicy Bypass -File collect-windows-facts.ps1 -Area Network
#>
param(
    [ValidateSet('All', 'Os', 'Network', 'Gpo', 'Hardware')]
    [string]$Area = 'All'
)

function Write-Section([string]$Title) { "`n=== $Title ===" }

function Invoke-Section([string]$Title, [scriptblock]$Body) {
    Write-Section $Title
    try { & $Body | Out-String -Width 200 | ForEach-Object { $_.Trim() } }
    catch { "COULD NOT READ: $($_.Exception.Message)" }
}

"collect-windows-facts  host=$env:COMPUTERNAME  user=$env:USERDOMAIN\$env:USERNAME"
"PowerShell $($PSVersionTable.PSVersion) ($((Get-Host).Name))  collected $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss K')"

if ($Area -in 'All', 'Os') {
    Invoke-Section 'OS BUILD' {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        $cv = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -ErrorAction Stop
        [pscustomobject]@{
            Caption        = $os.Caption
            DisplayVersion = $cv.DisplayVersion
            Build          = "$($cv.CurrentBuild).$($cv.UBR)"
            LastStartUp    = $os.LastBootUpTime
            InstallDate    = $os.InstallDate
        } | Format-List
    }
    Invoke-Section 'LAST 5 UPDATES (Get-HotFix: Component Based Servicing updates only)' {
        Get-HotFix -ErrorAction Stop | Sort-Object -Property InstalledOn -Descending |
            Select-Object -First 5 -Property HotFixID, Description, InstalledOn | Format-Table -AutoSize
    }
}

if ($Area -in 'All', 'Network', 'Gpo') {
    Invoke-Section 'DOMAIN ROLE' {
        $cs = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop
        $roles = 'Standalone workstation', 'Member workstation', 'Standalone server',
                 'Member server', 'Backup domain controller', 'Primary domain controller'
        [pscustomobject]@{
            PartOfDomain = $cs.PartOfDomain
            Domain       = $cs.Domain
            DomainRole   = "$($cs.DomainRole) ($($roles[$cs.DomainRole]))"
            LogonServer  = $env:LOGONSERVER
        } | Format-List
    }
}

if ($Area -in 'All', 'Network') {
    Invoke-Section 'ADAPTERS THAT ARE UP' {
        Get-NetAdapter -ErrorAction Stop | Where-Object Status -EQ 'Up' |
            Select-Object -Property Name, InterfaceDescription, LinkSpeed, MacAddress | Format-Table -AutoSize
    }
    Invoke-Section 'IP CONFIGURATION' {
        Get-NetIPConfiguration -ErrorAction Stop | ForEach-Object {
            [pscustomobject]@{
                Interface = $_.InterfaceAlias
                IPv4      = $_.IPv4Address.IPAddress -join ', '
                Gateway   = $_.IPv4DefaultGateway.NextHop -join ', '
                DNS       = $_.DNSServer.ServerAddresses -join ', '
            }
        } | Format-Table -AutoSize
    }
    Invoke-Section 'DNS SERVERS PER INTERFACE (IPv4)' {
        Get-DnsClientServerAddress -AddressFamily IPv4 -ErrorAction Stop |
            Where-Object ServerAddresses | Select-Object -Property InterfaceAlias, ServerAddresses | Format-Table -AutoSize
    }
}

if ($Area -in 'All', 'Gpo') {
    Invoke-Section 'GROUP POLICY RESULT (gpresult /r; computer settings need an elevated shell)' {
        gpresult.exe /r 2>&1
    }
}

if ($Area -in 'All', 'Hardware') {
    Invoke-Section 'CRASH AND UNEXPECTED SHUTDOWN EVENTS, LAST 14 DAYS (System log: 41, 1001, 6008)' {
        $filter = @{ LogName = 'System'; Id = 41, 1001, 6008; StartTime = (Get-Date).AddDays(-14) }
        $events = Get-WinEvent -FilterHashtable $filter -MaxEvents 10 -ErrorAction SilentlyContinue
        if ($events) { $events | Select-Object -Property TimeCreated, Id, ProviderName | Format-Table -AutoSize }
        else { 'None found.' }
    }
}
