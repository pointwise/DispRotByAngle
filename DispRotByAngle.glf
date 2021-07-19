#############################################################################
#
# (C) 2021 Cadence Design Systems, Inc. All rights reserved worldwide.
#
# This sample script is not supported by Cadence Design Systems, Inc.
# It is provided freely for demonstration purposes only.
# SEE THE WARRANTY DISCLAIMER AT THE BOTTOM OF THIS FILE.
#
#############################################################################

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

  pack [label .buttons.logo -image [cadenceLogo] -bd 0 -relief flat] \
      -side left -padx 5

  bind . <KeyPress-Escape> { .buttons.close invoke }
  bind . <Control-KeyPress-Return> { .buttons.apply invoke }
}

proc cadenceLogo {} {
  set logoData "
R0lGODlhgAAYAPQfAI6MjDEtLlFOT8jHx7e2tv39/RYSE/Pz8+Tj46qoqHl3d+vq62ZjY/n4+NT
T0+gXJ/BhbN3d3fzk5vrJzR4aG3Fubz88PVxZWp2cnIOBgiIeH769vtjX2MLBwSMfIP///yH5BA
EAAB8AIf8LeG1wIGRhdGF4bXD/P3hwYWNrZXQgYmVnaW49Iu+7vyIgaWQ9Ilc1TTBNcENlaGlIe
nJlU3pOVGN6a2M5ZCI/PiA8eDp4bXBtdGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1w
dGs9IkFkb2JlIFhNUCBDb3JlIDUuMC1jMDYxIDY0LjE0MDk0OSwgMjAxMC8xMi8wNy0xMDo1Nzo
wMSAgICAgICAgIj48cmRmOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudy5vcmcvMTk5OS8wMi
8yMi1yZGYtc3ludGF4LW5zIyI+IDxyZGY6RGVzY3JpcHRpb24gcmY6YWJvdXQ9IiIg/3htbG5zO
nhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdFJlZj0iaHR0
cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUcGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh
0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0idX
VpZDoxMEJEMkEwOThFODExMUREQTBBQzhBN0JCMEIxNUM4NyB4bXBNTTpEb2N1bWVudElEPSJ4b
XAuZGlkOkIxQjg3MzdFOEI4MTFFQjhEMv81ODVDQTZCRURDQzZBIiB4bXBNTTpJbnN0YW5jZUlE
PSJ4bXAuaWQ6QjFCODczNkZFOEI4MTFFQjhEMjU4NUNBNkJFRENDNkEiIHhtcDpDcmVhdG9yVG9
vbD0iQWRvYmUgSWxsdXN0cmF0b3IgQ0MgMjMuMSAoTWFjaW50b3NoKSI+IDx4bXBNTTpEZXJpZW
RGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6MGE1NjBhMzgtOTJiMi00MjdmLWE4ZmQtM
jQ0NjMzNmNjMWI0IiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOjBhNTYwYTM4LTkyYjItNDL/
N2YtYThkLTI0NDYzMzZjYzFiNCIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g
6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PgH//v38+/r5+Pf29fTz8vHw7+7t7Ovp6Ofm5e
Tj4uHg397d3Nva2djX1tXU09LR0M/OzczLysnIx8bFxMPCwcC/vr28u7q5uLe2tbSzsrGwr66tr
KuqqainpqWko6KhoJ+enZybmpmYl5aVlJOSkZCPjo2Mi4qJiIeGhYSDgoGAf359fHt6eXh3dnV0
c3JxcG9ubWxramloZ2ZlZGNiYWBfXl1cW1pZWFdWVlVUU1JRUE9OTUxLSklIR0ZFRENCQUA/Pj0
8Ozo5ODc2NTQzMjEwLy4tLCsqKSgnJiUkIyIhIB8eHRwbGhkYFxYVFBMSERAPDg0MCwoJCAcGBQ
QDAgEAACwAAAAAgAAYAAAF/uAnjmQpTk+qqpLpvnAsz3RdFgOQHPa5/q1a4UAs9I7IZCmCISQwx
wlkSqUGaRsDxbBQer+zhKPSIYCVWQ33zG4PMINc+5j1rOf4ZCHRwSDyNXV3gIQ0BYcmBQ0NRjBD
CwuMhgcIPB0Gdl0xigcNMoegoT2KkpsNB40yDQkWGhoUES57Fga1FAyajhm1Bk2Ygy4RF1seCjw
vAwYBy8wBxjOzHq8OMA4CWwEAqS4LAVoUWwMul7wUah7HsheYrxQBHpkwWeAGagGeLg717eDE6S
4HaPUzYMYFBi211FzYRuJAAAp2AggwIM5ElgwJElyzowAGAUwQL7iCB4wEgnoU/hRgIJnhxUlpA
SxY8ADRQMsXDSxAdHetYIlkNDMAqJngxS47GESZ6DSiwDUNHvDd0KkhQJcIEOMlGkbhJlAK/0a8
NLDhUDdX914A+AWAkaJEOg0U/ZCgXgCGHxbAS4lXxketJcbO/aCgZi4SC34dK9CKoouxFT8cBNz
Q3K2+I/RVxXfAnIE/JTDUBC1k1S/SJATl+ltSxEcKAlJV2ALFBOTMp8f9ihVjLYUKTa8Z6GBCAF
rMN8Y8zPrZYL2oIy5RHrHr1qlOsw0AePwrsj47HFysrYpcBFcF1w8Mk2ti7wUaDRgg1EISNXVwF
lKpdsEAIj9zNAFnW3e4gecCV7Ft/qKTNP0A2Et7AUIj3ysARLDBaC7MRkF+I+x3wzA08SLiTYER
KMJ3BoR3wzUUvLdJAFBtIWIttZEQIwMzfEXNB2PZJ0J1HIrgIQkFILjBkUgSwFuJdnj3i4pEIlg
eY+Bc0AGSRxLg4zsblkcYODiK0KNzUEk1JAkaCkjDbSc+maE5d20i3HY0zDbdh1vQyWNuJkjXnJ
C/HDbCQeTVwOYHKEJJwmR/wlBYi16KMMBOHTnClZpjmpAYUh0GGoyJMxya6KcBlieIj7IsqB0ji
5iwyyu8ZboigKCd2RRVAUTQyBAugToqXDVhwKpUIxzgyoaacILMc5jQEtkIHLCjwQUMkxhnx5I/
seMBta3cKSk7BghQAQMeqMmkY20amA+zHtDiEwl10dRiBcPoacJr0qjx7Ai+yTjQvk31aws92JZ
Q1070mGsSQsS1uYWiJeDrCkGy+CZvnjFEUME7VaFaQAcXCCDyyBYA3NQGIY8ssgU7vqAxjB4EwA
DEIyxggQAsjxDBzRagKtbGaBXclAMMvNNuBaiGAAA7"

  return [image create photo -format GIF -data $logoData]
}

makeWindow
tkwait window .

#############################################################################
#
# This file is licensed under the Cadence Public License Version 1.0 (the
# "License"), a copy of which is found in the included file named "LICENSE",
# and is distributed "AS IS." TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE
# LAW, CADENCE DISCLAIMS ALL WARRANTIES AND IN NO EVENT SHALL BE LIABLE TO
# ANY PARTY FOR ANY DAMAGES ARISING OUT OF OR RELATING TO USE OF THIS FILE.
# Please see the License for the full text of applicable terms.
#
#############################################################################

