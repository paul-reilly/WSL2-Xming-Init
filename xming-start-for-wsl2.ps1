function Get-WSL2IPAddress{
    param([string]$distro)
    $ifconfig_cmd = @("run", "ifconfig eth0");
    try {
        $cmd_output = & $distro $ifconfig_cmd
    } 
    catch {
        write-error "Error: command '$distro $ifconfig_cmd' failed. Please check that WSL distro '$distro' is installed."
        return $null
    }
    foreach ($line in $cmd_output) {
        if ($line -match 'inet (?<IP>.+)  netmask .+  broadcast') {
          return $Matches.IP
        }
    }

    return $null
}

function getIPAddress {
  $ipaddress = $(ipconfig | where-object {$_ -match 'IPv4.+\s(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})' } | out-null; 
    $Matches[1]
  )

  return $ipaddress
}

function main {
    $ip = getIPAddress
    write-output $ip

    # needs file made executable with "chmod a+x ~/.wslrc"
    $cmd = "`"export DISPLAY=$($ip):0`""
    $save_to_file = " > ~/.wslrc"
    try {
        & "ubuntu" "run" "echo" $cmd $save_to_file
    }
    catch {
        write-error "Error: could not execute 'export DISPLAY' command on Linux."
        return $null
    }

    if ($process = get-process Xming -ErrorAction SilentlyContinue) { 
        write-output "Xming already running, stopping process..."
        stop-process $process
        wait-process Xming
        write-output "Process stopped."
    }

    if ($ip_address = Get-WSL2IPAddress -d ubuntu) {
        write-output "Starting Xming, listening on: $ip_address"
        try {
            set-content -path "C:\\Program Files (x86)\\Xming\\X0.hosts" -encoding ASCII -value $ip_address
        }
        catch {
            write-error "Whoops"
        }
        # TODO: attempting to start using '-from' the WSL2 IP is not working, have to edit Xming/X0.hosts
        #        but it's in Program Files so needs admin
        write-output (& "C:\\Program Files (x86)\\Xming\\Xming.exe" ":0" "-clipboard" "-multiwindow") # "-from $ip_address")
    }
    else {
        write-error "Error: attempt to get IP address from WSL2 ifconfig failed."
    }
}

main
write-output "Exiting ps1 script"
read-host "Press ENTER to continue..."
