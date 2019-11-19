At the moment the IP address for the WSL2 local network is not static. 

Xming needs the WSL2 IP address so this script sets it in the `X0.hosts` file, which is assumed to be here:

    C:\\Program Files (x86)\\Xming\\X0.hosts

Since this is a protected folder *the script must be run as administrator*.

In addition the script sets the Windows adapter IP address in WSL2 Linux, in a file called:

    ~/.wslrc

... when in WSL2, you must get this to update the `DISPLAY` env variable it sets by:

    source ~/.wslrc