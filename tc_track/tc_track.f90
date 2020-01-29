! Program to locate the area of lowest SLP
!
! Joseph B. Zambon
! 1 August 2014

      program tctrack

      use netcdf

      implicit none

! Global variables
      character(len=50) :: infile, outfile
      integer :: fhr, ixx, iyy, itt
      real, allocatable :: lat(:,:,:), lon(:,:,:), savear(:,:)

      call getarg(1,infile)
      call getarg(2,outfile)

      call grid
      call gettrack
      call output

      contains

        subroutine check(status)
          integer, intent ( in) :: status

          if(status /= nf90_noerr      ) then
            print *, trim(nf90_strerror(status))
            stop "Stopped"
          end if
        end subroutine check

        subroutine grid

          CHARACTER(LEN=50) :: xname, yname, tname
          integer ncid, lat_varid, lon_varid
          call check( nf90_open(infile, NF90_NOWRITE, ncid) )
          !Get ixx, iyy dimensions
          call check( nf90_inquire_dimension(ncid,3,xname,ixx) )
          call check( nf90_inquire_dimension(ncid,2,yname,iyy) )
          call check( nf90_inquire_dimension(ncid,4,tname,itt) )
          !print*, ixx, iyy, itt
          allocate(lat(ixx,iyy,itt))
          allocate(lon(ixx,iyy,itt))
          
          !Retrieve lat/lon
            call check( nf90_inq_varid(ncid, "lat", lat_varid) )
            call check( nf90_get_var(ncid, lat_varid,lat) )
              !print*, (lat(1,1,1)),(lat(1,300,1))
            call check( nf90_inq_varid(ncid, "lon", lon_varid) )
            call check( nf90_get_var(ncid, lon_varid,lon) )
              !print*, (lon(1,1,1)),(lon(300,1,1))
            call check( nf90_close(ncid) )

        end subroutine grid

        subroutine gettrack
          integer ncid, t, slp_varid, u10_varid, v10_varid
          real, allocatable :: u10(:,:,:), v10(:,:,:), &
                               m10(:,:,:), slp(:,:,:)
          real :: minloc_loc(itt,2), mslp(itt), mwind(itt)
          integer minloc_slp(2), minlocx(itt)
            allocate(savear(itt,4))
          call check( nf90_open(infile, NF90_WRITE, ncid) )
          call check( nf90_inq_varid(ncid, "u10", u10_varid) )
            allocate(u10(ixx,iyy,itt))
          call check( nf90_get_var(ncid, u10_varid, u10) )
          call check( nf90_inq_varid(ncid, "v10", v10_varid) )
            allocate(v10(ixx,iyy,itt))
          call check( nf90_get_var(ncid, v10_varid, v10) )
          call check( nf90_inq_varid(ncid, "slp", slp_varid) )
            allocate(slp(ixx,iyy,itt))
          call check( nf90_get_var(ncid, slp_varid, slp) )
          call check( nf90_close(ncid) )
            !print*, (slp(1,1,1)),(slp(1,300,1))
            !print*, (slp(300,1,1)),(slp(1,1,85))
            allocate(m10(ixx,iyy,itt))
          m10(:,:,:) = sqrt ( u10(:,:,:)**2 + v10(:,:,:)**2 )
          do t=1, itt;
            minloc_slp(:) = minloc(slp(:,:,t))   ! Find position in grid space
            minloc_loc(t,1) = lat(minloc_slp(1),minloc_slp(2),t) ! Find Lat
            minloc_loc(t,2) = lon(minloc_slp(1),minloc_slp(2),t) ! Find Lon
            mslp(t)  = minval(slp(:,:,t))      ! Find value of min SLP
            mwind(t) = maxval(m10(:,:,t))      ! Find value of max wind
            savear(t,1) = minloc_loc(t,1)
            savear(t,2) = minloc_loc(t,2)
            savear(t,3) = mslp(t)
            savear(t,4) = mwind(t)
            !print*, minloc_loc(t,:), mslp(t), mwind(t)
          enddo
            !print*, savear(:,1), savear(:,2), savear(:,3), savear(:,4)

        end subroutine gettrack

        subroutine output

          integer t

          open(unit=2, file=outfile)
            do t=1,itt;
              write(2,*) savear(t,1),',', savear(t,2),',', savear(t,3),&
                         ',', & savear(t,4)
            enddo
          close(2)

        end subroutine output

      end program



