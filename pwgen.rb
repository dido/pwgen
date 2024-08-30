#!/usr/bin/env ruby

def random_bytes(nbytes)
  File.open("/dev/random", "r") do |fp|
    return(fp.read(nbytes))
  end
end

def rand()
  rnd = random_bytes(8)
  rnd = rnd.bytes.to_a
  rval = 0.0
  rnd.each do |val|
    rval = rval/256.0 + val
  end
  return(rval/256.0)
end

def depth(m, d)
  if m[0].is_a?(Array)
    return(depth(m[0], d+1))
  end
  return(d)
end

def tblidx(mtx, indices)
  m = mtx
  indices.each do |idx|
    m = m[idx]
  end
  return(m)
end

def incidx(indices)
  val = indices.inject(0) {|x,y| x*26 + y}
  val += 1
  idx = []
  indices.length.times { idx.unshift(val % 26); val = val / 26 }
  return(idx)
end

freqtbl = File.open(ARGV[0]) {|fp| eval(fp.read) }
s = freqtbl.flatten.sum.to_i
d = depth(freqtbl, 1)
output = Array.new(d, 0)
ranno = rand()
sum = 0.0
until sum >= ranno
  while (t = tblidx(freqtbl,output)) == 0.0 do
    output = incidx(output)
  end
  sum += t
  if sum < ranno
    output = incidx(output)
  end
end
pwl = ARGV[1].to_i
nchar = d
while nchar < pwl do
  ctx = output[nchar-d+1, d-1]
  ctx.append(0)
  sum = 0
  row = []
  0.upto(25) do |x|
    ctx[-1] = x
    row << tblidx(freqtbl, ctx)
    sum += tblidx(freqtbl, ctx)
  end
  if (sum == 0)
    puts "sum was 0"
    exit(1)
  end
  ranno = rand() * sum
  sum = 0.0
  row.each_index do |i|
    sum += row[i]
    if sum > ranno
      output << i
      break
    end
  end
  nchar += 1
end
puts output.map { |x| x + 97 }.pack("c*")
