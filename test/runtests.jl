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
    function test_1D(a)
        for ord in 1:length(a)
            index = ord - 1 + firstindex(a)
            @test a[ord*th] == a[index]
            @test a[begin:(ord*th)] == a[begin:index]
            @test a[(ord*th):end] == a[index:end]
            @test a[begin:2:(ord*th)] == a[begin:2:index]
            @test a[(ord*th):2:end] == a[index:2:end]
        end
    end
    @testset "arrays" begin
        for a in Any[rand(10), rand(10, 10), rand(10, 3, 3)]
            test_1D(a)
        end
    end
    @testset "OffsetArrays" begin
        for a in Any[rand(10), rand(10, 10), rand(10, 3, 3)]
            b = OffsetArray(a, [2 for _ in 1:ndims(a)]...)
            test_1D(b)
        end
    end
end
