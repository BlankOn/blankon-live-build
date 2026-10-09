# BlankOn live-build testing configuration

The `sinambung-dummy` branch provides a minbase `ci` variant for standalone
`blankon-image-builder` smoke tests. It includes bare live boot essentials, not
a desktop, installer, or firmware extras. Full GNOME configuration lives on
`variant-gnome`.

Keep this repository and `blankon-image-builder` as siblings under `BUILD_LOCAL`.
See the builder README for setup and prerequisites. From the builder repository:

```
./build-iso --local blankon-live-build
./build-iso --remote https://github.com/BlankOn/blankon-live-build.git sinambung-dummy [commit]
```

The `variant` file selects `ci`. Its serial-console boot marker is a userspace
smoke signal, not proof of desktop readiness. Publish this branch before remote
or CI use.
