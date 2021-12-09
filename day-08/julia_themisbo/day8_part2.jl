all_lines = readlines("day8.txt")
all_lines_vec = hcat(split.(all_lines," | ")...)

inputs = all_lines_vec[1,:]
outputs = all_lines_vec[2,:]

keep_track_ints = zeros(Int64, size(all_lines,1))

for jk in 1:size(all_lines,1)
    full_line = inputs[jk] * " " * outputs[jk]
    all_vales = hcat(split.(full_line," ")...)

    d = Matrix(undef, 10, 2)
    d[:,1] = collect(0:9)
    d[1+1,2] = join(sort(split(all_vales[length.(all_vales) .== 2][1],"")))
    d[4+1,2] = join(sort(split(all_vales[length.(all_vales) .== 4][1],"")))
    d[7+1,2] = join(sort(split(all_vales[length.(all_vales) .== 3][1],"")))
    d[8+1,2] = join(sort(split(all_vales[length.(all_vales) .== 7][1],"")))

    # Numbers created with 6 letters
    sixlengths = hcat(split.(all_vales[length.(all_vales) .== 6],"")...)
    new_6 = hcat([sort(sixlengths[:,i]) for i in 1:size(sixlengths,2)]...)

    # 4 is in 9
    fours = sort(split(d[4+1,2],""))

    nines_orig = sixlengths[:,[issubset(Set(fours), Set(new_6[:,ii])) for ii in 1:size(new_6,2)]]
    d[9+1,2] = join(sort(nines_orig[:,1]))

    # 1 is not in 6
    ones = sort(split(d[1+1,2],""))

    sixes_orig = sixlengths[:,[!issubset(Set(ones), Set(new_6[:,ii])) for ii in 1:size(new_6,2)]]
    d[6+1,2] = join(sort(sixes_orig[:,1]))

    # 4 is not in 0 and 1 is in 0
    zeros_orig = sixlengths[:,[!issubset(Set(fours), Set(new_6[:,ii])) && issubset(Set(ones), Set(new_6[:,ii])) for ii in 1:size(new_6,2)]]
    d[0+1,2] = join(sort(zeros_orig[:,1]))

    # Numbers created with 5 letters
    fivelengths = hcat(split.(all_vales[length.(all_vales) .== 5],"")...)
    new_5 = hcat([sort(fivelengths[:,i]) for i in 1:size(fivelengths,2)]...)

    # 1 is in 3
    threes_orig = fivelengths[:,[issubset(Set(ones), Set(new_5[:,ii])) for ii in 1:size(new_5,2)]]
    d[3+1,2] = join(sort(threes_orig[:,1]))

    # complement of 7 and 9 is in 5
    comple_sev_nine = setdiff(Set(split(d[9+1,2],"")), Set(split(d[7+1,2],"")))

    fives_orig = fivelengths[:,[issubset(Set(comple_sev_nine), Set(new_5[:,ii])) for ii in 1:size(new_5,2)]]
    d[5+1,2] = join(sort(fives_orig[:,1]))

    # complement of 6 and 4 is in 2
    comple_six_four = setdiff(Set(split(d[6+1,2],"")), Set(split(d[4+1,2],"")))

    twos_orig = fivelengths[:,[issubset(Set(comple_six_four), Set(new_5[:,ii])) for ii in 1:size(new_5,2)]]
    d[2+1,2] = join(sort(twos_orig[:,1]))

    checks = join.(sort.(split.(split(outputs[jk]," "),"")))

    keep_track_ints[jk] =  parse(Int64, join([findall(x->x==checks[ii], d)[1][1] - 1 for ii in 1:size(checks,1)]))
end

sum(keep_track_ints)