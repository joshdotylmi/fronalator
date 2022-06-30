$ENV:orgnetworks = "10.0.0.0/24"
$ENV:wghostname = "66.117.128.224"
$ENV:orgdnsservers = "1.1.1.1,8.8.8.8"
#Probably have the below env varibles 
$ENV:showui = "yes"
function run-wgservercommand {

    param (
        [string[]]$terminalcmd
    )
    ssh.exe -vv wgkeygen@$ENV:wghostname -i sshkey -p 42042 -o StrictHostKeyChecking=no $terminalcmd

    #start-process -Verbose  -wait -nonewwindow -FilePath "ssh.exe" -ArgumentList "-vv wgkeygen@$ENV:wghostname -i sshkey -p 42042 -o StrictHostKeyChecking=no $terminalcmd" -WorkingDirectory E:\Github\fronalator
}

#if (Test-Path "C:\Program Files\WireGuard\wireguard.exe")
#{Write-Host "Is already installed"}
#else {
    write-host "Attempting key gen"
    #God have mercy on my soul for I'm a foolish girl.
    icacls .\sshkey /inheritance:r
    icacls .\sshkey /grant SYSTEM:`(F`)
    icacls .\sshkey /grant BUILTIN\Administrators:`(F`)
    #icacls .\sshkey /grant azuread\josh.doty@lmi.net:`(F`)
    #icacls .\sshkey /grant lmi\josh.doty@lmi.net:`(F`)
    run-wgservercommand $("'"+"./genClient.sh "+$env:COMPUTERNAME+" "+$ENV:orgdnsservers+" "+ $ENV:orgnetworks+"'") 

    Get-Process -Name 'WireGuard' | Stop-Process -Force
    New-Item -Type Directory "C:\ProgramData\Wireguard" -Force
    Invoke-WebRequest -Uri https://download.wireguard.com/windows-client/wireguard-installer.exe -OutFile wireguard-installer.exe -UseBasicParsing 
    #From https://web.archive.org/web/20211228190654/https://old.reddit.com/r/WireGuard/comments/rqkxz7/alwayson_vpn/hqb7x3t/
    Start-Process -Wait -NoNewWindow -FilePath wireguard-installer.exe -ArgumentList   "/qn /installtunnelservice", "C:\ProgramData\Wireguard\wg_vpn.conf"
    Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\WireGuardTunnelwg_vpn\' -Name 'DelayedAutostart' -Type DWord -Value 1 -PassThru
    if($ENV:showui -like "yes") {
        write-host  "Wireguard UI will be show during login of Windows"
        Set-ItemProperty -Path "HKLM:\SOFTWARE\WireGuard\" -Name "LimitedOperatorUI" -Type DWord -Value 1 -PassThru
    }else{
    Start-Process -Wait -NoNewWindow -FilePath "C:\Program Files\WireGuard\wireguard.exe" -ArgumentList "/uninstallmanagerservice"
    Remove-Item -Force "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\WireGuard.lnk"
     }
    Get-Process -Name 'WireGuard' | Stop-Process -Force
    New-Item -Type Directory "C:\ProgramData\Wireguard" -Force
    Restart-Service 'WireGuardTunnelwg_vpn' -PassThru | Format-List




#}

