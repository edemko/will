# Revision history for Compiler Pipeline: Token Stream Specification

## 0.2.0 -- ????-??-??

* New library management.
  Multiple libraries can now be installed.
  When commands are run against a package, a folder of libraries is searched, and the first library containing the requested package is used.
  The config file will allow you to specify the name of the library as installed.
  I suggest giving a numerical prefix to ensure that libraries are layered as expected (earliest alphabetically takes precedence).

## 0.1.0 -- 2021-03-7

* Released on an unsuspecting world.
