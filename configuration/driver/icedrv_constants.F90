!=======================================================================
!
! This module defines a variety of physical and numerical constants
! used throughout the ice model 
!
! author Elizabeth C. Hunke, LANL

      module icedrv_constants

      use icedrv_kinds
      use icepack_constants, only: c0, c1, c2, c3, c4, c5, c10, c20, c100, c1000
      use icepack_constants, only: p001, p1, p2, c6, p5, puny, pi
      use icepack_constants, only: secday, dragio, stefan_boltzmann
      use icepack_constants, only: tffresh, Tsmelt, depressT
      use icepack_constants, only: emissivity, vonkar, zref, iceruf, albocn
      use icepack_constants, only: rhoi, rhos, rhow, rhofresh
      use icepack_constants, only: lfresh, lvap, ice_ref_salinity, cp_ice, cp_ocn
      use icepack_constants, only: awtvdr, awtidr, awtvdf, awtidf
      use icepack_constants, only: qqqice, tttice

      implicit none

      !-----------------------------------------------------------------
      ! file units
      !-----------------------------------------------------------------

      integer (kind=int_kind), parameter, public :: &
         ice_stdin  =  5, & ! reserved unit for standard input
         ice_stdout =  6, & ! reserved unit for standard output
         ice_stderr =  6, & ! reserved unit for standard error
         nu_nml     = 10, &          ! unit for namelist
         nu_rst_pointer = 11, &      ! unit for restart pointer file
         nu_restart = 12, &          ! unit for restart file
         nu_dump    = 13, &          ! unit for dump file
         nu_forcing    = 14, &          ! unit for forcing file
         nu_diag    = ice_stdout, &     ! unit for diagnostic output
         nu_diag_out = 100

      !-----------------------------------------------------------------
      ! physical constants
      !-----------------------------------------------------------------

      real (kind=dbl_kind), parameter, public :: &
         omega     = 7.292e-5_dbl_kind   ,&! angular velocity of earth (rad/sec)
         radius    = 6.37e6_dbl_kind       ! earth radius (m)

      real (kind=dbl_kind), parameter, public :: &
         spval_dbl = 1.0e30_dbl_kind    ! special value (double precision)

      real (kind=real_kind), parameter, public :: &
         spval     = 1.0e30_real_kind   ! special value for netCDF output

      ! these are currently set so as to have no effect on the decomposition
      real (kind=dbl_kind), parameter, public :: &
         shlat  =  30.0_dbl_kind   ,&! artificial masking edge (deg)
         nhlat  = -30.0_dbl_kind     ! artificial masking edge (deg)
   
      !-----------------------------------------------------------------
      ! numbers used outside the column package
      !-----------------------------------------------------------------

      real (kind=dbl_kind), parameter, public :: &
        c9   = 9.0_dbl_kind, &
        c12  = 12.0_dbl_kind, &
        c30  = 30.0_dbl_kind, &
        c180 = 180.0_dbl_kind, &
        c360 = 360.0_dbl_kind, &
        c365 = 365.0_dbl_kind, &
	c400 = 400.0_dbl_kind, &
        c3600= 3600.0_dbl_kind, &
        p025 = 0.025_dbl_kind, &
        p166 = c1/c6, &
        p111 = c1/c9, &
        p055 = p111*p5, &
        p027 = p055*p5, &
        p222 = c2/c9, &
        eps13  = 1.0e-13_dbl_kind, &
        eps16  = 1.0e-16_dbl_kind

      !-----------------------------------------------------------------
      ! conversion factors
      !-----------------------------------------------------------------

      real (kind=dbl_kind), parameter, public :: &
        cm_to_m       = 0.01_dbl_kind   ,&! cm to meters
        m_to_cm       = 100._dbl_kind   ,&! meters to cm
        m2_to_km2     = 1.e-6_dbl_kind  ,&! m^2 to km^2
        kg_to_g       = 1000._dbl_kind  ,&! kilograms to grams
        mps_to_cmpdy  = 8.64e6_dbl_kind   ! m per s to cm per day

!=======================================================================

      end module icedrv_constants

!=======================================================================
