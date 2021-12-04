// Advent of Code - Day 2
// I am not good at C++!

#include <iostream>
#include <fstream>
#include <vector>
#include <string>


int part_one () {
    std::ifstream fin;
    fin.open("input.txt");

    std::string direction;
    int distance;

    int depth = 0;
    int horiz = 0;

    while (fin >> direction >> distance) {

        if (direction == "forward") {
            horiz += distance;
            // std::cout << "Added " << distance << " to horizontal, now " << horiz << std::endl;
        }

        else if (direction == "down") {
            depth += distance;
            // std::cout << "Added " << distance << " to depth, now " << depth << std::endl;
        }

        else if (direction == "up") {
            depth -= distance;
            // std::cout << "Subtracted " << distance << " from depth, now " << depth << std::endl;
        }

        else {
            std::cout << "Direction invalid" << std::endl;
        }
    }

    fin.close();
    return depth*horiz;
}


int part_two () {
    std::ifstream fin;
    fin.open("input.txt");

    std::string direction;
    int distance;

    int depth = 0;
    int horiz = 0;
    int aim   = 0;

    while (fin >> direction >> distance) {

        if (direction == "forward") {
            horiz += distance;
            depth += aim*distance;
            // std::cout << "Added " << distance << " to horizontal, now " << horiz << std::endl;
            // std::cout << "Added " << aim*distance << " to depth, now " << depth << std::endl;
        }

        else if (direction == "down") {
            aim += distance;
            // std::cout << "Added " << distance << " to aim, now " << aim << std::endl;
        }

        else if (direction == "up") {
            aim -= distance;
            // std::cout << "Subtracted " << distance << " from aim, now " << aim << std::endl;
        }

        else {
            std::cout << "Direction invalid" << std::endl;
        }
    }

    fin.close();
    return depth*horiz;
}


int main () { 
    std::cout << "Part one: " << part_one() << std::endl;
    std::cout << "Part two: " << part_two() << std::endl;
}