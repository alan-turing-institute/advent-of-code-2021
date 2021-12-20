from ast import literal_eval
from itertools import permutations
from typing import List, Iterable, Optional, Union
from collections import UserList


class Number: 
    """A snailfish number is a pair of integers or other nested pairs.
    
    Snailfish numbers are reduced upon initialisation. 
    
    Example:

        This would be a valid iterable to produce a snailfish Number
        [[1, 2], 3] but this would not [[1, 2]]
    """
    def __init__(self, iterable: Optional[list]=None,
                 values: Optional[List[int]]=None,
                 depths: Optional[List[int]]=None) -> None:
        if iterable is not None:
            iterable = self._validate_iterable(iterable)
            self.values, self.depths = self.flatten(iterable)
        elif not (values is None or depths is None):
            self.values, self.depths = self._validate_values(values, depths)
        else:
            raise AttributeError('Pass either iterable or both values and depths')

        self._magnitude = None  # Lazy load the magnitude on first call
        self._constructed = None  # This is set during validation
 
        self._validate()
        self.reduce()  # We can now safely reduce the Number

    @classmethod
    def _validate_iterable(cls, iterable):
        """A Number should be able to be made from each item in iterable."""
        for i in range(2):
            # for each value in the pair, check it can be made into a number
            try:
                pair = iterable[i]
            except IndexError:
                raise ValueError(f'Iterable \'{iterable}\' must be a valid pair.')
            if isinstance(pair, list):
                cls(pair)  # Try to create a Number from nested list
        return iterable

    @staticmethod
    def _validate_values(values, depths):
        if len(values) != len(depths):
            raise ValueError(f'Values \'{values}\' must be same length ' + 
                             f'as depths \'{depths}\'')
        return values, depths

    @staticmethod
    def _is_number(obj):
        if not isinstance(obj, Number):
            raise TypeError(f'Object \'{obj}\' must be an instance of Number')
        return obj

    @staticmethod
    def flatten(iterable, depth=0):
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

    def construct(self):
        """Reconstruct nested pairs from values and depths."""
        if self._constructed is not None:
            return self._constructed
        
        values = self.values.copy()
        depths = self.depths.copy()
        def construct_pair(depth=0):
            pair = [None] * 2
            for i in range(2):
                if depths[0] == depth:
                    pair[i] = values.pop(0)
                    depths.pop(0)
                    continue
                pair[i] = construct_pair(depth + 1)
            return pair
        self._constructed = construct_pair()
        return self._constructed

    def _validate(self):
        if max(self.depths) > 4:
                raise ValueError('Cannot reduce number with a pair at a ' + 
                                 'depth greater than 4')
        try:
            # Try constructing number from values and depths
            self.construct()
        except IndexError:
            raise ValueError('Valid number cannot be constructed from ' + 
                             f'{self.values} and {self.depths}')

    def __repr__(self) -> str:
        return f'Number({self.construct()})'

    def __str__(self) -> str:
        return str(self.construct())

    def __add__(self, other):
        other = self._is_number(other)
        values = self.values + other.values
        depths = self.depths + other.depths
        depths = [d + 1 for d in depths]
        return Number(values=values, depths=depths)

    def __radd__(self, other):
        """To allow for 0 + self."""
        if other == 0:
            return self
        else:
            return self.__add__(other)

    def __eq__(self, other) -> bool:
        other = self._is_number(other)
        return (self.values == other.values) and (self.depths == other.depths)

    def __gt__(self, other) -> bool:
        return self.magnitude() > self._is_number(other).magnitude()
    
    def __lt__(self, other) -> bool:
        return self.magnitude() < self._is_number(other).magnitude()

    def explode(self):
        """Explodes the first pair at a depth of 4 and returns
        the exploded pair, or None"""
        if 4 not in self.depths:
            return None
        i = self.depths.index(4)  # First occurrence of pair at depth 4
        old_pair = [self.values[i], self.values[i+1]]
        if i > 0:
            self.values[i-1] += old_pair[0]
        if i + 2 < len(self.values):
            self.values[i+2] += old_pair[1]
        self.values[i+1] = 0
        self.depths[i+1] = 3
        self.values.pop(i)
        self.depths.pop(i)
        return old_pair

    def split(self):
        """Splits the first value larger than 9 and returns
        the split value, or None."""
        for i, n in enumerate(self.values):
            if n > 9:
                break  # First occurance of number > 9
        if not n > 9:
            return None
        self.values[i] = n//2
        self.depths[i] += 1
        self.values.insert(i+1, n//2 + n%2)
        self.depths.insert(i+1, self.depths[i])
        return n
    
    def reduce(self):
        while True:
            if self.explode() is not None:
                continue
            if self.split() is None:
                break

    def magnitude(self):
        if self._magnitude is not None:
            return self._magnitude

        values = self.values.copy()
        depths = self.depths.copy()
        
        while len(depths) > 1:
            i = depths.index(max(depths))
            values[i+1] = 3 * values[i] + 2 * values[i+1]
            depths[i+1] -= 1
            values.pop(i)
            depths.pop(i)
        self._magnitude = values[0]
        return self._magnitude


class NumbersList(UserList):
    """List of Numbers.
    """
    def __init__(self, initlist: List[Number]) -> None:
        assert all(isinstance(i, Number) for i in initlist)
        super().__init__(initlist)

    @classmethod
    def from_file(cls, file_name: str):
        with open(file_name, 'r') as file:
            inputs = [literal_eval(line) for line in file]
        return cls([Number(i) for i in inputs])

    @staticmethod
    def _validate_item(item: Number) -> Number:
        if not isinstance(item, Number):
            raise TypeError(f'Item \'{item}\' must be an instance of Number')
        return item

    def largest_magnitude(self, r: int=2) -> int:
        """Takes list of numbers and gives largest magnitude
        from the sum of any permutation of size r."""
        magnitude = 0
        for i in permutations(self.data, r):
            magnitude = max(sum(i).magnitude(), magnitude)
        return magnitude
        
    def append(self, item: Number) -> None:
        item = self._validate_item(item)
        return super().append(item)

    def insert(self, i: int, item: Number) -> None:
        item = self._validate_item(item)
        return super().insert(i, item)

    def extend(self, other: Iterable[Number]) -> None:
        if not all(isinstance(item, Number) for item in other):
            raise TypeError(f'Iterable \'{other}\' must only comprise ' + 
                            'instances of Number')
        return super().extend(other)


if __name__ == '__main__':
    numbers = NumbersList.from_file('input.txt')
    result = sum(numbers)
    print('Part 1:', result.magnitude())
    print('Part 2:', numbers.largest_magnitude())
