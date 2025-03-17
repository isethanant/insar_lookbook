#!/bin/csh -f

###############################################
# This script creates subplots of interferograms of one fixed rake but varying strike values. 
###############################################
# Written by: Israporn Sethanant
# Date first created: April 9, 2024
# Date last modified: March 17,2025
###############################################
# Set paper size, orientation, and map layout
gmt gmtset MAP_FRAME_TYPE = PLAIN
gmt gmtset PS_MEDIA = A2
gmt gmtset PS_PAGE_ORIENTATION = portrait
gmt gmtset COLOR_NAN = white
gmt gmtset MAP_ANNOT_OBLIQUE = 1
gmt gmtset MAP_ANNOT_ORTHO = ver_text
gmt gmtset FONT_ANNOT = 8p
gmt gmtset FONT_LABEL = 8p


###############################################
set dir_asc = "oksar_asc/"
set dir_desc = "oksar_desc/"

set rake = "-135" 	#choose between: 0 45 90 135 180 -45 -90 -135 
set dip = "22.5" 	#need to specify dip angle: 10 22.5 45 67.5 90

set unit = "wrara" #wrara or unwcm
set pdf = "intf_rake""$rake""_"$unit""

set proj = "-JX1.8i" 
set bounds = "-R370000/480000/4370000/4480000"  

if ( $dip == "10" ) then
	set pdf = "intf_rake${rake}_lowangle_${unit}"
	set bounds = ( "-R420000/550000/4360000/4490000" "-R410000/540000/4320000/4450000" "-R400000/530000/4310000/4440000" "-R360000/490000/4300000/4430000" "-R320000/450000/4310000/4440000" "-R310000/440000/4320000/4450000" "-R300000/430000/4360000/4490000" "-R310000/440000/4400000/4530000" "-R320000/450000/4410000/4540000" "-R360000/490000/4420000/4550000" "-R400000/530000/4410000/4540000" "-R410000/540000/4400000/4530000" )

	set lowangle = "yes"
	echo "############################################## Is this a low angle plot?" $lowangle
	echo "############################################## Need to adjust thrustposition variable" 

else if ( $dip == "22.5" ) then
	set lowangle = "oblique" #set this variable to make rectangular fault

endif

set col_offset = '-X1.9i'   #offset column between asc and desc intfs 
set position = ( '-X6.4i -Y20i'  '-X2.1i -Y-1i'   '-X-0.8i -Y-2.1i'  '-X-0.8i -Y-2.1i' '-X-3i -Y-2.1i' '-X-3i -Y-2.1i' '-X-5.9i -Y-1i' '-X-5.9i -Y1i' '-X-3i -Y2.1i' '-X-3i -Y2.1i' '-X-0.8i -Y2.1i' '-X-0.8i -Y2.1i')
set thrustposition = ( '-X6.4i -Y20i'  '-X2.1i -Y-1i'   '-X-0.8i -Y-2.1i'  '-X-0.8i -Y-2.1i' '-X-3i -Y-2.1i' '-X-3i -Y-2.1i' '-X-5.9i -Y-1i' '-X-5.9i -Y1i' '-X-3i -Y2.1i' '-X-3i -Y2.1i' '-X-0.8i -Y2.1i' '-X-0.8i -Y2.1i')


###############################################
if ( $unit == "wrara" ) then
	set cpt = "cpt/phase_wrara_comet.cpt" 

else if ( $unit == "unwcm" ) then
	set cpt = "cpt/phase_unwcm_20_comet.cpt"
	
endif


###############################################
set i = 1
set j = 1

gmt begin $pdf
		
foreach strike ( 0 30 60 90 120 150 180 210 240 270 300 330 )
	gmt grdimage $bounds $proj $dir_asc'asc_'$rake'-'$dip'-'$strike'_'$unit'.grd' -C$cpt $thrustposition[$i]
	gmt basemap -B0
	awk -F"," ' NR==1 {print substr($3,2,11),$4,"\n",$5,substr($6,1,12)}' $dir_asc*$rake'-'$dip'-'$strike'_fault' | gmt plot -W1p -t20
	
	if ( $lowangle == "yes" || $lowangle == "oblique" ) then
	# Make rectangular fault	
	csh make_rect_fault.csh $dir_asc $rake $dip $strike
	gmt plot -SJ 'rectfault_'$rake'-'$dip'-'$strike'.txt' -W1p,3_2 -Vl
	endif

	echo "################ Plotting descending track "
	gmt grdimage $bounds $proj $dir_desc'desc_'$rake'-'$dip'-'$strike'_'$unit'.grd' -C$cpt $col_offset
	gmt basemap -B0 #-LjBC+w20000+o0/0.5c -B0
	awk -F"," ' NR==1 {print substr($3,2,11),$4,"\n",$5,substr($6,1,12)}' $dir_desc*$rake'-'$dip'-'$strike'_fault' | gmt plot -W1p -t20
	
	if ( $lowangle == "yes" || $lowangle == "oblique" ) then
	gmt plot -SJ 'rectfault_'$rake'-'$dip'-'$strike'.txt' -W1p,3_2 -Vl
	endif
	

@ i=$i + 1

@ j=$j + 1

end


if ( $unit == "wrara" ) then
gmt colorbar $bounds[1] $proj -DJTL+o0/1i+w2i/0.25i+h -C$cpt -Bx3.14+l"LOS displacement (radians)"
else if ( $unit == "unwcm" ) then
gmt colorbar $bounds[1] $proj -DJTL+o0/1i+w2i/0.25i+h+e -C$cpt -Ba -Bx+l"LOS displacement (cm)"
endif


gmt end

exit