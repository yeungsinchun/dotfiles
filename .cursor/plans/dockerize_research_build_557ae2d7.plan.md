---
name: Dockerize Research Build
overview: Containerize the reproducible headless C++ workflow and benchmark dependencies while keeping native GUI and platform-specific builds outside Docker.
todos:
  - id: docker-headless
    content: Add a reproducible Linux Docker image for headless build and benchmark dependencies.
    status: pending
  - id: docker-docs
    content: Document Docker usage, mounts, architecture choices, credentials, and GUI limitations in README.md.
    status: pending
  - id: platform-ci
    content: Add native platform CI guidance or workflows for macOS and Windows builds.
    status: pending
  - id: docker-verify
    content: Build the image and verify headless simplify execution with a mounted dataset fixture.
    status: pending
isProject: false
---

# Dockerize Research Build

- Add a Linux-based `Dockerfile` for the headless `simplify` and `simplify_with_time` targets, installing CMake, CGAL, Qt6 Core, Python, Julia, and the Frechet dependency.
- Keep dataset files, normalized `data/`, benchmark results, and build outputs outside the image through documented bind mounts or named volumes; do not bake Kaggle credentials or T-Drive data into the image.
- Add a concise README section covering `docker build`, headless execution, benchmark usage, Apple Silicon architecture selection, and the limitation that the Qt GUI remains a native desktop workflow.
- Use GitHub Actions for native Windows and macOS validation rather than trying to produce native Windows/macOS binaries from a Linux container. A Windows container image would require a Windows builder/host or remote builder.