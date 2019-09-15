#!/usr/bin/python
"""
Reads IR codes from a file and sends them to the "Dangerous Prototypes IRtoy".

Relies on the IRtoy's 'advanced features ""transmit handshake"/"count" and
"notify complete" of the "sampling mode" from later firmwares (>v20).
See:
  http://dangerousprototypes.com/docs/USB_Infrared_Toy

Usage:
  {PROGNAME} --help | --version | --completion-info
  {PROGNAME} [--code-dir=<dir>] [--port=<port>] FILE...
  {PROGNAME} [--code-dir=<dir>] [--port=<port>] {DIR_COMMANDS}

Options:
  -h --help            Show this screen.
  --version            Show version of this script.
  --completion-info    Display info on how to enable TAB completion in Bash.
  -p --port=<port>     Set IRtoy serial port. [default: {DEFAULT_PORT}]
  -c --code-dir=<dir>    Set directory to look for pre-defined IR command files.
                       This takes precendence over files of the same name in
                       '/usr/share/irtoy/codes'. Files in both directories need
                       to end in '.ir' (lower case) to be recognized.
                       [default: {DEFAULT_CDIR}]
  FILE                   A file containing the hex output values of the toy as
                       ASCII string. Text following '#' is ignored in the file,
                       as are white spaces and "\0x" or "0x". File names have
                       precedence over commands from the '--code-dir option'.
"""
completion_info='''
As tool for command line completion use `docopt_wordlist`.
See:
    https://github.com/docopt/docopt.rs

To download and build `docopt-wordlist` (as part of the docopt.rs package) on
Ubuntu 14.04 use the following commands in shell:

# First you will need the Rust programming language (to build cargo):
$ wget https://static.rust-lang.org/dist/rust-nightly-x86_64-unknown-linux-gnu.tar.gz
$ tar xzvf rust-*-unknown-linux-gnu.tar.gz
$ cd rust-*-unknown-linux-gnu
$ sudo checkinstall ./install.sh

# Then you can proceed to install docopt.rs
$ git clone git://github.com/docopt/docopt.rs
$ cd docopt.rs
$ cargo build --release

# Now you can setup tab completion (for bash) with docopt.rs's docpopt_wordlist
$ echo "DOCOPT_WORDLIST_BIN=\"$(pwd)/target/release/docopt-wordlist\"" \
    >> $HOME/.bash_completion
$ echo "source \"$(pwd)/completions/docopt-wordlist.bash\"" \
    >> $HOME/.bash_completion
$ echo "complete -F _docopt_wordlist_commands cargo" \
    >> $HOME/.bash_completion
'''
default_cdir = '$HOME/.config/irtoy/codes/'
default_gdir = '/usr/share/irtoy/codes'
default_port = '/dev/ttyACM0'
buffer_size  = 62

import re, os, sys, time, serial, os.path as op
#from textwrap import fill as Wrap
try:
    from docopt import docopt
except ImportError:
    exit( 'This program requires `docopt` command line option parser.\n'
          'Install:   pip install docopt\n'
          'https://github.com/docopt/docopt' )


def CheckIR(ser, val, expect, succ, err):
    """Error checking for the serial data."""
    if val == expect:
        sys.stdout.write(succ)
    else:
        ser.flush()
        ser.close()
        exit("Error: %s expected!" % err)


def ChunkIR(IRfile):
    """Devide IR sequence into chunks the IRtoy can deal with."""
    with open(IRfile) as myfile:
        IRcode = myfile.read()
    IRcode = re.sub('#.*$|(0|\\0)?x|^[0-9a-fA-F]{8}: |\s','',IRcode, flags=re.M)
     # bytes are represented by 2 characters
    if not re.match("^([0-9a-f]{2})+f{4}$", IRcode, re.I):
        exit("Error: '%s' is not a valid IR code!" % IRfile)
    block_len = buffer_size * 2
    IRcode = [ IRcode[i:i+block_len] for i in range(0, len(IRcode), block_len) ]
    return IRcode, sum([len(x) for x in IRcode])/2


if __name__ == '__main__':
    # Get cdir beforehand
    cdir = [i for i,v in enumerate(sys.argv) if re.match('^(-c|--code-dir)',v)]
    cdir = ' '.join(sys.argv[cdir[0]:cdir[0]+2]) if cdir else '-c'+default_cdir
    cdir = re.match('-?-c(ode-dir)?=? ?(.*)', cdir).group(2)
    cdir = op.expandvars(op.expanduser( cdir if cdir else default_cdir ))

    # Get predefined commands
    fls = [ os.listdir(x) for x in [cdir,default_gdir] if op.isdir(x) ]
    fls = [ op.splitext(x)[0] for y in fls for x in y if x.endswith('.ir') ]
    dir_commands = sorted( list( set(fls) ) )
    # multi-line usage stings not yet supported by docopt_wordlist
    #dir_commands = Wrap(dir_commands, subsequent_indent='    ')
    #dir_commands = re.sub("\| ?\n {4}","\n    | ",dir_commands)
    dir_commands = '( '+ ' | '.join(dir_commands) +' )...'

    # Argument handling
    __doc__ = __doc__.format( PROGNAME=os.path.basename(sys.argv[0]), DEFAULT_CDIR=default_cdir,
        DEFAULT_PORT=default_port, DIR_COMMANDS=dir_commands )
    arguments = docopt(__doc__, version='IRcontrol for IRtoy v 1.0')

    if arguments['--completion-info']:
        print completion_info
        exit(0)

    for i, irfile in enumerate(arguments['FILE']):
        if op.isfile(irfile):
            pass
        elif op.isfile(cdir+'/'+irfile+'.ir'):
            arguments['FILE'][i] = cdir+'/'+ irfile +'.ir'
            arguments['FILE'][i] = re.sub('/+','/', arguments['FILE'][i])
        elif op.isfile(default_gdir+irfile+'.ir'):
            arguments['FILE'][i] = default_gdir+irfile+'.ir'
        else:
            exit("Error: IR command '"+ irfile +"' not found!")


    # Setup IRtoy serial CDC connection (irman compatible)
    try:
        ser = serial.Serial(
            port=arguments['--port'],
            baudrate=9600, # changes/s
            parity=serial.PARITY_NONE,
            bytesize=serial.EIGHTBITS,
            stopbits=serial.STOPBITS_ONE,
            writeTimeout=30, #s
            timeout=30 #s
        )
    except:
        exit("Error: Cannot open serial port '%s'." % arguments['--port'])

    # Enter Sample Mode
    sys.stdout.write("Entering sample mode ")
    ser.flush()
    ser.write("\x00\x00\x00\x00\x00")
    time.sleep(.01)
    ser.write("\x73")
    protocol = ser.read(3)
    CheckIR( ser, protocol, "S01", "with protocol "+ protocol,
        'Different protocol than '+ protocol )
    time.sleep(.01) #s

    # Enable advanced send mode with handshake and count
    sys.stdout.write(" (enhanced)... ")
    ser.write("\x24\x25\x26")
    time.sleep(.01) #s
    print "[ Ok ]"

    for irfile in arguments['FILE']:
        IRchunks, IRlen = ChunkIR(irfile)

        # Send command
        sys.stdout.write("Transmitting ir data (%s) " % irfile)
        ser.write("\x03")
        CheckIR(ser, ser.read(),">", "acknowledged and", "Transmit acknowledge")

        # Send IR data in chunks
        for i, IRchunk in enumerate(IRchunks):
            ser.write( IRchunk.decode('hex') )
            CheckIR(ser,ser.read(),">",", hs %i" % (i+1),"Handshake %i" % (i+1))

        # Check return
        CheckIR( ser, ser.read(), "t"," received (byte count: ", "Byte count" )
        byte = int( ser.read(2).encode('hex'), 16 )
        CheckIR( ser, byte, IRlen, "%i)... " % byte, "Device received %i but %i"
            % (byte,IRlen) )
        CheckIR(ser, ser.read(), "C", "[ Ok ] \n", "Complete reply")
        time.sleep(.01) #s

    # Tidy Up
    ser.flush()
    ser.close()
