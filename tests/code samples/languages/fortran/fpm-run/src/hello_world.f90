module hello_world
  implicit none
  private

  public :: say_hello
contains
  subroutine say_hello
    print *, "Hello, hello_world!"
  end subroutine say_hello
end module hello_world
