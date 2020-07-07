#!/usr/bin/python2
# coding: UTF-8, break: linux, indent: 4 spaces, lang: python/eng
"""
Download images from given URL files ('-' for standard input) or URLs.

Usage:
    {progname} --help | --version
    {progname} [options] [-v...] (ARGS... | -c [ARGS...])

Options:
    -v --verbose           Specify (multiply) to increase status reporting
    -n --no-download       Simulate downloading without creating any files
    -c --clipboard         Get additional inputs from clipboard
    -p --processes=<int>   Number of processes for downlaod [default: 15]
    -d --maxdepth=<int>    Maximal recursion depth [default: 10]

Examples:
    Get URLs or files paths containing URL lists from clipboard.
        {progname} -c

    Get images in specified gallery and downlad them sequentially.
        {progname} -p 1 'http://myurl.com/some/gallery'

    Get get gallery URLs from another command's output and a file.
        anothercommand | {progname} myurls.txt -
"""

# =======================================================================

from __future__ import division, print_function, unicode_literals
from logging import info, debug, error, warning as warn
import sys, os, re, logging, time
import pyperclip as clp
from docopt import docopt
from bs4 import BeautifulSoup
import multiprocessing

try:  # Python 2.6-2.7
    from HTMLParser import HTMLParser
except ImportError:  # Python 3
    from html.parser import HTMLParser
try:
    from urllib2 import Request, urlopen
except ImportError:
    from urllib.request import Request, urlopen
try:
    from urlparse import urlparse
except ImportError:
    from urllib.parse import urlparse

# =======================================================================

reqhdr = {
    "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.11 "
    "(KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Charset": "ISO-8859-1,utf-8;q=0.7,*;q=0.3",
    "Accept-Encoding": "none",
    "Accept-Language": "en-US,en;q=0.8",
    "Connection": "keep-alive",
}
q = multiprocessing.JoinableQueue()
h = HTMLParser()


def get_urllist(args):
    """Get HTTP(S) URLs from standard input, files or pass them through"""
    for arg in args:
        try:
            with sys.stdin if arg == "-" else open(arg, "r") as urllst:
                for line in urllst:
                    line = line.strip()
                    if line.startswith("http"):
                        yield line
        except IOError:
            typ, val, tb = sys.exc_info()
            if arg.startswith("http"):
                yield arg
            else:
                warn("IOError while reading file '%s': %s", arg, val)


def url_request(url):
    """Retry getting the provided url."""
    for _ in range(5):
        try:
            urlhandle = urlopen(Request(url, headers=reqhdr), timeout=10)
            break
        except Exception:
            typ, val, tb = sys.exc_info()
            warn("Exception '%s' at '%s'. Retrying...", val, url)
            time.sleep(5)
    else:
        raise Exception("Failed after 5 retries")
    return urlhandle


def save_image(img):  # Main worker function for image node
    """Retreive image, append number and save it to a folder"""
    url, nmg, fldr = img  # Url, Number, Path
    for s, r in [
        ("cdn.ampproject.org/i/s/", ""),
        ("data/th/", "data/fu/"),
        ("data/uth/", "data/ufu/"),
        ("image/th/", "image/fl/"),
    ]:
        url = url.replace(s, r)
    try:
        imgRequest = url_request(url)
        imgData = imgRequest.read()
    except:
        print("x")
        return
    # nm = os.path.basename(fldr)
    nm = "_-_".join(path_split(fldr)[-2:])
    debug("%s : %s", fldr, nm)

    fname = fldr + "/" + nm + "-{:0>4}.jpg"
    with open(fname.format(nmg), "wb") as output:
        output.write(imgData)
    print(".", end="")
    sys.stdout.flush()


def path_split(dirname):
    path_split = []
    while True:
        dirname, leaf = os.path.split(dirname)
        if leaf:
            path_split = [leaf] + path_split
        else:
            return path_split


def get_urls(gs, dom):
    """Get list of image urls and prepend domain if missing."""
    urls = [g.get("href") for g in gs("a", class_="c-tile t-hover")]
    urls = [dom + g[1:] if g.startswith("/") else dom + g for g in urls if g]
    return urls


def get_fldr(gs):
    """Get folder name from a BeautifulSoup object."""
    menu = gs.find("div", class_="top-menu-breadcrumb")
    fldr = [i.text for i in menu.findAll("a", href=re.compile("/album/"))]
    if fldr:
        fldr = "/".join(fldr)
    else:
        fldr = re.sub(" \|.*$", "", gs.title.text)
    return h.unescape(fldr)


def is_img(img):
    """Find out if we're an image leaf."""
    return re.search("/\d+$", img)


def get_imgs(gs, dom):
    """Get the appropriate image URLs."""
    # [ 'https:'+i["data-src"] for i in gs('img',{'class':'lazyload','data-src':True}) ]
    imgs = [i["data-src"] for i in gs("img", {"class": "lazyload", "data-src": True})]
    imgs = [dom + i[1:] if i.startswith("/") else i for i in imgs if i]
    return imgs


def get_splits(gs, domain):
    """Find split galaries."""
    ret = []
    fpgs = gs.find_all("div", class_="pagination")
    if fpgs:
        fpgs = fpgs[0]
        curr = fpgs.find_next("span", class_="current")
        curr = int(curr.text) if curr else -1
        debug("curr: " + str(curr))
        if curr == 1:
            try:
                hreflst = fpgs.find_next("span", class_="last").a.get("href")
            except AttributeError:
                warn("No `a` tag found")
                return ret
            lst = re.search("(?<=page=)\d+$", hreflst)
            if lst:
                lst = int(lst.group(0))
            for nbr in range(2, lst + 1):
                newurl = re.sub("(?<=page=)\d+$", str(nbr), hreflst)
                newurl = (
                    domain + newurl[1:] if newurl.startswith("/") else gomain + newurl
                )
                debug("newurl: " + newurl)
                ret.append(newurl)
    return ret


def walk_urls(url, maxdepth=10, nodl=False, lvl=0):
    """Recursively walk URLs until we find images."""

    # Exit when too deep or URL not readble.
    imgcnt = 0
    if lvl >= maxdepth:
        warn("Stop at '%s' because maxdepth (%i) reached", url, maxdepth)
        return imgcnt
    try:
        urlhandel = url_request(url).read()
    except Exception:
        typ, val, tb = sys.exc_info()
        warn(val)
        return imgcnt

    # Get page and look for links further down the stream
    gs = BeautifulSoup(urlhandel, "lxml")
    domain = "{uri.scheme}://{uri.netloc}/".format(uri=urlparse(url))
    urls = get_urls(gs, domain)
    print("\r" + "\t" * lvl + h.unescape(gs.title.text))
    if not urls:
        return 0

    img_urls = set(filter(is_img, urls))
    other_urls = set(urls) - img_urls

    if img_urls:
        # Look for images and schedule download.
        debug("at least one image found")
        imgs = get_imgs(gs, domain)
        debug(imgs)
        fldr = get_fldr(gs)
        if not os.path.exists(fldr) and not nodl:
            os.makedirs(fldr)
        for img in imgs:
            if nodl:
                print("\t" * lvl, img)
            else:
                q.put((img, imgcnt, fldr))
            imgcnt += 1

    for g in get_splits(gs, domain) + list(other_urls):
        debug("gallery: %s", g)
        imgcnt += walk_urls(g, maxdepth, nodl, lvl + 1)

    return imgcnt


def worker():
    """Handle worker in the global queue."""
    for item in iter(q.get, None):
        save_image(item)
        q.task_done()
    q.task_done()


def queue_download(args):
    """Retrieve images from galaries."""

    # Setup worker processes in Queue
    num_procs = int(args["--processes"])
    procs = []
    for i in range(num_procs):
        procs.append(multiprocessing.Process(target=worker))
        procs[-1].daemon = True
        procs[-1].start()

    # Add to download queue
    print("Getting Image List...")
    totimgs = 0
    for gal in get_urllist(args["ARGS"]):
        totimgs += walk_urls(gal, int(args["--maxdepth"]), args["--no-download"])

    # Status update
    while q.qsize() > 0:
        time.sleep(1)
        progress = 100.0 * (1 - q.qsize() / totimgs)
        print("\r{:.2f}% done".format(progress), end="")
        sys.stdout.flush()
    print("100% done.")
    q.join()

    # Cleanup
    for p in procs:
        q.put(None)  # Make sure the worker loop terminates
    q.join()
    for p in procs:
        p.join()  # Terminate processes
    print("\nFinished everything ({} images downloaded).".format(totimgs))


if __name__ == "__main__":
    progname = os.path.splitext(os.path.basename(__file__))[0]
    vstring = (
        " v0.8.5\nWritten by confus\n" "(Sun Aug 21 23:20:09 CEST 2016) on confusion"
    )
    args = docopt(__doc__.format(**locals()), version=progname + vstring)
    logging.basicConfig(
        level=logging.ERROR - int(args["--verbose"]) * 10,
        format="[%(levelname)-7.7s] (%(asctime)s "
        "%(filename)s:%(lineno)s) %(message)s",
        datefmt="%y%m%d %H:%M",  # , stream=, mode=, filename=
    )
    if args["--clipboard"]:
        args["ARGS"].extend(clp.paste().splitlines())
    if os.getcwd() == os.path.expanduser("~"):
        print("Not in home directory!")
        sys.exit(1)
    queue_download(args)
