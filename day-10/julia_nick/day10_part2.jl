function process_line(line)
    parenthesis_dict = Dict('{'=>'}',
                            '('=>')',
                            '<'=>'>',
                            '['=>']')
    score_dict = Dict(')'=>1,
                      ']'=>2,
                      '}'=>3,
                      '>'=>4)

    open_brackets = []
    for character in line
        if character in keys(parenthesis_dict)
            push!(open_brackets, character)
        elseif character in values(parenthesis_dict)
            if (length(open_brackets)==0) ||
                (character != parenthesis_dict[open_brackets[length(open_brackets)]])
                return -1 # corrupted
            else
                pop!(open_brackets)
            end
        end
    end
    if length(open_brackets) > 0
        # incomplete line - iterate backwards through the list of open brackets
        score = 0
        for bracket in reverse(open_brackets)
            score *= 5
            score += score_dict[parenthesis_dict[bracket]]
        end
        return score
    end
    return 0
end

function test_process_line()
    @assert process_line("[({(<(())[]>[[{[]{<()<>>") == 288957
    @assert process_line("[(()[<>])]({[<{<<[]>>(") == 5566
    @assert process_line("(((({<>}<{<{<>}{[]{[]{}") == 1480781
    @assert process_line("{<[[]]>}<{[{[{[]{()[[[]") == 995444
    @assert process_line("<{([{{}}[<[[[<>{}]]]>[]]") == 294

end

test_process_line()

function process_file(filename)
    input_lines = readlines(filename)
    line_scores = []
    for line in input_lines
        score = process_line(line)
        if score > 0
            push!(line_scores, score)
        end
    end
    line_scores = sort(line_scores)
    return line_scores[Int(ceil(length(line_scores)/2))]
end

score = process_file("input.txt")
println("score is ",score)
