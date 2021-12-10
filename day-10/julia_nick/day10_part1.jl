


function is_line_corrupted(line)
    parenthesis_dict = Dict('{'=>'}',
                            '('=>')',
                            '<'=>'>',
                            '['=>']')
    open_brackets = []
    for character in line
        if character in keys(parenthesis_dict)
            push!(open_brackets, character)
        elseif character in values(parenthesis_dict)
            if (length(open_brackets)==0) ||
                (character != parenthesis_dict[open_brackets[length(open_brackets)]])
                return true, character # corrupted
            else
                pop!(open_brackets)
            end
        end
    end
    return false, nothing
end

function test_is_line_corrupted()
    @assert is_line_corrupted("([])")[1] == false
    @assert is_line_corrupted("{()()()}")[1] == false
    @assert is_line_corrupted("<([{}])>")[1] == false
    @assert is_line_corrupted("[<>({}){}[([])<>]]")[1] == false
    @assert is_line_corrupted("(((((((((())))))))))")[1] == false
    @assert is_line_corrupted("{()(}()}")[1] == true
    @assert is_line_corrupted("((()))}")[1] == true
    @assert is_line_corrupted("<([]){()}[{}])")[1] == true

end

test_is_line_corrupted()

function process_file(filename)
    score_dict = Dict(')'=>3,
                      ']'=>57,
                      '}'=>1197,
                      '>'=>25137)
    input_lines = readlines(filename)
    total_score = 0
    for line in input_lines
        corrupted, illegal_char = is_line_corrupted(line)
        if corrupted
            total_score += score_dict[illegal_char]
        end
    end
    return total_score
end

test_score = process_file("test_input.txt")
@assert test_score == 26397

score = process_file("input.txt")
println("score is ",score)
