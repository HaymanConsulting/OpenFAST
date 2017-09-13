!**********************************************************************************************************************************
! AFI_DriverCode: This code tests a stand-alone version of the AirfoilInfo module
!..................................................................................................................................
! LICENSING
! Copyright (C) 2015  National Renewable Energy Laboratory
!
!    This file is part of UnsteadyAero.
!
! Licensed under the Apache License, Version 2.0 (the "License");
! you may not use this file except in compliance with the License.
! You may obtain a copy of the License at
!
!     http://www.apache.org/licenses/LICENSE-2.0
!
! Unless required by applicable law or agreed to in writing, software
! distributed under the License is distributed on an "AS IS" BASIS,
! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
! See the License for the specific language governing permissions and
! limitations under the License.
!
!**********************************************************************************************************************************


   
   
   
program AFI_Driver

   use NWTC_Library
   use AirfoilInfo
   use AirfoilInfo_Types
#ifdef UNIT_TESTS
   use AirfoilInfo_Unit
#endif  


   implicit none

   
   
   
   
    ! Variables
   
   real(DbKi)  :: dt, t  
   type(AFI_InitInputType)                       :: initInputs           ! Input data for initialization
   type(AFI_ParameterType)                       :: p                    ! Parameters
   
   integer(IntKi)                                :: errStat, errStat2    ! Status of error message
   character(1024)                               :: errMsg, errMsg2      ! Error message if ErrStat /= ErrID_None
   
   character(1024)                               :: outFileName
   integer                                       :: unOutFile
   character(200)                                :: timeFrmt, Frmt 
   CHARACTER(1024)                               :: dvrFilename          ! Filename and path for the driver input file.  This is passed in as a command line argument when running the Driver exe.
   integer                                       :: nSteps
   real(DbKi)                                    :: simTime  
   integer                                       :: nSimSteps
   character(1024)                               :: routineName
   integer                                       :: unEc
   character(200)                                :: git_commit           ! This is the git commit hash and tag associated with the codebase
   integer                                       :: i, j, k, n           ! loop counter
   real(ReKi)                                    :: angleRad, angleDeg, Cl, Cd, Cm, Cpmin
   integer                                       :: tableIndx(5)
   real(ReKi)                                    :: ReVal
      ! Initialize variables  
   errStat     = ErrID_None   
   errMsg      = ''
   unEc        = 0
   routineName = 'AFI_Driver'
   git_commit  = ''



      ! Initialize the NWTC library 
   call NWTC_Init()

   print *, 'Running AFI_Driver version '
   
   
      ! Parse the driver file if one was provided, if not, then set driver parameters using hardcoded values  
   if ( command_argument_count() > 1 ) then
      call print_help()
      stop
   else if ( command_argument_count() == 1 ) then
      
      !call get_command_argument(1, dvrFilename)
      !call ReadDriverInputFile( dvrFilename, dvrInitInp, errStat2, errMsg2 )
      !   call SetErrStat(errStat2, errMsg2, ErrStat, ErrMsg, RoutineName )
      !   if (ErrStat >= AbortErrLev) then
      !      call Cleanup()
      !      stop
      !   end if
    
   
   else ! No argument     
      !dvrInitInp%OutRootName  = '.\TestingUA_Driver'
      
      
      
      InitInputs%FileName      = '.\DU25_A17.dat'   
            ! Establish Initialization input data based on hardcoded airfoil file data
      InitInputs%AFTabMod      =  2  !  "What type of lookup are we doing? [1 = 1D on AoA, 2 = 2D on AoA and Re, 3 = 2D on AoA and UserProp]" -
      InitInputs%InCol_Alfa	 =  1  !  "The column of the coefficient tables that holds the angle of attack"	-
      InitInputs%InCol_Cl	    =  2  !	"The column of the coefficient tables that holds the lift coefficient"	-
      InitInputs%InCol_Cd	    =  3  !	"The column of the coefficient tables that holds the minimum pressure coefficient"	-
      InitInputs%InCol_Cm	    =  4  !  "The column of the coefficient tables that holds the pitching-moment coefficient"	-
      InitInputs%InCol_Cpmin	 =  0  ! 	"The column of the coefficient tables that holds the minimum pressure coefficient"	-

   end if
   
      ! Call AFI_Init to read in and process the airfoil files.
      ! This includes creating the spline coefficients to be used for interpolation.

   call AFI_Init ( InitInputs, p, errStat2, errMsg2, UnEc )
      call SetErrStat(errStat2, errMsg2, ErrStat, ErrMsg, RoutineName )
      if (ErrStat >= AbortErrLev) then
         print *, ErrMsg
         call NormStop()
      end if 
   
   
      ! Let's verify that for each angle in the airfoil file, we get the recorded values of Cl, Cd, and Cm
   !do i = 1, p%Table(1)%NumAlf 
   !   angleRad = p%Table(1)%Alpha(i)
   !   angleDeg = angleRad*R2D
   !   call AFI_ComputeAirfoilCoefs1D( angleRad, p, Cl, Cd, Cm, Cpmin, errStat, errMsg )
   !   write(*,*) angleDeg, Cl, Cd, Cm, Cpmin
   !end do
   
      ! Now let's force the code to interpolate between some values
      ! We will print values that are in the table before and after the requested angle 
      ! so we can see if the interpolation is reasonable
   tableIndx = (/5, 27, 47, 67, 103/)
   do j = 1, 5
      do i = tableIndx(j)-1, tableIndx(j)
         angleRad = p%Table(1)%Alpha(i)
         angleDeg = angleRad*R2D
         call AFI_ComputeAirfoilCoefs1D( angleRad, p, Cl, Cd, Cm, Cpmin, errStat, errMsg )
         write(*,*) angleDeg, Cl, Cd, Cm, Cpmin
      end do
      
      angleRad = 0.5_ReKi*(p%Table(1)%Alpha(tableIndx(j)+1) + p%Table(1)%Alpha(tableIndx(j)))
      angleDeg = angleRad*R2D
      call AFI_ComputeAirfoilCoefs1D( angleRad, p, Cl, Cd, Cm, Cpmin, errStat, errMsg )
      write(*,*) angleDeg, Cl, Cd, Cm, Cpmin
      
      do i = tableIndx(j)+1, tableIndx(j)+2
         angleRad = p%Table(1)%Alpha(i)
         angleDeg = angleRad*R2D
         call AFI_ComputeAirfoilCoefs1D( angleRad, p, Cl, Cd, Cm, Cpmin, errStat, errMsg )
         write(*,*) angleDeg, Cl, Cd, Cm, Cpmin
      end do
      
   end do
   
   
      ! Now let's force the code to interpolate between some values
      ! We will print values that are in the table before and after the requested angle 
      ! so we can see if the interpolation is reasonable
   tableIndx = (/5, 27, 47, 67, 103/)
   ReVal = 0.5_ReKi*(p%Table(2)%Re + p%Table(3)%Re)
   do j = 1, 5
      do i = tableIndx(j)-1, tableIndx(j)
         angleRad = p%Table(1)%Alpha(i)
         angleDeg = angleRad*R2D
         call AFI_ComputeAirfoilCoefs2D( 1, angleRad, ReVal, p, Cl, Cd, Cm, Cpmin, errStat, errMsg )
         write(*,*) angleDeg, Cl, Cd, Cm, Cpmin
      end do
      
      angleRad = 0.5_ReKi*(p%Table(1)%Alpha(tableIndx(j)+1) + p%Table(1)%Alpha(tableIndx(j)))
      angleDeg = angleRad*R2D
      call AFI_ComputeAirfoilCoefs2D( 1, angleRad, ReVal, p, Cl, Cd, Cm, Cpmin, errStat, errMsg )
      write(*,*) angleDeg, Cl, Cd, Cm, Cpmin
      
      do i = tableIndx(j)+1, tableIndx(j)+2
         angleRad = p%Table(1)%Alpha(i)
         angleDeg = angleRad*R2D
         call AFI_ComputeAirfoilCoefs2D( 1, angleRad, ReVal, p, Cl, Cd, Cm, Cpmin, errStat, errMsg )
         write(*,*) angleDeg, Cl, Cd, Cm, Cpmin
      end do
      
   end do
   
   !-------------------------------------------------------------------------------------------------
   ! Close our output file
   !-------------------------------------------------------------------------------------------------
   

   call NormStop()
   
   contains 
   
   subroutine print_help()
    print '(a)', 'usage: '
    print '(a)', ''
    print '(a)', 'AFI_Driver.exe [driverfilename]'
    print '(a)', ''
    print '(a)', 'Where the optional argument, driverfilename, is the name of the AFI driver input file.'
    print '(a)', ''

   end subroutine print_help


end program AFI_Driver

