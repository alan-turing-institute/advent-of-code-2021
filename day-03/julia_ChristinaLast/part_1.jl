diagnostic_report = (split.(readlines("input.txt"),""))

ones_count = zeros(length(diagnostic_report[1]))
zero_count = zeros(length(diagnostic_report[1]))
numeric = 0

function binary_to_decimal(binary_string, numeric)
  for i in 1:length(binary_string)
    if binary_string[i] == '1'
      numeric += 2^(length(binary_string)-i)
    end
  end
  return numeric
end

function extract_report_count(diagnostic_report)
  for report in diagnostic_report
    num_digits = 1:length(report)
    for i in num_digits
      if report[i] == "1"
        ones_count[i] += 1
      else
        zero_count[i] += 1
      end
    end
    vcat(1, ones_count, ones_count)
    vcat(1, zero_count, zero_count)
  end
  return ones_count, zero_count
end
ones_count, zero_count = extract_report_count(diagnostic_report)

function extract_gamma_epsilon(ones_count, zero_count)
  epsilon_binary = ""
  gamma_binary = ""
  for i in 1:length(diagnostic_report[1])
    if ones_count[i] > zero_count[i]
      gamma_binary *= "1"
      epsilon_binary *= "0"
    else
      epsilon_binary *= "1"
      gamma_binary *= "0"
    end
  end
  return epsilon_binary, gamma_binary
end
epsilon_binary, gamma_binary = extract_gamma_epsilon(ones_count, zero_count)

print("The final rate is: ",binary_to_decimal(epsilon_binary, numeric)*binary_to_decimal(gamma_binary, numeric))
