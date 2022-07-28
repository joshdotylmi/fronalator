#These networks are to be routed through the wireguard vpn device.
$ENV:orgnetworks = "10.0.0.0/24,66.117.128.0/19"
#This is the ip or DNS name of a wireguard server.
$ENV:wghostname = "1.1.1.1"
#These are the name servers you want to use for the wireguard client vpn config
$ENV:orgdnsservers = "1.1.1.1,8.8.8.8"

#This will do a popup wireguard utility so the user can use wireguard for other vpn's however the device tunnel that wireguard installs doesn't show in the UI at all so it's not super useful unless you're using multiple wireguard vpn's.
$ENV:showui = "yes"

#This is a previous function but is no longer used. 
#function run-wgservercommand {
#
#    param (
#        [string[]]$terminalcmd
#    )
#    ssh.exe wgkeygen@$ENV:wghostname -i .\sshkey -p 42042 -o StrictHostKeyChecking=no $terminalcmd

    #start-process -Verbose  -wait -nonewwindow -FilePath "ssh.exe" -ArgumentList "-vv wgkeygen@$ENV:wghostname -i sshkey -p 42042 -o StrictHostKeyChecking=no $terminalcmd" -WorkingDirectory E:\Github\fronalator
#}

if (Test-Path "C:\ProgramData\Wireguard\wg_vpn.conf") {
    Write-Host "Is already installed"}
else {
    write-host "Attempting key gen"
    #God have mercy on my soul for I'm a foolish girl.
    icacls .\sshkey /inheritance:r
    icacls .\sshkey /grant SYSTEM:`(F`)
    icacls .\sshkey /grant BUILTIN\Administrators:`(F`)
    #icacls .\sshkey /grant azuread\josh.doty@lmi.net:`(F`)
    #icacls .\sshkey /grant lmi\josh.doty@lmi.net:`(F`)
     New-Item -Type Directory "C:\ProgramData\Wireguard" -Force
     $(ssh.exe wgkeygen@$ENV:wghostname -i .\sshkey -p 42042 -o StrictHostKeyChecking=no ./genClient.sh $env:COMPUTERNAME $ENV:orgdnsservers $ENV:orgnetworks)>"C:\ProgramData\Wireguard\wg_vpn.conf"

    Get-Process -Name 'WireGuard' | Stop-Process -Force
   
    Invoke-WebRequest -Uri https://download.wireguard.com/windows-client/wireguard-amd64-0.5.3.msi -OutFile wireguard-amd64.msi -UseBasicParsing 
    #From https://web.archive.org/web/20211228190654/https://old.reddit.com/r/WireGuard/comments/rqkxz7/alwayson_vpn/hqb7x3t/
    MsiExec /i wireguard-amd64.msi /qn DO_NOT_LAUNCH=1

     timeout 10

   Start-Process "C:\Program Files\WireGuard\wireguard.exe" -ArgumentList "/installtunnelservice C:\ProgramData\Wireguard\wg_vpn.conf" -wait
    Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\WireGuardTunnel$wg_vpn\' -Name 'DelayedAutostart' -Type DWord -Value 1 -PassThru
    if($ENV:showui -like "yes") {
        write-host  "Wireguard UI will be show during login of Windows"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\WireGuard\" -Name "LimitedOperatorUI" -Type DWord -Value 1 -PassThru
    }else{
    Start-Process -Wait -NoNewWindow -FilePath "C:\Program Files\WireGuard\wireguard.exe" -ArgumentList "/uninstallmanagerservice"
    Remove-Item -Force "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\WireGuard.lnk"
     }
    Get-Process -Name 'WireGuard' | Stop-Process -Force
    New-Item -Type Directory "C:\ProgramData\Wireguard" -Force
    timeout 10
    Restart-Service 'WireGuardTunnel$wg_vpn' -PassThru | Format-List

   # Remove-Item .\sshkey -Force
   remove-item -force ./wireguard-amd64.msi
   schtasks /create /f /ru SYSTEM /sc daily /tn "WireGuard Update" /tr "%PROGRAMFILES%\WireGuard\wireguard.exe /update" /st 03:00

   wireguard /dumplog |Out-File -Force C:\ProgramData\Wireguard\log.log


}

