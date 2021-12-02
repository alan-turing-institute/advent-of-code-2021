txt = (readlines("day2.txt") .|> split)
hor = 0
aim = 0
depth = 0

for i in 1:size(txt, 1)
    X = (txt[i][2] |> x -> parse(Int64,x))
    if txt[i][1] == "forward"
        hor += X
        depth += aim*X
    else aim -= (txt[i][1] == "down" ? -X : X)
    end
end


print(hor*depth)