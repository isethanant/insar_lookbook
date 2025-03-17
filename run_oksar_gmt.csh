#!/bin/csh -f

##############
# In this code "run_oksar_gmt.csh", user manually inputs necessary variables (satellite track, strike, dip, rake, bottom depth) to create a new input (.inp) file. Then, the code calls Oksar3 software (Okada dislocation modelling) to produce a synthetic interferogram, and plots it with the Generic Mapping Tools (GMT).
# Date first created: March 18, 2024
# Date last modified: March 14, 2025
# Written by: Israporn Sethanant 

##############
# Step 1 (REQUIRES USER INPUT)

# Choose satellite track to call the relevant input template file
set track = "asc"	#Enter between "asc" or "desc"

# Set up strike (s), dip (d), rake (r), bottom depth (bd) parameters to retain fault area of 20 km x 10 km

set r = "0"		#User input desired rake angle
set s = "30"		#User input desired strike angle

# User selects one set of dip angle and bottom depth
# COMMENT OUT THE VALUES NOT NEEDED

# Vertical faults
set d = "90"
set bd = "10"

# Dipping 67.5 degrees
##set d = "67.5"
##set bd = "9.2387953"

# Dipping 45 degrees
##set d = "45"
##set bd = "7.071067812" #Trigonometry to get bottom depth for dipping faults; bd = 10km x sin(dip)

# Dipping 22.5 degrees
##set d = "22.5"
##set bd = "3.826834324"

# Dipping 10 degrees
##set d = "10" 
##set bd = "1.736481777"

##############
# Step 2: Print out new input (.inp) file with the selected fault parameters in Step 1

set infile = oksar3_"$track"_template.inp

echo "##### Running perl"
perl -p -e "s/rake/$r/g; s/strike/$s/g; s/dip/$d/g; s/bottomdepth/$bd/g" "$infile" > "oksar3_${track}_${r}-${d}-${s}.inp"

##############
# Step 3: Run Oksar3 to produce interferograms

echo "##### Running Oksar3"
oksar3  "oksar3_${track}_${r}-${d}-${s}.inp"
		
##############
# Step 4: Convert Oksar3 output files (.ers) to .grd format

echo "###################### GMT convert Oksar3 .ers --> .grd for strike/dip/rake:" $s $d $r
gmt xyz2grd $track'_'$r'-'$d'-'$s'_wrara' -G$track'_'$r'-'$d'-'$s'_wrara.grd' -R350050/500050/4350050/4500050 -I1501+/1501+ -ZTLd
gmt xyz2grd $track'_'$r'-'$d'-'$s'_unwcm' -G$track'_'$r'-'$d'-'$s'_unwcm.grd' -R350050/500050/4350050/4500050 -I1501+/1501+ -ZTLd
			
##############
# Step 5: Plot interferograms with GMT

# Set GMT paper size, orientation, and map layout
gmt gmtset MAP_FRAME_TYPE = PLAIN
gmt gmtset PS_MEDIA = A4
gmt gmtset PS_PAGE_ORIENTATION = portrait
gmt gmtset COLOR_NAN = white
gmt gmtset MAP_ANNOT_OBLIQUE = 1
gmt gmtset MAP_ANNOT_ORTHO = ver_text

set cpt = "phase_wrara_comet.cpt"

set pdf = $track'_'$r'-'$d'-'$s'_wrara'

echo "###################### Plotting interferogram "
gmt begin $pdf
	gmt basemap -R350050/500050/4350050/4500050 -Y5i -JX8 -Ba -LJBC+w20000+o0/0.5i
	gmt grdimage $track'_'$r'-'$d'-'$s'_wrara.grd' -C$cpt
	gmt colorbar -Dx0/-1.5i+w2i/0.25i+h -C$cpt -Bx3.14+l"LOS displacement (radians)"  
gmt end


exit
#END OF CODE
