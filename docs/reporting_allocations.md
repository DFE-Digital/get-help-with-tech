# Reporting allocations

## Code

The code for reporting allocations is defined in `app/services/allocations_exporter.rb`. 

## The "All Allocations" Report

The class above generates what's known as the "all allocations" report. For each school
output is generated for, it shows how many allocations are left (that is, for each school,
the cap minus how many that school's ordered).
