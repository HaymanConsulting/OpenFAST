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
   
   implicit none

   
   
   
   
    ! Variables
   
   real(DbKi)  :: dt, t
   integer     :: i, j, k, n 
   
   type(AFI_InitInputType)                        :: InitInputs           ! Input data for initialization
   type(AFI_ParameterType)                        :: p                    ! Parameters
   
   integer(IntKi)                                :: ErrStat, errStat2    ! Status of error message
   character(1024)                               :: ErrMsg, errMsg2     ! Error message if ErrStat /= ErrID_None
   
   integer, parameter                            :: NumAFfiles = 1
   character(1024)                               :: afNames(NumAFfiles)
   character(1024)                               :: outFileName
   integer                                       :: unOutFile
   character(200)                                :: TimeFrmt, Frmt 
   CHARACTER(1024)                               :: dvrFilename          ! Filename and path for the driver input file.  This is passed in as a command line argument when running the Driver exe.
   integer                                       :: nSteps
   real(DbKi)                                    :: simTime  
   integer                                       :: nSimSteps
   character(1024)                               :: RoutineName
   integer                                       :: UnEc
   character(200)                                :: git_commit           ! This is the git commit hash and tag associated with the codebase
   
      ! Initialize the NWTC library
   call NWTC_Init()
   
      ! Initialize variables
   ErrMsg      = ''
   ErrStat     = ErrID_None   
   UnEc        = 0
   RoutineName = 'AFI_Driver'
   git_commit  = ''
   
#ifdef GIT_COMMIT_HASH
   git_commit  = GIT_COMMIT_HASH    ! CMake method for obtaining the git hash info
#endif
#ifdef GIT_HASH_FILE
      ! vs-build method for obtaining the git hash info.
      ! This requires setting:
      !   1) GIT_HASH_FILE = '$(ProjectDir)\githash.txt' preprocessor option on this file.
      !   2) Creating a pre-build event on the AFI project file which runs this command: ..\GetGitHash.bat
      !   3) The bat file, GetGitHash.bat, located in the vs-build folder of the openfast repository, which has the git command: git describe --abbrev=8 --dirty --tags
   git_commit  = ReadGitHash(GIT_HASH_FILE, errStat, errMsg)  
#endif

   print *, 'Running AFI_Driver version '//trim(git_commit)
   
      ! Parse the driver file if one was provided, if not, then set driver parameters using hardcoded values
   if ( command_argument_count() > 1 ) then
      call print_help()
      stop
   end if
  
   
      ! Establish initialization inputs which are fixed for the stand-alone driver, but would be
      ! variable for a coupled simulation
   !nNodesPerBlade  = 1 
   !numBlades       = 1
   
      ! Set up initialization data
   !allocate(AFIndx(InitInData%nNodesPerBlade,InitInData%numBlades), STAT = ErrStat)
   !   if ( ErrStat /= 0 ) then
   !      call SetErrStat( ErrID_Fatal, 'Error trying to allocate InitInData%AFIndx.', ErrStat, ErrMsg, 'UnsteadyAeroTest')  
   !      call Cleanup()
   !      stop       
   !   end if
   !
   !allocate(InitInData%c(InitInData%nNodesPerBlade,InitInData%numBlades), STAT = ErrStat)
   !   if ( ErrStat /= 0 ) then
   !      call SetErrStat( ErrID_Fatal, 'Error trying to allocate InitInData%c.', ErrStat, ErrMsg, 'UnsteadyAeroTest')  
   !      call Cleanup()
   !      stop       
   !   end if
   
      
      ! Parse the driver input file and run the simulation based on that file
      
   if ( command_argument_count() == 1 ) then
      
      !call get_command_argument(1, dvrFilename)
      !call ReadDriverInputFile( dvrFilename, dvrInitInp, errStat2, errMsg2 )
      !   call SetErrStat(errStat2, errMsg2, ErrStat, ErrMsg, RoutineName )
      !   if (ErrStat >= AbortErrLev) then
      !      call Cleanup()
      !      stop
      !   end if
    
   
   else
      
      !dvrInitInp%OutRootName  = '.\TestingUA_Driver'
    
      afNames(1)    = 'C:\Dev\OpenFAST\raf-test\openfast\build\reg_tests\glue-codes\fast\5MW_Baseline\Airfoils\DU21_A17a.dat'
      
      
   end if
 
      ! All nodes/blades are using the same 2D airfoil
  
   
   
      ! Initialize the Airfoil Info Params
   !call Init_AFI( NumAFfiles, afNames, .FALSE., .FALSE., AFI_Params, errStat2, errMsg2 )
   !   call SetErrStat( errStat2, errMsg2, ErrStat, ErrMsg, RoutineName )
   !   if ( ErrStat >= AbortErrLev ) then
   !      call Cleanup()
   !      stop
   !   end if
   InitInputs%NumAFfiles = NumAFfiles
   allocate ( InitInputs%FileNames( InitInputs%NumAFfiles ), STAT=ErrStat )
      if ( ErrStat /= 0 ) then
         call SetErrStat( ErrID_Fatal, 'Error trying to allocate AFI_InitInputs%FileNames.', ErrStat, ErrMsg, RoutineName)  
         print *, ErrMsg
         stop       
      end if
   
   
   do i=1,InitInputs%NumAFfiles
      InitInputs%FileNames(i) = afNames(i) !InitInp%AF_File(i)
   end do
   
      ! Set this to 1 to use the UA coefs
   !AFI_InitInputs%UA_Model    = 1
      ! This is the number of columns of coefs in the AOA table: Cl, Cd, Cm, for example, but doesn't include Alpha
   !AFI_InitInputs%NumCoefs    = 3
      !
   InitInputs%InCol_Alfa  = 1
   InitInputs%InCol_Cl    = 2
   InitInputs%InCol_Cd    = 3  
   InitInputs%InCol_Cm    = 0

   
   InitInputs%InCol_Cpmin = 0
   
   !AFI_InitInputs%Flookup     = Flookup

   
   
      ! Call AFI_Init to read in and process the airfoil files.
      ! This includes creating the spline coefficients to be used for interpolation.

   call AFI_Init ( InitInputs, p, errStat2, errMsg2, UnEc )
      call SetErrStat(errStat2, errMsg2, ErrStat, ErrMsg, RoutineName )
      if (ErrStat >= AbortErrLev) then
         print *, ErrMsg
         
      end if 
   
   
  
   
   !-------------------------------------------------------------------------------------------------
   ! Close our output file
   !-------------------------------------------------------------------------------------------------
   

   call NormStop()
   
   contains
   
   function ReadGitHash(fileName, ErrStat, ErrMsg)
      ! Passed variables
      integer(IntKi),     intent(out)     :: ErrStat                             ! Error status

      character(*),       intent(in)      :: fileName                           ! Name of the file containing the primary input data
      character(*),       intent(out)     :: ErrMsg                              ! Error message
      character(200) :: ReadGitHash
         ! Local variables:
      real(ReKi)                    :: TmpAry(3)                                 ! array to help read tower properties table
      integer(IntKi)                :: I                                         ! loop counter
      integer(IntKi)                :: UnIn                                      ! Unit number for reading file
     
      integer(IntKi)                :: ErrStat2, IOS                             ! Temporary Error status
      logical                       :: Echo                                      ! Determines if an echo file should be written
      character(ErrMsgLen)          :: ErrMsg2                                   ! Temporary Error message
      character(1024)               :: PriPath                                   ! Path name of the primary file
      character(1024)               :: FTitle                                    ! "File Title": the 2nd line of the input file, which contains a description of its contents
      character(200)                :: Line                                      ! Temporary storage of a line from the input file (to compare with "default")
      character(*), parameter       :: RoutineName = 'ReadGitHash'
   
      ErrStat = ErrID_None
      ErrMsg  = ''
      ReadGitHash = ''
      ! Get an available unit number for the file.

      CALL GetNewUnit( UnIn, ErrStat2, ErrMsg2 )
         CALL SetErrStat( ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName )

         ! Open the Primary input file.

      CALL OpenFInpFile ( UnIn, fileName, ErrStat2, ErrMsg2 )
         CALL SetErrStat( ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName )
        
         
      CALL ReadVar( UnIn, fileName, ReadGitHash, "HASH", "Git Hash String)", ErrStat2, ErrMsg2, 0)
         CALL SetErrStat( ErrStat2, ErrMsg2, ErrStat, ErrMsg, RoutineName )
         
      IF (UnIn > 0) CLOSE ( UnIn )
      
   end function ReadGitHash
   
   

   
   
   
   subroutine print_help()
    print '(a)', 'usage: '
    print '(a)', ''
    print '(a)', 'AFI_Driver.exe [driverfilename]'
    print '(a)', ''
    print '(a)', 'Where the optional argument, driverfilename, is the name of the AFI driver input file.'
    print '(a)', ''

   end subroutine print_help
   
end program AFI_Driver

