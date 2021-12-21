from ast import literal_eval
from itertools import permutations
from typing import Tuple, List, Iterable, Optional, Any
from collections import UserList, deque


class Number: 
    """A snailfish number is a pair of integers or other nested pairs up to a
    maximum depth of 4 (i.e. a pair nested in 4 other pairs). Numbers are 
    automatically reduced upon initialisation such that the max depth is 3
    and the maximum value of any integer in the number is 9.
    
    Args:
        pair (list, optional): Pair of integers or other nested pairs up to a
            depth of 4.
        values (list of int, optional): Flattened list representing values in
            the pair. Can be passed instead of pair.
        depths (list of int, optional): List of depths corresponding to the 
            depth of nested pairs, up to a max depth of 4. Required if passing
            values.
    
    Example:
        The pair [[1, 2], 3] is valid for producing a number, but [[1, 2]] is
        not.
    
    Notes:
        I enjoyed this AoC challenge as an exercise in building classes
        and thinking about data validation and exception catching.
        Could be improved by combining values and depths into their
        own object, or at least give them leading underscores as editing them
        can break things. Also, this starts to run slowly, ~ 1 second, for the
        part 2, so there may be room for improvement.
    """
    def __init__(self, pair: Optional[list]=None,
                 values: Optional[List[int]]=None,
                 depths: Optional[List[int]]=None) -> None:
        if pair is not None:
            pair = self._validate_pair(pair)
            self.values, self.depths = self.flatten(pair)
        elif not (values is None or depths is None):
            self.values, self.depths = self._validate_values(values, depths)
        else:
            raise AttributeError('Pass either pair or both values and depths')

        self._validate()
        self.reduce()  # We can now safely reduce the Number

    @classmethod
    def _validate_pair(cls, pair):
        """A Number should be able to be made from each item in pair."""
        if len(pair) != 2:
            raise ValueError(f'Pair \'{pair}\' must have length of 2.')
        for p in pair:
            # For each value in the pair, check it contains pairs
            if isinstance(p, list):
                cls._validate_pair(p)
            elif not isinstance(p, int):
                raise TypeError(f'Pair must contain integers or other pairs.')
        return pair

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
    def flatten(pair: list, depth=0) -> Tuple[List[int], List[int]]:
        """Flatten pairs starting at some depth."""
        values, depths = [], []
        for i in pair:
            if isinstance(i, list):
                f, l = Number.flatten(i, depth=depth + 1)
                values.extend(f)
                depths.extend(l)
            else:
                values.append(i)
                depths.append(depth)
        return values, depths

    def construct(self):
        """Reconstruct nested pairs from values and depths."""
        queue = deque(zip(self.values, self.depths))
        
        def construct_pair(depth=0):
            pair = [None] * 2
            for i in range(2):
                if not queue:
                    raise ValueError('Pair cannot be constructed from ' + 
                                     f'{self.values} and {self.depths}')
                if queue[0][1] == depth:
                    pair[i], _ = queue.popleft()
                    continue
                pair[i] = construct_pair(depth + 1)
            return pair
        return construct_pair()

    def _validate(self):
        if max(self.depths) > 4:
            raise ValueError('Cannot reduce number with a pair at a ' + 
                             'depth greater than 4')
        # TODO: quick way to test valid pair can be constructed
        
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
        """To allow for 0 + self, e.g. in sum()."""
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
        the exploded pair, or None."""
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
        """Reduce the number by exploding and splitting until neither
        can be applied."""
        while True:
            if self.explode() is not None:
                continue
            if self.split() is None:
                break

    def magnitude(self):
        """Calculate the magnitude of the number."""
        values = self.values.copy()
        depths = self.depths.copy()
        
        while len(depths) > 1:
            i = depths.index(max(depths))
            values[i+1] = 3 * values[i] + 2 * values[i+1]
            depths[i+1] -= 1
            values.pop(i)
            depths.pop(i)
        return values[0]


class NumberList(UserList):
    """List of Numbers.
    
    Args:
        initlist (list of number): List of numbers.
    """
    def __init__(self, initlist: List[Number]) -> None:
        initlist = self._validate_iterable(initlist)
        super().__init__(initlist)

    @classmethod
    def from_file(cls, file_name: str):
        """Load numbers list from file."""
        with open(file_name, 'r') as file:
            inputs = [literal_eval(line) for line in file]
        return cls([Number(i) for i in inputs])

    @staticmethod
    def _validate_item(item: Number) -> Number:
        if not isinstance(item, Number):
            raise TypeError(f'Item \'{item}\' must be an instance of Number')
        return item
    
    @staticmethod
    def _validate_iterable(iterable: Iterable[Number]) -> Iterable[Number]:
        if not all(isinstance(item, Number) for item in iterable):
            raise TypeError(f'Iterable \'{iterable}\' must only comprise ' + 
                            'instances of Number')
        return iterable

    def __setitem__(self, index, value):
        """Magic for setting items in data."""
        if isinstance(index, slice):
            value = self._validate_iterable(value)
            self.data[index] = value
        else:
            value = self._validate_item(value)
            self.data[index] = value

    def append(self, item: Number) -> None:
        item = self._validate_item(item)
        return super().append(item)

    def insert(self, i: int, item: Number) -> None:
        item = self._validate_item(item)
        return super().insert(i, item)

    def extend(self, other: Iterable[Number]) -> None:
        other = self._validate_iterable(other)
        return super().extend(other)

    def largest_magnitude(self, r: int=2) -> int:
        """Takes list of numbers and gives largest magnitude
        from the sum of any permutation of size r."""
        magnitude = 0
        for i in permutations(self.data, r):
            magnitude = max(sum(i).magnitude(), magnitude)
        return magnitude


if __name__ == '__main__':
    numbers = NumberList.from_file('input.txt')
    result = sum(numbers)
    print('Part 1:', result.magnitude())
    print('Part 2:', numbers.largest_magnitude())
