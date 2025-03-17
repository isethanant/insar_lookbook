#!/bin/csh -f

##############
# The code loops the oksar3~.inp file to replace the strike, dip, rake, bottom depth values and creates a new .inp file. Then, it runs the file through Oksar3, then GMT plots the interferograms.
# Date first created: March 18, 2024
# Date last modified: March 17, 2025
##############
# Set GMT paper size, orientation, and map layout
gmt gmtset MAP_FRAME_TYPE = PLAIN
gmt gmtset PS_MEDIA = A4
gmt gmtset PS_PAGE_ORIENTATION = portrait
gmt gmtset COLOR_NAN = white
gmt gmtset MAP_ANNOT_OBLIQUE = 1
gmt gmtset MAP_ANNOT_ORTHO = ver_text

##############
set track = "asc"
set mec = "ss" 	#choose between ss (strike-slip), normal, reverse, thrust, oblique in order to use the corresponding dip angle
set infile = "oksar3_"$track"_template.inp"
set cpt = "cpt/phase_wrara.cpt"

##############

# Step 0: Set up s,d,r,bd parameters to retain fault area of 20 km x 10 km

if ( $mec == "ss" ) then
set r = " 0 "  #180 "
set d = " 90 "
set bd = " 10 "
else if ( $mec == "normal" ) then
set r = " -90 "
set d = " 45 "
set bd = " 7.071067812 " # Trigonometry to get bottom depth for dipping faults; bd = 10km x sin(45)
else if ( $mec == "reverse" ) then
set r = " 90 "
set d = " 45 " 
set bd = " 7.071067812 "
else if ( $mec == "thrust" ) then
set infile = "oksar3_"$track"_template_thrust.inp" 	#Adjust top depth = 10 km
set r = " 90 "
set d = " 10 " 
set bd = " 11.736481777 "		#Adjust bottom depth to be buried below 10 km
else if ( $mec == "oblique" ) then
set r = " 45 135 -45  -135 "
set d = " 67.5 "
set bd = " 9.2387953 "
endif



# Step 1: Print out the oksar3 .inp file

foreach rake ( $r )
echo "###################### Looping through rake:" $rake
perl -p -e 's/rake/'$rake'/g' $infile  >  tempinp1 
#'s'ubstitute original text with replacement text 'g'lobally (on the whole input line); -p loops and prints the text; -e is followed by the one-line command 


	foreach dip ( $d )
	echo "###################### Looping through dip:" $dip
	perl -p -e 's/dip/'$dip'/g' tempinp1  >  tempinp2
	
	
		foreach bottomdepth ( $bd )
		echo "###################### Looping through bottom depth:" $bottomdepth
		perl -p -e 's/bottomdepth/'$bottomdepth'/g' tempinp2  >  tempinp3


			foreach strike ( 0 30 60 90 120 150 180 210 240 270 300 330 ) 
			echo "###################### Looping through strike:" $strike
			perl -p -e 's/strike/'$strike'/g' tempinp3  >  'oksar3_'$track'_'$rake'-'$dip'-'$strike'.inp'
		
	
			# Step 2: Run oksar3 
			oksar3 'oksar3_'$track'_'$rake'-'$dip'-'$strike'.inp'
		

		
			# Step 3: Convert oksar3 .ers --> .grd file
			echo "###################### GMT convert Oksar3 .ers --> .grd for strike/dip/rake:" $strike $dip $rake
			gmt xyz2grd $track'_'$rake'-'$dip'-'$strike'_wrara' -G$track'_'$rake'-'$dip'-'$strike'_wrara.grd' -R350050/500050/4350050/4500050 -I1501+/1501+ -ZTLd
			gmt xyz2grd $track'_'$rake'-'$dip'-'$strike'_unwcm' -G$track'_'$rake'-'$dip'-'$strike'_unwcm.grd' -R350050/500050/4350050/4500050 -I1501+/1501+ -ZTLd	
			
			# Use these bounds for thrusting
			##gmt xyz2grd $track'_'$rake'-'$dip'-'$strike'_wrara' -G$track'_'$rake'-'$dip'-'$strike'_wrara.grd' -R320050/530050/4320050/4530050 -I2101+/2101+ -ZTLd
			##gmt xyz2grd $track'_'$rake'-'$dip'-'$strike'_unwcm' -G$track'_'$rake'-'$dip'-'$strike'_unwcm.grd' -R320050/530050/4320050/4530050 -I2101+/2101+ -ZTLd
			
		
			# Step 4: Plot the interferogram (Do this step if want to plot one interferogram)
			##set pdf = $track'_'$rake'-'$dip'-'$strike'_wrara'
			##echo "###################### Plotting interferogram "
			##gmt begin $pdf
			##gmt basemap -R350050/500050/4350050/4500050 -Y5i -JX8 -Ba -LJBC+w20000+o0/0.5i
			##gmt grdimage $track'_'$rake'-'$dip'-'$strike'_wrara.grd' -C$cpt
			##gmt colorbar -Dx0/-1.5i+w2i/0.25i+h -C$cpt -Bx3.14+l"LOS displacement (radians)"  
			##gmt end


			end
		end	
	end
end

exit
