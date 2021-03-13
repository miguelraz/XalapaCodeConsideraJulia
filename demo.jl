using PyCall
using Test
using BenchmarkTools
using LinuxPerf
using Debugger

# Puedo llamar funciones de python nativamente
# INTEROP Y TESTING
py"print('hello')"

3+3

asdfiasdff(x) = x^2

# O de cualquier paqueteria en mi ambiente
py"""
import getsizeof from sys

getsizeof(1)
"""

math = pyimport("math")
pysin = math.sin(math.pi / 4)
sin(π/4)


# TESTING!
@testset "python vs Julia" begin
    θ₁ = π/4
    θ₂ = math.pi/4
    @test sin(θ₁) ≈ pysin(θ₂)
    @test_broken 1 == 2
    @test 2 == 3

    @testset "Yay tests" begin
        @test 2 == 2
        @test 1 == 0
    end

    @testset "Super tests" begin
        @test 1 == 2
        @test 1 == 1
    end
end

# INSPECCION Y EL JIT!
function mysum(xs)
    res = 0
    for i in xs
        res += i
    end
    res
end

@code_warntype mysum(1:100)

function mysum2(xs)
    res = zero(xs)
    for i in xs
        res += i
    end
    res
end

@code_warntype mysum2(rand(Complex64) for i in 1:100)

@benchmark mysum(1:1000000)

@code_lowered mysum(1:100)

@code_warntype mysum(1:100)

@code_llvm mysum(1:100)

@code_native debuginfo=:none mysum(1:100)

xs = rand(100);
@code_native debuginfo=:none mysum(xs)

@pstats mysum(xs)

@btime mysum(xs)

# JIT!
g(x) = x^2

@time g(3)

@time g(3.0)

@time g(3.0 + 1im)

@time g("asdf") # oops!

"abc" * "efg"
# Super bonus: broadcasting

v1 = 1:3

f.(v1)

v2 = ["a" "b" "c"];

f.(v2)

# Ooops Python module
v3 = Any[1, "a", 3.0]

@time f.(v3)

@code_warntype f.(v3)

@code_warntype f.(v2)

@time f.(v2)

# Debugger?
@enter mysum2(1:100)


@testset "vector" begin
    v = Vector{Int}()
    @testset "can't pop when empty" begin
        @test_throws Error pop!(v)
    end  
    @testset "adds one element" begin
        push!(v, 1)
        @test length(v) == 1    
        @testset "adds another element" begin
            push!(v, 1)
            @test length(v) == 2
        end
    end
    @testset "removes - empty" begin
        pop!(v)
        @test isempty(v)
    end
    @test 1 == 1
end
