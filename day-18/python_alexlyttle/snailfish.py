from ast import literal_eval
from itertools import combinations

def largest_magnitude(numbers):
    """Takes list of numbers and gives largest magnitude
    from the sum of any two."""
    magnitude = 0
    for i, j in combinations(numbers, 2):
        for n in [i + j, j + i]:
            magnitude = max(n.magnitude(), magnitude)
    return magnitude


class Number: 
    """Sorry not much docs yet, this one took a while!"""
    @classmethod
    def from_file(cls, file_name):
        with open(file_name, 'r') as file:
            inputs = [literal_eval(line) for line in file]
        return [cls.from_iterable(i) for i in inputs]  
     
    @classmethod
    def from_iterable(cls, iterable):
        number = Number()
        number.values, number.depths = number.flatten(iterable, 0)
        return number

    def flatten(self, iterable, depth):
        values, depths = [], []
        for i in iterable:
            if isinstance(i, list):
                f, l = self.flatten(i, depth + 1)
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
        is_greater = [i > 9 for i in self.values]
        if not any(is_greater):
            return False
        i = is_greater.index(True)  # First time this is true
        n = self.values[i]
        self.values[i] = n//2
        self.values.insert(i+1, n//2 + n%2)
        self.depths[i] += 1
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
        number = Number()
        number.values = self.values + other.values
        number.depths = self.depths + other.depths
        number.depths = [d + 1 for d in number.depths]
        number.reduce()
        return number

    def __radd__(self, other):
        """To allow for 0 + self."""
        if other == 0:
            return self
        else:
            return self.__add__(other)


if __name__ == '__main__':
    numbers = Number.from_file('input.txt')
    result = sum(numbers)
    print('Part 1:', result.magnitude())
    print('Part 2:', largest_magnitude(numbers))
