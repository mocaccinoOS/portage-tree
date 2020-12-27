# [![Packages](https://packages.mocaccino.org/badge/mocaccino-portage-tree "List of packages")](https://packages.mocaccino.org/mocaccino-portage-tree) mocaccino-portage-tree
Mocaccino OS Luet Tree for Gentoo Portage


## Development notes

### Generate provides for a package:

First be sure to have `yq`, `jq` and `pkgs-checker` installed ( ```luet install repository/mocaccino-extra-stable``` and ```luet install -y utils/yq utils/jq dev-util/pkgs-checker-minimal``` )


```bash
$ DOCKER_HOST=ssh://10.16.0.51 PACK=layers/X make gen-provides
```

### Inspect docker images from packages

To retrieve the docker images hashes of the packages, you can run:

```bash
$ luet tree images --image-repository quay.io/mocaccinocache/portage-amd64-cache --tree amd64 --tree multi-arch layers/system-x

layer/gentoo-stage3-0.20201125: quay.io/mocaccinocache/portage-amd64-cache:e1eb7be13068a1fb7956b4b68d20e74f9033956b453a2fbc7436e0dab28e50c2
layer/gentoo-portage-0.20201111: quay.io/mocaccinocache/portage-amd64-cache:46d476051855c7e1129e1a99cf8b0a283e1804ff5f5e28eac394731c2cf0c547
development/mocaccino-overlay-x-0.20201125+5: quay.io/mocaccinocache/portage-amd64-cache:34e8cc87db92843bce1027f65d35562831fc535a64705975d4a0231db34b3176
layers/system-x-0.20201125+5: quay.io/mocaccinocache/portage-amd64-cache:14ecb8f06592144484d3a103002894c36c115dd372953399d7afa0ecb05a1f82

```

To run a container for debugging, then you can :

```bash
DOCKER_HOST=ssh://10.16.0.51 docker run --rm -ti quay.io/mocaccinocache/portage-amd64-cache:14ecb8f06592144484d3a103002894c36c115dd372953399d7afa0ecb05a1f82
```
