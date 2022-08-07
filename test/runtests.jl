using OrdinalIndexing
using OffsetArrays
using Test

@testset "OrdinalIndexing.jl" begin
    @testset "ranges" begin
        @test length(2nd:1st) == 0
        @test length(2nd:2nd) == 1
        @test length(2nd:3rd) == 2
        @test length(2nd:1:1st) == 0
        @test length(2nd:1:2nd) == 1
        @test length(2nd:1:3nd) == 2
        @test length(2nd:2:4rd) == 2
    end
    @testset "promotion" begin
        @test [2nd, true*th] == [2nd, 1st]
        @test [2nd, 3] == Any[2nd, 3]
    end
    @testset "broadcasting" begin
        @test (1:3) * th == 1st:3nd
        @test (1:2:3) * th == 1st:2:3nd
    end
    @testset "indexing" begin
        @testset "getindex" begin
            function test_linear(a)
                @test_throws BoundsError a[0*th]
                @test_throws BoundsError a[(length(a)+1)*th]
                for ord in 1:length(a)
                    index = ord - 1 + firstindex(a)
                    @test a[ord*th] == a[index]
                    @test a[begin:(ord*th)] == a[begin:index]
                    @test a[(ord*th):end] == a[index:end]
                    @test a[begin:2:(ord*th)] == a[begin:2:index]
                    @test a[(ord*th):2:end] == a[index:2:end]
                    @test a[[ord*th]] == a[[index]]
                    @test a[[1st, ord*th]] == a[[begin, index]]
                end
            end
            function test_cart(a)
                @test_throws BoundsError a[ntuple(_ -> 0th, ndims(a))...]
                @test_throws BoundsError a[ntuple(n -> (size(a, n) + 1) * th, ndims(a))...]
                for ord in 1:size(a, 1), ind2 in CartesianIndices(axes(a)[2:end])
                    index = ord - 1 + firstindex(a, 1)
                    @test a[ord*th, ind2] == a[index, ind2]
                    @test a[begin:(ord*th), ind2] == a[begin:index, ind2]
                    @test a[(ord*th):end, ind2] == a[index:end, ind2]
                    @test a[begin:2:(ord*th), ind2] == a[begin:2:index, ind2]
                    @test a[(ord*th):2:end, ind2] == a[index:2:end, ind2]
                end
                for ind1 in CartesianIndices(axes(a)[1:end-1]), ord in 1:size(a, ndims(a))
                    index = ord - 1 + firstindex(a, ndims(a))
                    @test a[ind1, ord*th] == a[ind1, index]
                end
                for ordCI in CartesianIndices(map(x -> 1:x, size(a)))
                    ords = Tuple(ordCI)
                    inds = ords .- 1 .+ first.(axes(a))
                    @test a[(ords .* th)...] == a[inds...]
                end
                ord = [1st, 2nd]
                ordinds = ntuple(x -> ord, ndims(a))
                inds = ntuple(n -> Int.(ord) .- 1 .+ firstindex(a, n), ndims(a))
                @test a[ordinds...] == a[inds...]
            end
            @testset "ranges" begin
                @testset for r in Any[3:10, 5:2:111, Base.OneTo(10), Base.IdentityUnitRange(-11:11)]
                    test_linear(r)
                    @test r[1st:3rd] isa AbstractRange
                    @test r[1st:2:5th] isa AbstractRange
                end
            end
            @testset "arrays" begin
                @testset for sz in [(5,), (5, 5), (5, 5, 3)]
                    a = rand(sz...)
                    test_linear(a)
                    test_cart(a)
                end
            end
            @testset "OffsetArrays" begin
                @testset for sz in Any[(5,), (5, 5), (5, 5, 3)]
                    a = rand(sz...)
                    @testset for offsets in Any[ntuple(_->20, ndims(a)), ntuple(_->-100, ndims(a))]
                        b = OffsetArray(a, offsets)
                        test_linear(b)
                        test_cart(b)
                    end
                end
            end
        end
        @testset "view" begin
            function test_linear(a)
                @test_throws BoundsError a[0*th]
                @test_throws BoundsError a[(length(a)+1)*th]
                for ord in 1:length(a)
                    index = ord - 1 + firstindex(a)
                    @test @view(a[ord*th]) == @view(a[index])
                    @test @view(a[begin:(ord*th)]) == @view(a[begin:index])
                    @test @view(a[(ord*th):end]) == @view(a[index:end])
                    @test @view(a[begin:2:(ord*th)]) == @view(a[begin:2:index])
                    @test @view(a[(ord*th):2:end]) == @view(a[index:2:end])
                    @test @view(a[[ord*th]]) == @view(a[[index]])
                    @test @view(a[[1st, ord*th]]) == @view(a[[begin, index]])
                end
            end
            @testset for r in Any[3:10, 5:2:111, Base.OneTo(10), Base.IdentityUnitRange(-11:11)]
                test_linear(r)
                @test @view(r[1st:3rd]) isa AbstractRange
                @test @view(r[1st:2:5th]) isa AbstractRange
            end
            @testset "arrays" begin
                @testset for sz in [(5,), (5, 5), (5, 5, 3)]
                    a = rand(sz...)
                    test_linear(a)
                end
            end
        end
    end
end
