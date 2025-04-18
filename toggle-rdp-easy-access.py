import winreg
import platform
import ctypes
import sys
import os
import msvcrt  # For Windows key input

# ANSI Color codes
GREEN = '\033[92m'
RED = '\033[91m'
YELLOW = '\033[93m'
BLUE = '\033[94m'
RESET = '\033[0m'

def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False

def wait_key():
    print(f"\n{YELLOW}Press any key to continue...{RESET}")
    msvcrt.getch()

def elevate():
    if not is_admin():
        wait_key()  # Allow user to read messages before elevation
        # Re-run the program with admin rights
        ctypes.windll.shell32.ShellExecuteW(
            None, 
            "runas", 
            sys.executable, 
            " ".join([sys.argv[0]] + sys.argv[1:]),
            None, 
            1  # SW_SHOWNORMAL
        )
        sys.exit(0)

def get_blank_password_status():
    try:
        key_path = r"SYSTEM\CurrentControlSet\Control\Lsa"
        key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, key_path, 0, winreg.KEY_READ)
        value, _ = winreg.QueryValueEx(key, "LimitBlankPasswordUse")
        winreg.CloseKey(key)
        return value
    except OSError as e:
        print(f"{RED}Error accessing registry: {e}{RESET}")
        return None

def toggle_blank_password():
    try:
        key_path = r"SYSTEM\CurrentControlSet\Control\Lsa"
        key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, key_path, 0, winreg.KEY_ALL_ACCESS)
        current_value, _ = winreg.QueryValueEx(key, "LimitBlankPasswordUse")
        new_value = 0 if current_value == 1 else 1
        winreg.SetValueEx(key, "LimitBlankPasswordUse", 0, winreg.REG_DWORD, new_value)
        winreg.CloseKey(key)
        return new_value
    except OSError as e:
        print(f"{RED}Error modifying registry: {e}{RESET}")
        return None

def main():
    if platform.system() != "Windows":
        print(f"{RED}This script can only run on Windows systems{RESET}")
        sys.exit(1)

    # Check admin status and show current privilege level
    if not is_admin():
        print(f"{YELLOW}Current status: Running without administrator privileges{RESET}")
        print(f"{BLUE}Administrator privileges are required. Requesting elevation...{RESET}")
        elevate()  # This will restart the script with admin rights if needed

    print(f"{BLUE}Checking current LimitBlankPasswordUse status...{RESET}")
    current_status = get_blank_password_status()
    
    if current_status is not None:
        status_text = "ENABLED (blank passwords restricted)" if current_status == 1 else "DISABLED (blank passwords allowed)"
        status_color = GREEN if current_status == 1 else YELLOW
        print(f"Current status: {status_color}{status_text}{RESET}")

        print(f"{BLUE}Toggling LimitBlankPasswordUse...{RESET}")
        new_status = toggle_blank_password()
        
        if new_status is not None:
            new_status_text = "ENABLED (blank passwords restricted)" if new_status == 1 else "DISABLED (blank passwords allowed)"
            new_status_color = GREEN if new_status == 1 else YELLOW
            print(f"New status: {new_status_color}{new_status_text}{RESET}")
            print(f"{GREEN}Operation completed successfully!{RESET}")
    
    # Add final pause to read messages
    wait_key()

if __name__ == "__main__":
    main()