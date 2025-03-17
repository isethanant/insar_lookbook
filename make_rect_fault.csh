#!/bin/csh -f

###########
# Calculate coordinates of the surface projection of a rectangular fault plane for gmt plot -Sj
# Written by: Israporn Sethanant
# Date first created: September 9, 2022
# Date last modified: May 29, 2024

###########
# Set up variables to match the "plot_intf_by_rake.csh" code
set dir_oksar = {$1}
set rake = {$2}
set dip = {$3}
set strike = {$4}

###########

# Read in fault parameters from Oksar.inp file 
set fault_x = `awk ' NR==36 {print $1/1000}' $dir_oksar*'oksar3_'*$rake'-'$dip*.inp`  #coord of the center of the fault line
set fault_y = `awk ' NR==36 {print $2/1000}' $dir_oksar*'oksar3_'*$rake'-'$dip*.inp`
set td = `awk ' NR==39 {print $2}' $dir_oksar*'oksar3_'*$rake'-'$dip*.inp`
set bd = `awk ' NR==39 {print $3}' $dir_oksar*'oksar3_'*$rake'-'$dip*.inp`
set length = `awk ' NR==39 {print $1}' $dir_oksar*'oksar3_'*$rake'-'$dip*.inp`
set slip = `awk ' NR==38 {print $1}' $dir_oksar*'oksar3_'*$rake'-'$dip*.inp`
echo "################### Oksar uniform slip value is " $slip


###########
# Step 1 Calculate width/2 (distance between old and new coordinates)
# Find tan(dip); dip in degrees
set tandip = `echo $dip | gmt math STDIN TAND =` #gmt math--needed to add -Tmin/max/inc (-T0/1/1) to create an array; gmt math doesn't recognize one number I think? -- could get away with "echo XX | gmt math STDIN"

# Calculate width/2 to find rectangle center
set bdtd = `echo $bd | gmt math STDIN $td SUB =`	#May 9--corrected width considering top depth
set halfwidth = `echo $bdtd | gmt math STDIN 2 DIV $tandip DIV =`

# Account for the shift due to top depth not being zero
set tdshift = `echo $td | gmt math STDIN $tandip DIV =`

# Total distance shift (if top depth is zero, then the amount of shift = halfwidth)
set totalshift = `echo $tdshift | gmt math STDIN $halfwidth ADD =`



###########
# Step 2 Calculate new rectangle x, y
# Find how much x, y needs to shift to get the rectangle center
echo "STEP 2: DOUBLE CHECK---WHETHER STRIKE IS > or < than 90*****************"
echo "Strike value is: " $strike
echo "############## Is strike greater than 90 degrees? Answer: (y/n)"
##set answer = $<
##if ( $answer == "y" ) then
	echo "If strike > 90, then calculate 180-strike"
	# *For Mw 6.2 Sainyabuli, strike is 166.38, greater than 90, so we use 180-strike in the trigonometry
	set strike_reduce = `echo $strike | gmt math 180 STDIN SUB =`
endif


# Find x, y translation distance
set x_shift = `echo $strike_reduce | gmt math STDIN COSD $totalshift MUL =` 
set y_shift = `echo $strike_reduce | gmt math STDIN SIND $totalshift MUL =`


# ***DEPENDS on the strike orientation whether you need to add or subtract the translation distance!
echo "STEP 2: DOUBLE CHECK---WHETHER RECTANGLE X,Y is < or > than fault center*****************"
echo "############## ADD or SUB x, y coordinates? Answer: (ADD/SUB)"
##set answer = $<
set rect_x = `echo $fault_x | gmt math STDIN $x_shift SUB 1000 MUL =` 
set rect_y = `echo $fault_y | gmt math STDIN $y_shift SUB 1000 MUL =`



###########
# Step 3 Calculate rectangle x-, y-dimensions and rotation angle for gmt plot -Sj/J

# For gmt plot -SJazimuth/width in geographical units
set x_dimen = `echo $bdtd | gmt math STDIN $tandip DIV 1000 MUL =`	#multiply 1000 to convert to meters to match gmt -Rbounds units
set y_dimen = `echo $length | awk '{print $1*1000}'`

# Calculate rotation angle for gmt plot -SJ (clockwise from N)
# *But not sure why it initially plotted clockwise from E, so need to subtract 90 degrees
set rotation = `echo $strike | gmt math STDIN 90 SUB =`

# Print everything in a format for gmt plot -SJ: center_x center_y azimuth-east-of-north x-dimension y-dimension
echo $rect_x $rect_y $rotation $x_dimen $y_dimen > 'rectfault_'$rake'-'$dip'-'$strike'.txt'

exit
