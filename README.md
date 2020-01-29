# isaac_track
Track code for Isaac Ensemble Solutions  
  Joseph B. Zambon  
  jbzambon@ncsu.edu  
  29 January 2020  

	isaac_track.yml       Environment file to clone (e.g. conda env create -f isaac_track.yml)  
	plot_isaac.py         Plotting Python Script (python plot_isaac.py)  
	plot_isaac.ipynb      Plotting Jupyter Notebook (jupyter notebook)  

	data/                         Data folder (NetCDFs and csv's)  
	isaac_besttrack.csv           NHC best track data  
	isaac_coupled_ens_mean.csv    Luke's Coupled ensemble mean track data  
	isaac_uncoupled_track.csv     Joe's WRF-only uncoupled track data  
	isaac_uncoupled_ncl.nc        NCL-derived products from wrfout file (not included)  

	tc_track/             TC Track derivation programs, scripts  
	compile.sh            Compiles tc_track.f90 to tc_track.exe (requires NetCDF libs)  
	ncl_out.ncl           NCL script to derive variables needed by tc_track.exe (lat, lon, u10, v10, slp)  
	tc_track.f90          Fortran program to output CSV of TC Track (lat, lon, slp; hPa, wind; m/s)  
	tc_track.exe          TC Track program executable  (usage: ./tc_track.exe NCL_OUTPUT_FILE CSV_TO_BE_CREATED)  

	images/               Final output images  
	isaac_track.png       Track map output  
	isaac_intensity.png   Intensity (hPa) plot output  
	isaac_strength.png    Strength (m/s) plot output  
