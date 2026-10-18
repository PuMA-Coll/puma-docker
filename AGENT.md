# puma-docker Repository Guidance

## Purpose

This repository builds the legacy Docker environment required by PuMA and its
pulsar-processing tools at the Argentinian Institute of Radioastronomy (IAR).
PRESTO performs the principal folding work and Tempo2 produces and analyzes
TOAs.

## Runtime Compatibility

- The image currently targets the legacy Jupyter/Ubuntu stack with Python 2.7
  and Python 3.6 environments plus PRESTO, PSRCHIVE, SIGPROC, Tempo/Tempo2,
  and related scientific software.
- Newer upstream software may work with Python 3, but compatibility with the
  complete PuMA pipeline has not been established. A Python 3 migration is a
  separate upgrade requiring dependency mapping, a new image baseline, and
  scientific regression data.
- Do not upgrade Astropy, NumPy, or the legacy pulsar stack blindly. Existing
  security alerts are documented in the workspace audit and require a
  compatibility and scientific validation plan.

## Working Rules

- Inspect `git status`, branch, and recent history before editing.
- Work on an isolated branch. Do not stage or commit unless explicitly asked.
- Preserve attribution, bundled software licenses, and external source terms.
- Do not publish images, push remotes, expose services publicly, or add
  credentials to the repository.
- Bind local development ports to loopback only. The image is for trusted local
  use and is not a secure untrusted deployment.
- Prefer small Dockerfile and startup changes. Avoid broad dependency or base
  image migrations without a separate plan.

## Current Verified Baseline

- The Docker image builds successfully after the PSRCHIVE C++ compatibility
  fix.
- No-port startup, Python imports, expected pulsar commands, PuMA paths, and
  internal Jupyter startup have been smoke-tested.
- Shell profile destinations and JupyterHub single-user startup have been
  corrected on the agent work.

## Pending Verification and Upgrades

- Revalidate the image against a representative authorized `.fil` through a
  narrow, non-destructive PuMA operation.
- Prefer a short J0835-4510 (Vela) observation for glitch-path validation.
  PRESTO should recover the period independently; an isolated outdated test
  `.par` may then verify that the glitch trigger activates. Do not install the
  outdated file as an operational asset.
- Pin moving external repositories and downloads only after compatible commits
  are identified and the image rebuild is verified.
- Replace insecure download practices with integrity-verified artifacts where
  safe alternatives are available.
- Plan a Python 3 image/runtime migration separately. Validate every specialist
  pulsar dependency and compare scientific outputs before changing defaults.
- Document and schedule `puma_process.py`, the PuMA dispatcher. 
  The current MSPs are J0437-4715 and J2241-5236, routed to
  `pipe_reduc.py`; J1744-1134 and J1810-197 are currently marked non-MSP and
  use `pipe_pugliS.py`. Other J-name pulsars require registry and asset
  verification before use.
  Scheduling should run when the processing system is idle and stable
  observations are waiting. Hourly polling is only an estimate. It must provide
  a lock, input-readiness checks, quarantine, retries, durable logs, failure
  alerts, and duplicate-observation protection.
- Observation folders can appear while multi-GB `.fil` files are still being
  written. Do not treat folder existence as readiness. The scheduler needs an
  acquisition completion signal or a validated file-size/mtime stability
  interval.
- After successful processing and local product publication, raw `.fil` files
  move to a separate Globus staging area. Globus owns transfer verification and
  source-copy retention; do not add competing transfer or deletion behavior to
  the image.
- Pipeline products remain local for the internal website. Operational `.par`
  files and other timing assets may exist on the IAR cluster outside Git.

## Validation

- Record exact Docker commands, image tags, build outcomes, and resource use.
- Run shell syntax checks and no-port startup checks after startup changes.
- Use the image's Python 2.7 environment to parse and smoke-test legacy PuMA
  scripts.
- A successful image build does not prove scientific correctness. No `.fil`
  input is currently available for end-to-end validation.
