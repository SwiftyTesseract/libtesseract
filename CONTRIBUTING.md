# Contributing to libtesseract

The libtesseract repo is merely a collection of build scripts to compile and distribute [Tesseract](https://github.com/tesseract-ocr/tesseract) and it's dependencies to be consumed as an xcframework for Apple platforms. If you have an issue or bug report related to the actual behavior of the library, you should open it on the [Tesseract issue tracker](https://github.com/tesseract-ocr/tesseract/issues/new). 

That being said, if you have an issue and believe it's related to how the project is built, please follow the guidelines below.

## Pull Requests
Pull requests are the preferred method of contributing.
* **Completely** fill out the pull request template with all the requested information.
* Validate your changes by ensuring the library can still be imported and compiled for iOS (arm64, x86_64 simulator, and x86_64 catalyst) and macOS (x86_64).
* If you are adding something new (like libgif or libwebp support), either provide an example project showing it in action or explicit instructions to validate the changes.

## Opening Issues
While pull requests are preferred, opening issues is permitted given the following guidance:
* **Completely** fill out the issue template with all the requested information. Any issue without the template filled out completely will be rejected and closed without review.
* **Do not** open an issue to report a bug regarding runtime behavior of Tesseract or it's dependencies. A full list of dependencies is listed at the bottom of the [README](README.md)

## Failing to Follow the Guidelines
I'm very passionate about open source software. I love to share things that I've found useful for myself with the rest of the community and I enjoy contributing to other projects. 

One thing that I lack, however, is an abundance of free time. These guidelines have been established so that no unneccessary back and forth is needed to review and validate any contributions.

Failure to abide by these guidelines will result in your contribution being rejected without comment. Repeat offenders failures be banned from contributing to the project.