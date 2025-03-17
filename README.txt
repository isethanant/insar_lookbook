# Written by Israporn Sethanant
# March 17, 2025

We provide the following codes used in generating interferograms in this lookbook:


1. Four fault parameter input files, specific for ascending or descending interferograms (oksar3_asc_template.inp, oksar3_desc_template.inp, oksar3_asc_template_thrust.inp, oksar3_desc_template_thrust.inp). For thrust faulting, top depth is set to 10 km below surface. Other configurations, top depth = 0 km. 


2. Script to generate one interferogram of desired fault parameters:
The script calls oksar3 program (oksar3 can be obtained from COMET), fault input file, and plots up the interferogram using GMT (run_oksar_gmt.csh).
	3.1 Step 1 ***requires user input*** (satellite track, strike, dip, rake, fault bottom depth)
	3.2 Steps 2-5 does not require code adjustment
	3.3 Run program by typing in terminal:  ./run_oksar_gmt.csh


3. Script to generate all interferograms as seen in the lookbook (run_oksar_loop.csh) using Oksar3 program.


4. Script to plot all interferograms by rake using GMT:
The script plots the 12 interferograms in a clock layout (30 degrees strike increment) as seen in the lookbook (plot_intf_by_rake.csh).


5. Script to plot all interferograms by strike using GMT:
The script plots the interferograms of different faulting styles for each strike value (plot_intf_by_strike.csh).


6. Color scale from COMET for plotting up interferograms in phase radians can be obtained from:
https://github.com/comet-licsar/licsar_proc/blob/main/misc/pha.cpt
Cite Watson et al. (2023) for usage.

Watson, C. S., Elliott, J. R., Ebmeier, S. K., Biggs, J., Albino, F., Brown, S. K., Burns, H., Hooper, A., Lazecký, M., Maghsoudi, Y., Rigby, R., and Wright, T. J. Strategies for improving the communication of satellite-derived InSAR data for geohazards through the analysis of Twitter and online data portals. Geoscience Communication, 6(2):75–96, 2023. doi: 10.5194/gc-6-75-2023.


7. Script to plot fault surface projection or rectangular fault plane using GMT (make_rect_fault.csh).