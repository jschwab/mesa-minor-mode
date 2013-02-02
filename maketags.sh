#!/bin/bash

TAGSPATH=$MESA_DIR/star/defaults
etags --language=none --regex='/[ \t]+\([^ \t]+\)[ \t]*=/\1/' -o $TAGSPATH/TAGS $TAGSPATH/*.defaults
