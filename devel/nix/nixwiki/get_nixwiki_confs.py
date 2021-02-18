#!/usr/bin/env python3

import subprocess, sys

import requests
from bs4 import BeautifulSoup as bs

url = "https://nixos.wiki/wiki/Configuration_Collection"

def sentinel(t):
    return t.name == "table" and t.caption and "system conf" in str(t.caption).lower()


def gitify(s):
    return s.replace("https://", "git@", 1).replace("github.com/", "github.com:", 1).strip("/") + ".git"


def main(url, print_only=False):
    resp = requests.get(url)
    page = bs(resp.text, "html.parser")

    table = page.findAll(sentinel)[0]
    links = table.find_all("a", "external text")
    hrefs = [l["href"] for l in links if l.has_attr("href") and "github" in l["href"]]

    for g in  map(gitify, hrefs):
        _, _, path = g.rpartition(":")
        comps = path.replace("/", "_")[0:-4]
        cmd = f"git clone '{g}' '{comps}'"
        print(cmd)
        if print_only:
            continue
        process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=sys.stdout.buffer, shell=True)
        for line in iter(process.stdout.readline, b''):  # replace '' with b'' for Python 3
            print(line)

    return 0


if __name__ == "__main__":
    exit( main(url, "print" in sys.argv) )

"""
#!/bin/sh
git clone 'git@github.com:areina/nixos-config.git' 'areina_nixos-config'
git clone 'git@github.com:barrucadu/nixfiles.git' 'barrucadu_nixfiles'
git clone 'git@github.com:Baughn/machine-config.git' 'Baughn_machine-config'
git clone 'git@github.com:bennofs/etc-nixos.git' 'bennofs_etc-nixos'
git clone 'git@github.com:coreyoconnor/nix_configs.git' 'coreyoconnor_nix_configs'
git clone 'git@github.com:CrazedProgrammer/nix.git' 'CrazedProgrammer_nix'
git clone 'git@github.com:davidak/nixos-config.git' 'davidak_nixos-config'
git clone 'git@github.com:sjau/nixos.git' 'sjau_nixos'
git clone 'git@github.com:Infinisil/system.git' 'Infinisil_system'
git clone 'git@github.com:ixxie/fluxstack.git' 'ixxie_fluxstack'
git clone 'git@github.com:jwiegley/nix-config.git' 'jwiegley_nix-config'
git clone 'git@github.com:leosbotelho/cartons.git' 'leosbotelho_cartons'
git clone 'git@github.com:Luis-Hebendanz/nix-configs.git' 'Luis-Hebendanz_nix-configs'
git clone 'git@github.com:mogria/nixos-config.git' 'mogria_nixos-config'
git clone 'git@github.com:mxjessie/nixos-configs.git' 'mxjessie_nixos-configs'
git clone 'git@github.com:netcave/nix-files.git' 'netcave_nix-files'
git clone 'git@github.com:nickjanus/nixos-config.git' 'nickjanus_nixos-config'
git clone 'git@github.com:peel/dotfiles/tree/master/nix/.config/nixpkgs.git' 'peel_dotfiles_tree_master_nix_.config_nixpkgs'
git clone 'git@github.com:periklis/nix-config.git' 'periklis_nix-config'
git clone 'git@github.com:prikhi/nixos-config.git' 'prikhi_nixos-config'
git clone 'git@github.com:pSub/configs/tree/master/nixos.git' 'pSub_configs_tree_master_nixos'
git clone 'git@github.com:rasendubi/dotfiles.git' 'rasendubi_dotfiles'
git clone 'git@github.com:sheenobu/nixos.git' 'sheenobu_nixos'
git clone 'git@github.com:snabblab/snabblab-nixos.git' 'snabblab_snabblab-nixos'
git clone 'git@github.com:Synthetica9/configuration.nix.git' 'Synthetica9_configuration.nix'
git clone 'git@github.com:taktoa/server-config.git' 'taktoa_server-config'
git clone 'git@github.com:trishume/nixfiles.git' 'trishume_nixfiles'
git clone 'git@github.com:utdemir/dotfiles.git' 'utdemir_dotfiles'
git clone 'git@github.com:openlab-aux/vuizvui.git' 'openlab-aux_vuizvui'
git clone 'git@github.com:davidtwco/veritas.git' 'davidtwco_veritas'
git clone 'git@github.com:delroth/infra.delroth.net.git' 'delroth_infra'

git clone 'git@github.com:Xe/nixos-configs.git' 'xe_nixos-configs'
git clone 'git@github.com:burke/b.git' 'burke_libbey-b'
git clone 'git@git@github.com:adisbladis/nixconfig.git' 'adam_hose-adisbladis'
git clone 'git@github.com:delroth/infra.delroth.net.git' 'del_roth-infra.delroth.net'
git clone 'ssh://git@stash.cudaops.com:7999/~tmeusburger/infrastructure.git' 'tobi_tmeusburger-infrastructure'
"""

