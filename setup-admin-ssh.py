import os
import sys
import stat
from pathlib import Path

# List of public SSH keys to add
PUB_KEYS = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILed5D0PyYn6ivh4rJNBmi6sbIv1updja+7zwAX5C6iU noizrom@gmail.com",
    "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCevu6fUoIkL42Swajl5zYtbErpMMMcuXc38jhzUbiU8MuHpK9+udTbBpm3rQqMM6KsCaPpkztEhOG+13BMwJ8M=",
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCso92w1BEn9jh4eYeXaDij6cbJbLBJvrdyPj6rRZzV7O1zZvtYlDA5KFvdss7DAMvBxQTS+4pIS35uZok63Q7wHYB20sMpOhH5VxUuQIqnDNds5YQCqPE/fqQ+TDrV3LS1j0LzFs8SGDPqQBqO3hlIc1yxCE7u0nGqqK0T2bmVtbmUFq7VuXvawtOOD7VFWJyBifKS5VtcEFnPWafmy11t68FTUrIQfe1Wdp5ETaZWWQ0FyvhL7YgW6zYBlSzwuyLO84ptW6aPF0+IVuI+fkcJX6Z9KEL/EgFDb3WY7JsdwNvcYBhYGEBRH+hKpymA8cBux/475NgE3+ieFWSsfWrU9dVEjNibIZaX9a9m0vg8QQLl1klixqRy5d6/FN9Rzh52150S8e0KtwVvVnsPgBlCFec2jLa2v9L9NNrUS9dr+UbhOMj3G5/88zODvEN4X5W0XbnENrh1QmHuXraQX43ktPsAr5b57arnlih0E2megQ8VjoDc9Q2ibZap8o/nOmE= noizr@DELLPICHU"
]

def get_ssh_path():
    """Get the appropriate SSH directory path based on the operating system."""
    if sys.platform == 'win32':
        programdata = os.environ.get('PROGRAMDATA', 'C:\\ProgramData')
        return os.path.join(programdata, 'ssh')
    else:
        return '/etc/ssh'

def ensure_directory_exists(directory):
    """Create directory if it doesn't exist."""
    os.makedirs(directory, exist_ok=True)

def set_file_permissions(file_path):
    """Set appropriate permissions for the authorized_keys file."""
    if sys.platform == 'win32':
        # On Windows, set appropriate ACLs
        # This requires administrative privileges
        os.chmod(file_path, stat.S_IRUSR | stat.S_IWUSR)  # 600 equivalent
    else:
        # On Unix-like systems, set 600 permissions
        os.chmod(file_path, 0o600)

def main():
    # Get the SSH directory path
    ssh_dir = get_ssh_path()
    ensure_directory_exists(ssh_dir)
    
    # Set the administrators_authorized_keys file path
    auth_keys_path = os.path.join(ssh_dir, 'administrators_authorized_keys')
    
    # Create or append to the authorized_keys file
    try:
        with open(auth_keys_path, 'a') as f:
            for key in PUB_KEYS:
                f.write(f"{key}\n")
        
        # Set proper file permissions
        set_file_permissions(auth_keys_path)
        print(f"Successfully updated {auth_keys_path}")
        
    except PermissionError:
        print("Error: Administrative privileges required to modify the SSH keys file.")
        sys.exit(1)
    except Exception as e:
        print(f"Error updating SSH keys file: {e}")
        sys.exit(1)

if __name__ == "__main__":
    # Check if running with administrative privileges
    if os.name == 'nt':  # Windows
        import ctypes
        if not ctypes.windll.shell32.IsUserAnAdmin():
            print("This script requires administrative privileges. Please run as administrator.")
            sys.exit(1)
    elif os.geteuid() != 0:  # Unix-like systems
        print("This script requires root privileges. Please run with sudo.")
        sys.exit(1)
    
    main()

