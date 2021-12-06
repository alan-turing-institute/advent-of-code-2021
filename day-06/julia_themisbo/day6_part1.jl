orig_input = readlines("day6.txt")
Init_state = hcat(split.(orig_input,",")...) .|> x -> parse(Int64,x)

for day in 1:80
    newborns = count(Init_state .== 0)
    Init_state[Init_state .== 0] .= 7
    Init_state = vcat(Init_state, fill(9, newborns))
    Init_state .-= 1
end

size(Init_state,1)