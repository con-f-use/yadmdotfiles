#!/bin/bash
# Print ip of moonsoft to stdout and clipboard.

# moonip=$(
#     ssh cudaws ping moon.emea.cuda-inc.com -c 1 2>/dev/null | 
#         grep -Po -m1 '\d{1,3}(\.\d{1,3}){3,3}' )

moonip=$(
    ssh jan@10.17.70.10 ping moon.emea.cuda-inc.com -c 1 2>/dev/null |
        grep -Po -m1 '\d{1,3}(\.\d{1,3}){3,3}' || 
        ssh cudaws ping moon.emea.cuda-inc.com -c 1 2>/dev/null | 
        grep -Po -m1 '\d{1,3}(\.\d{1,3}){3,3}' || exit 1
)

echo "$moonip"
#echo "$moonip" |
#    xsel --clipboard --input

firefox "$moonip" &

