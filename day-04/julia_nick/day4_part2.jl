using DelimitedFiles

function read_numbers(input_filename)
    number_string = readlines(input_filename)[1]
    number_strings = split(number_string, ",")
    numbers = map(x->parse(Int64, x), number_strings)
    return numbers
end

function read_bingo_cards(input_filename)
    bigmatrix = readdlm(input_filename, Int, skipstart=1)
    cards = []
    # Assume cards are square
    card_size = size(bigmatrix)[2]
    for i in 1:Int64((size(bigmatrix)[1]/card_size))
        push!(cards, bigmatrix[(i-1)*card_size+1:i*card_size, :])
    end
    return cards
end

function check_row_or_column(row_or_column, nums)
    return sum(in(nums).(row_or_column)) == length(row_or_column)
end

function check_card_win(card, nums)
    card_size = size(card)[1]
    for i in 1:card_size
        if (check_row_or_column(card[i,:],nums) ||
            check_row_or_column(card[:,i],nums))
            return true
        end
    end
    return false
end

function test_card_win()
    card = [1 2 3
            4 5 6
            7 8 9]
    @assert check_card_win(card, [1,2]) == false
    @assert check_card_win(card, [1,2,3]) == true
    @assert check_card_win(card, [1,4,7]) == true
    @assert check_card_win(card, [9,5,8,1,6,4]) == true
end

function get_card_score(card, nums)
    last_number_called = nums[length(nums)]
    # flatten the card
    card_flat = vec(card)
    # get a bit vector of numbers that are not called
    matches = (!).(in(nums).(card_flat))
    # multiply by the numbers in the card
    total = sum(matches .* card_flat)
    return total*last_number_called
end

function test_card_score()
    card = [1 2 3
            4 5 6
            7 8 9]
    # should be (1+2+3+4)*9 = 90
    @assert get_card_score(card, [5,6,7,8,9]) == 90
    # should be (2+7)*4 = 36
    @assert get_card_score(card, [9,8,1,3,6,23,5,4]) == 36
end

test_card_win()
test_card_score()

function find_last_winning_score(cards, numbers)
    for i in card_size:length(numbers)
        local nums_so_far = numbers[1:i]
        non_winning_cards = []
        for card in cards
            if check_card_win(card, nums_so_far)
                if length(cards) == 1
                    score = get_card_score(cards[1], nums_so_far)
                    println("Score of last winning card ",score)
                    return score
                end
            else
                push!(non_winning_cards, card)
            end
        end
        println("how many non-winners? ", length(non_winning_cards))
        global cards = non_winning_cards
    end
end


numbers = read_numbers("input.txt")
cards = read_bingo_cards("input.txt")
find_last_winning_score(cards, numbers)
