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
    @testset "indexing" begin
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
end
