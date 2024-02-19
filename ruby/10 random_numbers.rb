def binomial_estimate(n, k, p, accuracy=1000)
    total = 0
    accuracy.times do
        count = 0
        n.times {count += 1 if rand() < p}
        total += 1 if count == k
    end
    return total.to_f / accuracy
end

def factorial(n)
    return 1 if n < 1
    n * factorial(n-1)
end

def choose(n, k)
    factorial(n) / (factorial(k) * factorial(n-k))
end

def binomial(n, k, p)
    choose(n,k) * (p ** k) * ((1-p) ** (n-k))
end

def test_binomial(n, k, p)
    print "Estimate of binomial distribution n=#{n}, k=#{k}, p=#{p} is #{binomial_estimate(n, k, p)}. "
    puts "Actual value is #{binomial(n, k, p)}"
end

test_binomial 10, 3, 0.5