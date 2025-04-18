#!/usr/bin/env python3
import os
import platform
import sys
import ctypes
import winreg

# ANSI Color codes
GREEN = '\033[92m'
RED = '\033[91m'
YELLOW = '\033[93m'
BLUE = '\033[94m'
RESET = '\033[0m'

def is_admin():
    """Check if the script is running with administrative privileges."""
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False

def find_pwsh_path():
    """Find the path to PowerShell 7 executable."""
    possible_paths = [
        r"C:\Program Files\PowerShell\7\pwsh.exe",
        r"C:\Program Files (x86)\PowerShell\7\pwsh.exe",
    ]
    
    for path in possible_paths:
        if os.path.exists(path):
            return path
    
    return None

def set_default_shell(pwsh_path):
    """Set PowerShell 7 as default shell using Windows Registry."""
    try:
        # Open or create the OpenSSH key
        key_path = r"SOFTWARE\OpenSSH"
        try:
            key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, key_path, 0, winreg.KEY_ALL_ACCESS)
        except OSError:
            # Create key if it doesn't exist
            key = winreg.CreateKey(winreg.HKEY_LOCAL_MACHINE, key_path)

        # Set the DefaultShell value
        winreg.SetValueEx(key, "DefaultShell", 0, winreg.REG_SZ, pwsh_path)
        winreg.CloseKey(key)
        return True

    except Exception as e:
        print(f"{RED}Error modifying registry: {str(e)}{RESET}")
        return False

def restart_ssh_service():
    """Restart the SSH service."""
    try:
        os.system('net stop sshd')
        os.system('net start sshd')
        return True
    except Exception as e:
        print(f"{RED}Error restarting SSH service: {str(e)}{RESET}")
        return False

def main():
    # Check if running on Windows
    if platform.system() != "Windows":
        print(f"{RED}This script only works on Windows systems{RESET}")
        sys.exit(1)

    # Check for admin privileges
    if not is_admin():
        print(f"{RED}This script requires administrative privileges{RESET}")
        sys.exit(1)

    # Find PowerShell 7 path
    print(f"{BLUE}Looking for PowerShell 7 installation...{RESET}")
    pwsh_path = find_pwsh_path()
    
    if not pwsh_path:
        print(f"{RED}PowerShell 7 not found. Please install it first.{RESET}")
        sys.exit(1)
    
    print(f"{GREEN}Found PowerShell 7 at: {pwsh_path}{RESET}")

    # Set default shell in registry
    print(f"{BLUE}Setting PowerShell 7 as default SSH shell in registry...{RESET}")
    if set_default_shell(pwsh_path):
        print(f"{GREEN}Successfully set PowerShell 7 as default SSH shell{RESET}")
    else:
        print(f"{RED}Failed to set default SSH shell{RESET}")
        sys.exit(1)

    # Restart SSH service
    print(f"{BLUE}Restarting SSH service...{RESET}")
    if restart_ssh_service():
        print(f"{GREEN}SSH service restarted successfully{RESET}")
        print(f"{GREEN}PowerShell 7 is now set as the default SSH shell{RESET}")
    else:
        print(f"{RED}Failed to restart SSH service{RESET}")
        sys.exit(1)

if __name__ == "__main__":
    main()