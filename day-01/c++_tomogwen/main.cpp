
// Advent of Code
// I am not good at C++!

#include <iostream>
#include <fstream>
#include <vector>


int part_one() {

    std::ifstream fin;
    fin.open("input.txt");

    int current_number, prev_number;
    int count = 0;

    fin >> prev_number;

    while (fin >> current_number) {
        if (current_number > prev_number) {
            count++;
        }
        prev_number = current_number;
    }

    fin.close();
    return count;
}


int part_two() { 

    // read data
    std::ifstream fin;
    fin.open("input.txt");

    std::vector<int> data;
    int num;
    while (fin >> num) { 
        data.push_back(num);
    }
    fin.close();

    // compute and compare totals
    int current_total;
    int count = 0;
    int prev_total = data[0] + data[1] + data[2] + 1;

    for (int i = 0; i < data.size()-2; i++) {

        current_total = 0;
        for(int j = 0; j < 3; j++) {
            current_total += data[i+j];
        }

        if (current_total > prev_total) { 
            count++;
        }
        prev_total = current_total;
    }
    
    return count;
}


int main() {
    std::cout << "Part 1: " << part_one() << std::endl;
    std::cout << "Part 2: " << part_two() << std::endl;
}
