# FlatViews.jl

![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)
[![build](https://github.com/tpapp/FlatViews.jl/workflows/CI/badge.svg)](https://github.com/tpapp/FlatViews.jl/actions?query=workflow%3ACI)
[![codecov.io](http://codecov.io/github/tpapp/FlatViews.jl/coverage.svg?branch=master)](http://codecov.io/github/tpapp/FlatViews.jl?branch=master)
<!-- Documentation -- uncomment or delete as needed -->
<!--
[![Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://tpapp.github.io/FlatViews.jl/stable)
[![Documentation](https://img.shields.io/badge/docs-master-blue.svg)](https://tpapp.github.io/FlatViews.jl/dev)
-->
<!-- Aqua badge, see test/runtests.jl -->
<!-- [![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl) -->

Julia package for flat views of nested collections.  **EXPERIMENTAL**.

## Related packages

Similar packages include [ValueShapes.jl](https://github.com/oschulz/ValueShapes.jl), [https://github.com/JuliaNonconvex/DifferentiableFlatten.jl](DifferentiableFlatten.jl),
[ComponentArrays.jl](https://github.com/jonniedie/ComponentArrays.jl) [if I missed a package, please open an issue/PR adding to this list].

`FlatViews` is different from these because it only flattens when asked to (with `collect`). **FIXME** *expand on this*.
