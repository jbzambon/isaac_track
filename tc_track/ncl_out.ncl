  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

a = addfile("/mnt/home/jbzambon/tc_track/isaac/isaac_wrfout.nc","r")
ncf = addfile("/mnt/home/jbzambon/tc_track/isaac/isaac_ncl.nc","c")

; Export diagnostics to netcdf file
;
;  define dimensions
;
   T = a->T(1,:,:,:)
   b=dimsizes(T) ;
   bottom_top = b(0) ;
   south_north = b(1) ;
   west_east = b(2) ;
   DateStrLen = 19 ;
   time = -1 ; UNLIMITED

dim_names = (/ "bottom_top", "south_north", "west_east", "Time", "DateStrLen" /)
dim_sizes = (/ bottom_top, south_north, west_east, time, DateStrLen /)
dimUnlim = (/ False, False, False, True, False /)
filedimdef( ncf, dim_names, dim_sizes, dimUnlim )

;
; define variables to be input
;
var_names_time = (/ "Times" /)
var_types_time = (/ "character" /)
dim_names_time = (/ "Time", "DateStrLen" /)
filevardef(ncf, var_names_time, var_types_time, dim_names_time)

var_names_3D = (/ "slp", "mdbz", "rh2", "tc2", "td2", "sst", "swdown", "lwdown", "lh", "sh", "lat", "lon", "landmask", "u10", "v10", "hwave", "lwavep", "pwave" , "precip" /)
var_types_3D = (/ "float", "float", "float", "float", "float", "float", "float", "float", "float", "float", "float", "float", "float", "float", "float", "float", "float", "float", "float" /)
dim_names_3D = (/ "Time", "south_north", "west_east" /)
filevardef(ncf, var_names_3D, var_types_3D, dim_names_3D )

;
; find max time
;
maxtime=wrf_user_list_times(a);
ntimes = dimsizes(maxtime);

;create diagnostics array
ar_3d = new( (/ ntimes, south_north, west_east /), float)

;Diagnostics
do time = 0,ntimes-1,1                    ;SLP
  slp = wrf_user_getvar(a,"slp",time)            ; Sea level pressure in hPa
  ar_3d(time,:,:)=slp
end do
ncf->slp = ar_3d

do time = 0,ntimes-1,1                    ;MDBZ
  mdbz = wrf_user_getvar(a,"mdbz",time)          ; Simulated radar refl.
  ar_3d(time,:,:)=mdbz
end do
ncf->mdbz = ar_3d

do time = 0,ntimes-1,1                    ;RH2
  rh2 = wrf_user_getvar(a,"rh2",time)            ; 2m Relative Humidity
  ar_3d(time,:,:)=rh2
end do
ncf->rh2 = ar_3d

do time = 0,ntimes-1,1                    ;TC2
  tc2 = a->T2(time,:,:)                          ; 2m temp (in C)
  ar_3d(time,:,:)=tc2
end do
ncf->tc2 = ar_3d

do time = 0,ntimes-1,1                    ;TD2
  td2 = wrf_user_getvar(a,"td2",time)            ; 2m dewpoint (in C)
  ar_3d(time,:,:)=td2
end do
ncf->td2 = ar_3d

precip_3d = new( (/ ntimes, south_north, west_east /), float)
precip_3d(:,:,:) = a->RAINC(:,:,:) + a->RAINNC(:,:,:) + a->RAINSH(:,:,:)   ; Total precipitation (in mm)
do time = 0,ntimes-1,1                    ;Precip
  if (time.eq.0)
   ar_3d(time,:,:)=(/precip_3d(time,:,:)/)
  else
   ar_3d(time,:,:)=(/precip_3d(time,:,:)/)-(/precip_3d(time-1,:,:)/)
  end if
end do
ncf->precip = ar_3d

ncf->sst = a->SST(:,:,:)
ncf->swdown = a->SWDOWN(:,:,:)
ncf->lwdown = a->GLW(:,:,:)
ncf->lh = a->LH(:,:,:)
ncf->sh = a->HFX(:,:,:)
ncf->lat = a->XLAT(:,:,:)
ncf->lon = a->XLONG(:,:,:)
ncf->landmask = a->LANDMASK(:,:,:)
ncf->u10 = a->U10(:,:,:)
ncf->v10 = a->V10(:,:,:)
ncf->hwave = a->HWAVE(:,:,:)
ncf->lwavep = a->LWAVEP(:,:,:)
ncf->pwave = a->PWAVE(:,:,:)

ncf->Times = a->Times


ncf@title = "WRF diagnostics"


print("Successfully completed NCL")
