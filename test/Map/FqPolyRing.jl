function randpoly(R::FqPolyRing, dmax::Int)
  r = R()
  F = base_ring(R)
  d = rand(0:dmax)
  for i = 0:d
    Nemo.setcoeff!(r, i, rand(F))
  end
  return r
end

@testset "Extensions of finite field" begin
  Fp = ResidueRing(FlintZZ, fmpz(2))
  Fpx, x = Fp["x"]
  f = x^3 + x + 1
  Fq = FqFiniteField(f, :$)
  a = gen(Fq)
  Fqy, y = Fq["y"]
  g = y^3 + a*y + a^2
  G, FqytoG = Hecke.field_extension(g)
  @test characteristic(G) == 2
  @test degree(G) == 9
  GtoFqy = inv(FqytoG)

  # Check if FqytoG does something reasonable with constant polynomials
  @test iszero(FqytoG(Fqy(1))^8 - FqytoG(Fqy(1)))
  @test iszero(FqytoG(Fqy(a))^8 - FqytoG(Fqy(a)))
  @test iszero(FqytoG(Fqy(a^2))^8 - FqytoG(Fqy(a^2)))

  # Check if FqytoG is linear
  h1 = randpoly(Fqy, 5)
  h2 = randpoly(Fqy, 5)
  @test mod(h1, g) == GtoFqy(FqytoG(h1))
  @test mod(h2, g) == GtoFqy(FqytoG(h2))
  @test FqytoG(h1 + h2) == FqytoG(h1) + FqytoG(h2)
  @test FqytoG(h1*h2) == FqytoG(h1)*FqytoG(h2)
  @test iszero(FqytoG(Fqy()))
end