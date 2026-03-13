## Test environments

* local Windows 11 x86_64, R 4.4.2
* Ubuntu 22.04 (GitHub Actions), R 4.4.x (release)
* macOS (GitHub Actions), R 4.4.x (release)
* R-hub: windows-x86_64-devel, ubuntu-gcc-devel

## R CMD check results

0 ERRORs | 0 WARNINGs | 0 NOTEs

## Downstream dependencies

None — this is a new package submission.

## Notes to CRAN maintainers

* This is the first submission of EasyStat to CRAN.
* The package implements an automated statistical analysis and narrative
  reporting pipeline for R. All statistical computations use base-R `stats`
  functions; narrative generation uses only `glue`; visualizations use
  `ggplot2`; Word export uses `flextable` and `officer`.
* No external web services or databases are accessed at runtime.
* All examples run in well under 5 seconds on the test environments above.
