# puma-docker Repository Guidance

## Purpose

This repository builds the legacy Docker environment required by PuMA and its
pulsar-processing tools.

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
- Pin moving external repositories and downloads only after compatible commits
  are identified and the image rebuild is verified.
- Replace insecure download practices with integrity-verified artifacts where
  safe alternatives are available.
- Plan a Python 3 image/runtime migration separately. Validate every specialist
  pulsar dependency and compare scientific outputs before changing defaults.
- Document a future `puma_pipe` dispatcher and hourly/several-times-per-day
  scheduling only after the PuMA repository defines the actual dispatcher.
  Scheduling must provide a lock, retries, durable logs, failure alerts, and
  duplicate-observation protection.

## Validation

- Record exact Docker commands, image tags, build outcomes, and resource use.
- Run shell syntax checks and no-port startup checks after startup changes.
- Use the image's Python 2.7 environment to parse and smoke-test legacy PuMA
  scripts.
- A successful image build does not prove scientific correctness. No `.fil`
  input is currently available for end-to-end validation.
