use std::fs;

fn median(numbers: &Vec<i32>) -> i32 {

    let mut sort_numbers = numbers.clone();
    sort_numbers.sort();
    let mid = sort_numbers.len() / 2;
    sort_numbers[mid]
}

fn mean(numbers: &Vec<i32>) -> f64 {
    numbers.iter().map(|&x| x as f64).sum::<f64>() / numbers.len() as f64
}

fn diff_abs_sum(input: &Vec<i32>, x: i32) -> i32 {
    input.iter().map(|&y| (y - x).abs()).sum()
}

fn diff_sum_natural(input: &Vec<i32>, x: i32) -> i32 {

    let sum_nat = |n: i32| n * (n+1) /2;
    input.iter().map(|&y| sum_nat((y - x).abs())).sum()
}

fn main() {

    let input: Vec<i32> = fs::read_to_string("input.txt").unwrap().split(",").map(|x| x.parse().unwrap()).collect();
    
    println!("Part 1= {}",  diff_abs_sum(&input, median(&input)));

    let lower_bound = *(input.iter().min().unwrap());
    let upper_bound = *(input.iter().max().unwrap());
    
    let part_2 = (lower_bound..upper_bound + 1).map(|x| diff_sum_natural(&input, x)).min().unwrap();
    println!("Part 2= {}",  part_2);
}


#[cfg(test)]
mod tests {

    use super::*;

    #[test]
    fn test_median() {
        assert_eq!(
            2,
            median(&vec![16,1,2,0,4,2,7,1,2,14])
        );
        assert_eq!(
            4,
            median(&vec![1,2,3,4,5,6])
        );

    }

    #[test]
    fn test_part1(){
        
        let input = vec![16,1,2,0,4,2,7,1,2,14];
        assert_eq!(37 , diff_abs_sum(&input, median(&input)));
    }

    #[test]
    fn test_part2(){
        
        let input = vec![16,1,2,0,4,2,7,1,2,14];
        let lower_bound = *(input.iter().min().unwrap());
        let upper_bound = *(input.iter().max().unwrap());
    
        let part_2 = (lower_bound..upper_bound + 1).map(|x| diff_sum_natural(&input, x)).min().unwrap();
        assert_eq!(168, part_2);

        
        let part_2b = diff_sum_natural(&input, mean(&input).floor() as i32).min(
        diff_sum_natural(&input, mean(&input).ceil() as i32));
        assert_eq!(168, part_2b);
    }
}