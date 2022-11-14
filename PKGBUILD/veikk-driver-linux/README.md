1, Download latest driver from https://veikk.com (Use the redhat link)
2, Move that package into this folder, or copy this PKGBUILD into the package's location
3, Edit the PKGBUILD.
    - Example: your package's name is vktablet-1.2.1-3.x86_64.zip
    - Then your PKGBUILD should look like this
        + pkgname=vktablet
        + pkgver=1.2.1
        + pkgrel=3
        + arch=('x86_64')
4, Run makepkg -si to install package
5, Done
