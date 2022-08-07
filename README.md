# OrdinalIndexing

[![CI](https://github.com/jishnub/OrdinalIndexing.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/jishnub/OrdinalIndexing.jl/actions/workflows/ci.yml)

## API

This package exports the constants `th`, `st`, `nd` and `rd`, that may be multiplied to integers to construct ordinal numbers. These may subsequently be used in indexing.
```julia
julia> 2nd
2nd

julia> n = 2
2

julia> n * th
2nd
```

## How to use the package

This package allows one to index an array by using ordinal numbers, that is the rank of an index rather than its value. This is best explained through an example:
```julia
julia> using OrdinalIndexing, OffsetArrays

julia> a = 1:10
1:10

julia> a[2nd]
2

julia> b = OffsetArray(a, -10)
1:10 with indices -9:0

julia> b[2nd]
2
```
In this example, we aceess the `2nd` index of the array directly, instead of the conventional way to do this: `a[begin - 1 + 2]`. The general way to access the n-th element of an array using this package is `a[n*th]`. We may use this in Cartesian indexing as well, for example as
```julia
julia> a = reshape(1:9, 3, 3)
3×3 reshape(::UnitRange{Int64}, 3, 3) with eltype Int64:
 1  4  7
 2  5  8
 3  6  9

julia> a[2nd, 3rd]
8
```
This often makes writing loops over arrays easier. For example, to sum an `n x n` block of an array starting from the first element, we may use
```julia
julia> f(a, n) = sum(a[i, j] for i in axes(a, 1)[begin .+ (0:n-1)], j in axes(a,2)[begin .+ (0:n-1)])
f (generic function with 1 method)

julia> f(a, 2)
12
```
Using this package, we may express the function as
```julia
julia> g(a, n) = sum(a[i, j] for i in (1:n)th, j in (1:n)th)
g (generic function with 1 method)

julia> g(a, 2)
12
```
This works correctly for `OffsetArrays` as well:
```julia
julia> b = OffsetArray(a, -10, -20);

julia> f(a, 2) == g(a, 2)
true
```
We may also index into the axes first, instead of indexing into the array directly, which will be faster:
```julia
julia> h(a, n) = sum(a[i, j] for i in axes(a, 1)[(1:n)th], j in axes(a,2)[(1:n)th])
h (generic function with 1 method)

julia> a = collect(reshape(1:100^2, 100, 100));

julia> @btime f($a, 50)
  3.599 μs (0 allocations: 0 bytes)
6188750

julia> @btime g($a, 50)
  4.655 μs (0 allocations: 0 bytes)
6188750

julia> @btime h($a, 50)
  3.615 μs (0 allocations: 0 bytes)
6188750

julia> b = OffsetArray(a, -10, -20);

julia> f(b, 50) == g(b, 50) == h(b, 50)
true
```

## Installation

The package isn't registered yet, so install it using
```julia
julia> import Pkg

julia> Pkg.pkg"add https://github.com/jishnub/OrdinalIndexing.jl/"
```
