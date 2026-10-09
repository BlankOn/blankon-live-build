# BlankOn live-build testing configuration

The `dummy-sinambung` branch provides a minimal `ci` variant for testing the
standalone `blankon-image-builder`. It is not the full BlankOn desktop or installer
image.
The full GNOME configuration lives on `variant-gnome`.

## Setup and use

Keep the live-build and builder repositories as siblings under `BUILD_LOCAL`;
see the builder repository README for setup and prerequisites:

```
$BUILD_LOCAL/
├── blankon-live-build/
└── blankon-image-builder/
```

Run from the builder repository:

```
./build-iso --local blankon-live-build
./build-iso --remote https://github.com/BlankOn/blankon-live-build.git dummy-sinambung [commit]
```

The `variant` file selects `ci`. The full GNOME configuration is on
`variant-gnome`; publish this local testing branch before using the remote
invocation or CI.
