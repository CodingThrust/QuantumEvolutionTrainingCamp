using Test, RydbergToolkit

@testset "timedependent" begin
    clocks = [0.0, 1.0, 2.0]
    values = [1.0, 2.0, 3.0]
    f = piecewise_linear(clocks, values)
    @test_throws AssertionError piecewise_linear([1.0, 0.0, 2.0], values)
    @test_throws AssertionError piecewise_linear([0.0, 1.0, 2.0, 4.0], values)
    @test f(0.0) == 1.0
    @test f(1.0) == 2.0
    @test f(2.0) == 3.0
    @test f(1.5) == 2.5
end