# [![Packages](https://packages.mocaccino.org/badge/mocaccino-portage-tree "List of packages")](https://packages.mocaccino.org/mocaccino-portage-tree) mocaccino-portage-tree
Mocaccino OS Luet Tree for Gentoo Portage


## Development notes

Generate provides for a package:

```bash
$ DOCKER_HOST=ssh://10.16.0.51 PACK=layers/X make gen-provides
```
