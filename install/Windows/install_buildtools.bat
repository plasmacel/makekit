:: Install Visual Studio 2017 Build Tools
:: https://blogs.msdn.microsoft.com/vcblog/2016/11/16/introducing-the-visual-studio-build-tools/
:: https://stackoverflow.com/a/42697374/2430597

@echo off
vs_buildtools --quiet --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended
:: vswhere -latest -products Microsoft.VisualStudio.Product.BuildTools

echo Visual Studio 2017 Build Tools will be installed to location:
vswhere -latest -products Microsoft.VisualStudio.Product.BuildTools -property installationPath

echo Visual Studio 2017 Build Tools can be invoked from:
vswhere -latest -products Microsoft.VisualStudio.Product.BuildTools -property productPath

:: vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath