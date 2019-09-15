#!/bin/bash

echo "
    Ctrl + a => Return to the start of the command you’re typing
    Ctrl + e => Go to the end of the command you’re typing
    Ctrl + u => Cut everything before the cursor to a special clipboard
    Ctrl + k => Cut everything after the cursor to a special clipboard
    Ctrl + y => Paste from the special clipboard
    Ctrl + t => Swap the two characters under the cursor
    Ctrl + w => Delete the word / argument left of the cursor
    Ctrl + l => Clear the screen
    Ctrl + d => Logout
    Ctrl + r => reverse history search
    Alt  + f => Move curser one word right (forward)
    Alt  + b => Move curser one word left (back)
    Alt  + . => Repeat last argument
    Ctrl + x => Glob expand a word
    Ctrl + x Ctrl + e => edit long line in vim
    Alt + Ctrl + e => Shell-expand line
    !$ => Last non-command argument
    !^ => First non-command argument
    !* => All non-command arguments
    ^foo^bar => Replace foo by bar in last command
"