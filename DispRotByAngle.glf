#
# Copyright 2009 (c) Pointwise, Inc.
# All rights reserved.
# 
# This sample Pointwise script is not supported by Pointwise, Inc.
# It is provided freely for demonstration purposes only.  
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#

package require PWI_Glyph 2

pw::Script loadTk


set invalidColor "#FFCCCC"

set Input(angleX) 0.0
set Input(angleY) 0.0
set Input(angleZ) 0.0
set Input(relative) 0

foreach var [array names Input] {
   set validInput($var) 1
}

########################################################################
# Rotate: callback procedure that applies rotation transforms
########################################################################
proc Rotate { } {
  global Input

  if { 0 == $Input(relative) } {
    pw::Display resetView
  }

  set view [pw::Display getCurrentView]

  # convert Euler angles to Euler axis/angle
  set pi [tcl::mathfunc::acos -1.0]
  set c1 [tcl::mathfunc::cos [expr $Input(angleY) * $pi / 360.0]]
  set s1 [tcl::mathfunc::sin [expr $Input(angleY) * $pi / 360.0]]
  set c2 [tcl::mathfunc::cos [expr $Input(angleZ) * $pi / 360.0]]
  set s2 [tcl::mathfunc::sin [expr $Input(angleZ) * $pi / 360.0]]
  set c3 [tcl::mathfunc::cos [expr $Input(angleX) * $pi / 360.0]]
  set s3 [tcl::mathfunc::sin [expr $Input(angleX) * $pi / 360.0]]
  set c1c2 [expr $c1 * $c2]
  set s1s2 [expr $s1 * $s2]
   
  set rot [::tcl::mathfunc::acos [expr ($c1c2 * $c3) - ($s1s2 * $s3)]]
  set rot [expr 360.0 / $pi * $rot]
  set x [expr ($s1s2 * $c3) + ($c1c2 * $s3)]
  set y [expr ($s1 * $c2 * $c3) + ($c1 * $s2 * $s3)]
  set z [expr ($c1 * $s2 * $c3) - ($s1 * $c2 * $s3)]

  set axis [pwu::Vector3 normalize [list $x $y $z]]

  set view [lreplace $view 2 2 $axis]
  set view [lreplace $view 3 3 $rot]
  pw::Display setCurrentView $view
#puts $view
}

########################################################################
# Clear: resets angles to zero
########################################################################
proc Clear { } {
  global Input

  set Input(angleX) 0.0
  set Input(angleY) 0.0
  set Input(angleZ) 0.0
}

########################################################################
# Validate: validate text field input
########################################################################
proc Validate { w var text action } {
  global invalidColor Input validInput

  # Ignore forced validations
  if {$action == -1} {
    return 1
  }

  set validInput($var) \
    [expr [string is double -strict $text] && abs($text) <= 360.0]

  if $validInput($var) {
    $w configure -bg white
  } else {
    $w configure -bg $invalidColor
  }

  .buttons.apply configure -state normal
  foreach var [array names Input] {
    if {$validInput($var) == 0} {
      .buttons.apply configure -state disabled
      break
    }
  }

  return 1
}

########################################################################
# makeWindow: create the Tk interface
########################################################################
proc makeWindow {} {
  global Input

  wm title . "Set Display Rotation Angle"

  # Create a label for the title
  pack [label .title -text "Body Axis Rotation"] -side top -fill x -pady 5

  # Get the default font and increase the size slightly for the label
  set font [.title cget -font]
  set fontFamily [font actual $font -family]
  set fontSize [font actual $font -size]
  set bigLabelFont [font create -family $fontFamily -weight bold \
    -size [expr {int(1.5 * $fontSize)}]]

  .title configure -font $bigLabelFont

  # Add a separator
  pack [frame .hr1 -height 2 -relief sunken -borderwidth 1] \
    -side top -fill x -expand true

  pack [checkbutton .checkRel -text "Relative to Current" \
    -indicatoron TRUE -variable Input(relative)] -side top -expand false

  # Add a frame to hold the XY, YZ, and ZX buttons
  pack [frame .t] -side top -pady 5

  # 3 entry widgets for X, Y, and Z angles
  grid [label .t.labelX -text "X:" -justify right] -column 0 -row 0 -sticky e
  grid [label .t.labelY -text "Y:" -justify right] -column 0 -row 1 -sticky e
  grid [label .t.labelZ -text "Z:" -justify right] -column 0 -row 2 -sticky e

  grid [entry .t.entryX -width 7 -textvariable Input(angleX) \
    -validate all -vcmd [list Validate %W angleX %P %d]] \
    -column 1 -row 0
  grid [entry .t.entryY -width 7 -textvariable Input(angleY) \
    -validate all -vcmd [list Validate %W angleY %P %d]] \
    -column 1 -row 1
  grid [entry .t.entryZ -width 7 -textvariable Input(angleZ) \
    -validate all -vcmd [list Validate %W angleZ %P %d]] \
    -column 1 -row 2

  # Add another separator
  pack [frame .buttons] -side bottom
  pack [frame .hr2 -height 2 -relief sunken -borderwidth 1] \
    -side bottom -fill x -expand true

  # Close
  pack [button .buttons.close -text "Close" -width 7 -command exit] \
    -side right -pady 5 -padx 5
  # Apply
  pack [button .buttons.apply -text "Apply" -width 7 -command { Rotate }] \
    -side right -pady 5 -padx 5 
  # Reset
  pack [button .buttons.clear -text "Clear" -width 7 -command { Clear }] \
    -side right -pady 5 -padx 5

  pack [label .buttons.logo -image [pwLogo] -bd 0 -relief flat] \
      -side left -padx 5

  bind . <KeyPress-Escape> { .buttons.close invoke }
  bind . <Control-KeyPress-Return> { .buttons.apply invoke }
}

proc pwLogo {} {
  set logoData "
R0lGODlheAAYAIcAAAAAAAICAgUFBQkJCQwMDBERERUVFRkZGRwcHCEhISYmJisrKy0tLTIyMjQ0
NDk5OT09PUFBQUVFRUpKSk1NTVFRUVRUVFpaWlxcXGBgYGVlZWlpaW1tbXFxcXR0dHp6en5+fgBi
qQNkqQVkqQdnrApmpgpnqgpprA5prBFrrRNtrhZvsBhwrxdxsBlxsSJ2syJ3tCR2siZ5tSh6tix8
ti5+uTF+ujCAuDODvjaDvDuGujiFvT6Fuj2HvTyIvkGKvkWJu0yUv2mQrEOKwEWNwkaPxEiNwUqR
xk6Sw06SxU6Uxk+RyVKTxlCUwFKVxVWUwlWWxlKXyFOVzFWWyFaYyFmYx16bwlmZyVicyF2ayFyb
zF2cyV2cz2GaxGSex2GdymGezGOgzGSgyGWgzmihzWmkz22iymyizGmj0Gqk0m2l0HWqz3asznqn
ynuszXKp0XKq1nWp0Xaq1Hes0Xat1Hmt1Xyt0Huw1Xux2IGBgYWFhYqKio6Ojo6Xn5CQkJWVlZiY
mJycnKCgoKCioqKioqSkpKampqmpqaurq62trbGxsbKysrW1tbi4uLq6ur29vYCu0YixzYOw14G0
1oaz14e114K124O03YWz2Ie12oW13Im10o621Ii22oi23Iy32oq52Y252Y+73ZS51Ze81JC625G7
3JG825K83Je72pW93Zq92Zi/35G+4aC90qG+15bA3ZnA3Z7A2pjA4Z/E4qLA2KDF3qTA2qTE3avF
36zG3rLM3aPF4qfJ5KzJ4LPL5LLM5LTO4rbN5bLR6LTR6LXQ6r3T5L3V6cLCwsTExMbGxsvLy8/P
z9HR0dXV1dbW1tjY2Nra2tzc3N7e3sDW5sHV6cTY6MnZ79De7dTg6dTh69Xi7dbj7tni793m7tXj
8Nbk9tjl9N3m9N/p9eHh4eTk5Obm5ujo6Orq6u3t7e7u7uDp8efs8uXs+Ozv8+3z9vDw8PLy8vL0
9/b29vb5+/f6+/j4+Pn6+/r6+vr6/Pn8/fr8/Pv9/vz8/P7+/gAAACH5BAMAAP8ALAAAAAB4ABgA
AAj/AP8JHEiwoMGDCBMqXMiwocOHECNKnEixosWLGDNqZCioo0dC0Q7Sy2btlitisrjpK4io4yF/
yjzKRIZPIDSZOAUVmubxGUF88Aj2K+TxnKKOhfoJdOSxXEF1OXHCi5fnTx5oBgFo3QogwAalAv1V
yyUqFCtVZ2DZceOOIAKtB/pp4Mo1waN/gOjSJXBugFYJBBflIYhsq4F5DLQSmCcwwVZlBZvppQtt
D6M8gUBknQxA879+kXixwtauXbhheFph6dSmnsC3AOLO5TygWV7OAAj8u6A1QEiBEg4PnA2gw7/E
uRn3M7C1WWTcWqHlScahkJ7NkwnE80dqFiVw/Pz5/xMn7MsZLzUsvXoNVy50C7c56y6s1YPNAAAC
CYxXoLdP5IsJtMBWjDwHHTSJ/AENIHsYJMCDD+K31SPymEFLKNeM880xxXxCxhxoUKFJDNv8A5ts
W0EowFYFBFLAizDGmMA//iAnXAdaLaCUIVtFIBCAjP2Do1YNBCnQMwgkqeSSCEjzzyJ/BFJTQfNU
WSU6/Wk1yChjlJKJLcfEgsoaY0ARigxjgKEFJPec6J5WzFQJDwS9xdPQH1sR4k8DWzXijwRbHfKj
YkFO45dWFoCVUTqMMgrNoQD08ckPsaixBRxPKFEDEbEMAYYTSGQRxzpuEueTQBlshc5A6pjj6pQD
wf9DgFYP+MPHVhKQs2Js9gya3EB7cMWBPwL1A8+xyCYLD7EKQSfEF1uMEcsXTiThQhmszBCGC7G0
QAUT1JS61an/pKrVqsBttYxBxDGjzqxd8abVBwMBOZA/xHUmUDQB9OvvvwGYsxBuCNRSxidOwFCH
J5dMgcYJUKjQCwlahDHEL+JqRa65AKD7D6BarVsQM1tpgK9eAjjpa4D3esBVgdFAB4DAzXImiDY5
vCFHESko4cMKSJwAxhgzFLFDHEUYkzEAG6s6EMgAiFzQA4rBIxldExBkr1AcJzBPzNDRnFCKBpTd
gCD/cKKKDFuYQoQVNhhBBSY9TBHCFVW4UMkuSzf/fe7T6h4kyFZ/+BMBXYpoTahB8yiwlSFgdzXA
5JQPIDZCW1FgkDVxgGKCFCywEUQaKNitRA5UXHGFHN30PRDHHkMtNUHzMAcAA/4gwhUCsB63uEF+
bMVB5BVMtFXWBfljBhhgbCFCEyI4EcIRL4ChRgh36LBJPq6j6nS6ISPkslY0wQbAYIr/ahCeWg2f
ufFaIV8QNpeMMAkVlSyRiRNb0DFCFlu4wSlWYaL2mOp13/tY4A7CL63cRQ9aEYBT0seyfsQjHedg
xAG24ofITaBRIGTW2OJ3EH7o4gtfCIETRBAFEYRgC06YAw3CkIqVdK9cCZRdQgCVAKWYwy/FK4i9
3TYQIboE4BmR6wrABBCUmgFAfgXZRxfs4ARPPCEOZJjCHVxABFAA4R3sic2bmIbAv4EvaglJBACu
IxAMAKARBrFXvrhiAX8kEWVNHOETE+IPbzyBCD8oQRZwwIVOyAAXrgkjijRWxo4BLnwIwUcCJvgP
ZShAUfVa3Bz/EpQ70oWJC2mAKDmwEHYAIxhikAQPeOCLdRTEAhGIQKL0IMoGTGMgIBClA9QxkA3U
0hkKgcy9HHEQDcRyAr0ChAWWucwNMIJZ5KilNGvpADtt5JrYzKY2t8nNbnrzm+B8SEAAADs="

  return [image create photo -format GIF -data $logoData]
}

makeWindow
tkwait window .

#
# DISCLAIMER:
# TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, POINTWISE DISCLAIMS
# ALL WARRANTIES, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED
# TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE, WITH REGARD TO THIS SCRIPT.  TO THE MAXIMUM EXTENT PERMITTED 
# BY APPLICABLE LAW, IN NO EVENT SHALL POINTWISE BE LIABLE TO ANY PARTY 
# FOR ANY SPECIAL, INCIDENTAL, INDIRECT, OR CONSEQUENTIAL DAMAGES 
# WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF 
# BUSINESS INFORMATION, OR ANY OTHER PECUNIARY LOSS) ARISING OUT OF THE 
# USE OF OR INABILITY TO USE THIS SCRIPT EVEN IF POINTWISE HAS BEEN 
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGES AND REGARDLESS OF THE 
# FAULT OR NEGLIGENCE OF POINTWISE.
#

