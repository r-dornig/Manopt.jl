#
#      Sn - The manifold of the n-dimensional sphere
#  Point is a Point on the n-dimensional sphere.
#
export SnPoint, SnTVector

struct Sphere <: MatrixManifold
  name::String
  dimension::Int
  abbreviation::String
  Sphere(dimension::Int) = new("Sphere",dimension,"S$dimension")
end

struct SnPoint <: MMPoint
  value::Vector
  SnPoint(value::Vector) = new(value)
end

struct SnTVector <: MMTVector
  value::Vector
  base::Nullable{SnPoint}
  SnTVector(value::Vector) = new(value,Nullable{SnPoint}())
  SnTVector(value::Vector,base::SnPoint) = new(value,base)
  SnTVector(value::Vector,base::Nullable{SnPoint}) = new(value,base)
end

function distance(p::SnPoint,q::SnPoint)::Number
  return acos(dot(p.value,q.value))
end

function dot(ξ::SnTVector, ν::SnTVector)::Number
  if sameBase(ξ,ν)
    return dot(ξ.value,ν.value)
  else
    throw(ErrorException("Can't compute dot product of two tangential vectors belonging to
      different tangential spaces."))
  end
end

function exp(p::SnPoint,ξ::SnTVector,t=1.0)::SnPoint
  len = norm(ξ.value)
  if len < eps(Float64)
    return p
  else
    return SnPoint(cos(t*len)*p.value + sin(t*len)/len*ξ.value)
  end
end

function log(p::SnPoint,q::SnPoint,includeBase=false)::SnTVector
  scp = dot(p.value,q.value)
  ξvalue = q.value-scp*p.value
  ξvnorm = norm(ξvalue)
  if (ξvnorm > eps(Float64))
    value = ξvalue*acos(scp)/ξvnorm;
  else
    value = zeros(p.value)
  end
  if includeBase
    return SnTVector(value,p)
  else
    return SnTVector(value)
  end
end
function manifoldDimension(p::SnPoint)::Integer
  return length(p.value)-1
end
function norm(ξ::SnTVector)::Number
  return norm(ξ.value)
end

function show(io::IO, m::SnPoint)
    print(io, "Sn($(m.value))")
end
function show(io::IO, m::SnTVector)
  if !isnull(m.base)
    print(io, "SnT_$(m.base.value)($(m.value))")
  else
    print(io, "SnT($(m.value))")
  end
end
