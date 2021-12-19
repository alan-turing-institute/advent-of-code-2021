from ast import literal_eval
from itertools import permutations
from typing import List
from collections import UserList


class Number: 
    """Sorry not much docs yet, this one took a while!"""
    def __init__(self, values: List[int], depths: List[int]) -> None:
        assert len(values) == len(depths)
        self.values = values
        self.depths = depths
        self.reduce()

    @classmethod
    def from_iterable(cls, iterable):
        return cls(*cls.flatten(iterable, 0))

    @staticmethod
    def flatten(iterable, depth):
        values, depths = [], []
        for i in iterable:
            if isinstance(i, list):
                f, l = Number.flatten(i, depth + 1)
                values.extend(f)
                depths.extend(l)
            else:
                values.append(i)
                depths.append(depth)
        return values, depths

    def explode(self):
        if 4 not in self.depths:
            return False
        i = self.depths.index(4)  # First occurrence of pair at depth 4
        if i > 0:
            self.values[i-1] += self.values[i]
        if i + 2 < len(self.values):
            self.values[i+2] += self.values[i+1]
        self.values[i+1] = 0
        self.depths[i+1] = 3
        self.depths.pop(i)
        self.values.pop(i)
        return True

    def split(self):
        for i, n in enumerate(self.values):
            if n > 9:
                break  # First occurance of number > 9
        if not n > 9:
            return False
        self.values[i] = n//2
        self.depths[i] += 1
        self.values.insert(i+1, n//2 + n%2)
        self.depths.insert(i+1, self.depths[i])
        return True
    
    def reduce(self):
        while True:
            if self.explode():
                continue
            if not self.split():
                break

    def magnitude(self):
        values = self.values.copy()
        depths = self.depths.copy()
        
        while len(depths) > 1:
            i = depths.index(max(depths))
            values[i+1] = 3 * values[i] + 2 * values[i+1]
            depths[i+1] -= 1
            values.pop(i)
            depths.pop(i)
        return values[0]

    def __add__(self, other):
        if not isinstance(other, Number):
            raise TypeError('Object must be an instance of Number')
        values = self.values + other.values
        depths = self.depths + other.depths
        depths = [d + 1 for d in depths]
        return Number(values, depths)

    def __radd__(self, other):
        """To allow for 0 + self."""
        if other == 0:
            return self
        else:
            return self.__add__(other)


class NumbersList(UserList):
    """List of Numbers.
    
    Could add some stuff to make sure inserted elements are correct
    type.
    """
    def __init__(self, initlist: List[Number]) -> None:
        assert all(isinstance(i, Number) for i in initlist)
        super().__init__(initlist)

    @classmethod
    def from_file(cls, file_name: str):
        with open(file_name, 'r') as file:
            inputs = [literal_eval(line) for line in file]
        return cls([Number.from_iterable(i) for i in inputs])

    def largest_magnitude(self, r: int=2) -> int:
        """Takes list of numbers and gives largest magnitude
        from the sum of any permutation of size r."""
        magnitude = 0
        for i in permutations(self.data, r):
            magnitude = max(sum(i).magnitude(), magnitude)
        return magnitude


if __name__ == '__main__':
    numbers = NumbersList.from_file('input.txt')
    result = sum(numbers)
    print('Part 1:', result.magnitude())
    print('Part 2:', numbers.largest_magnitude())
