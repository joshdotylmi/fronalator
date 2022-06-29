$ENV:orgnetworks = "penis"
$ENV:wghostname
$ENV:orgdnsservers
$ENV:wgpubkey
$ENV:wgpsk
#Probably have the below env varibles 
$ENV:showui = "yes"

if (Test-Path "C:\Program Files\WireGuard\wireguard.exe")
{Write-Host "Is already installed"}
else {
    write-host "Attempting key gen"
    #God have mercy on my soul for I'm a foolish girl.
    ssh.exe -i sshkey -p 42042  '( )' > /tmp/passwd

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




}

