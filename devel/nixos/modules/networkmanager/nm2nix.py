#!/usr/bin/env python

import sys
from pathlib import Path
from configparser import ConfigParser

infile = Path(sys.argv[1])
parser = ConfigParser()
parser.read(infile)
name = infile.stem
print("# secrets via: https://search.nixos.org/options?channel=unstable&show=networking.networkmanager.ensureProfiles.environmentFiles&query=networkmanager.ensureProfiles")
print(f'{{ wifi ? "", ethernet ? "" }}: {{\n  "{name}" = {{')
for section in parser.sections():
    print(f'    {section} = {{')
    for key, val in parser.items(section):
        if key == "psk" and section == "wifi-security":
            sys.stderr.write(f"{name}_secret='{val}'\n")
            val = f"\\${{{name}_secret}}"
        elif key == "password" and section == "802-1x":
            sys.stderr.write(f"{name}_secret='{val}'\n")
            val = f"\\${{{name}_secret}}"
        elif key == "interface-name" and section == "connection":
            iface = "wifi" if parser[section].get("type") == "wifi" else "ethernet"
            val = f"${{{iface}}}"
        elif any(x in key for x in ["token", "secret", "password", "private"]):
            sys.stderr.write(f"{name}_secret='{val}'\n")
            val = f"\\${{{name}_secret}}"
        print(f'      {key} = "{val}";')
    print("    };")
print("  };\n}")

