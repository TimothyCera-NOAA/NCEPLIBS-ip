! This is a test for the NCEPLBS-ip library.
!
! Kyle Gerheiser June, 2021
program test_vector
#if(LSIZE==4)
  use input_data_mod_grib1_4
  use interp_mod_grib1_4
#elif(LSIZE==D)
  use input_data_mod_grib1_d
  use interp_mod_grib1_d
#elif(LSIZE==8)
  use input_data_mod_grib1_8
  use interp_mod_grib1_8
#endif
  implicit none

  integer :: num_args, len, status
  character(len=32) :: grid_type, interp_opt

  num_args = command_argument_count()
  if (num_args /= 2) then
     print *, "Two command line arguments expected: grid, interpolation scheme"
     error stop
  end if

  call get_command_argument(1, grid_type, len, status)
  call get_command_argument(2, interp_opt, len, status)
  
  call read_vector_input_data()
  call interp_vector(grid_type, interp_opt)
end program test_vector


