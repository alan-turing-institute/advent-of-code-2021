import numpy as np

class Heightmap:
    def __init__(self, xy):
        self.xy = xy
        self.height = xy.ravel()
        self.adjacency = self.find_adjacency()
        self.is_low = self.find_lowest()

    @classmethod
    def from_string(cls, s):
        lines = s.splitlines()
        xy = np.array(list(map(list, lines))).astype(int)
        return cls(xy)
    
    @classmethod
    def from_txt(cls, file_name):
        with open(file_name, 'r') as file:
            s = file.read()
        return cls.from_string(s)

    def find_adjacency(self):
        """Find adjacency between heights."""
        shape = self.xy.shape
        adjacency = []
        size = shape[0]*shape[1]
        for i in range(size):
            x, y = divmod(i, shape[1])
            adj = []
            if x > 0:
                # If row is not first, add above element index
                adj.append((i - shape[1]))
            if x < shape[0] - 1:
                # If row is not last, add below element index
                adj.append((i + shape[1]))
            if y > 0:
                # If column is not first, add left element index
                adj.append((i - 1))
            if y < shape[1] - 1:
                # If column is not last, add right element index
                adj.append((i + 1))
            adjacency.append(adj)
        return adjacency

    def find_lowest(self):
        is_low = np.full(self.height.shape, False)
        for i, adj in enumerate(self.adjacency):
            is_low[i] = (self.height[i] < self.height[adj]).all()
        return is_low

    def get_risk(self):
        return (self.height[self.is_low] + 1).sum()

    def _iterate_basin(self, i, size, idx_used):
        """A horrible way of iterating through the basin."""
        while len(self._a[i]) > 0:
            j = self._a[i].pop()
            if self.height[j] < 9 and j not in idx_used:
                idx_used.append(j)
                size, idx_used = self._iterate_basin(j, size+1, idx_used)
        return size, idx_used
    
    def fill_basins(self):
        """Find the sizes of each basin. Slow but works."""
        idx_low, = np.where(self.is_low)
        size = np.zeros_like(idx_low)
        self._a = self.find_adjacency()
        idx_used = []
        for k, i in enumerate(idx_low):
            idx_used.append(i)
            size[k], idx_used = self._iterate_basin(i, 1, idx_used)
        return np.sort(size)

    
if __name__ == '__main__':
    # Command Line Interface (CLI)
    import argparse

    parser = argparse.ArgumentParser(
        description='Find low points in smoke basin'
    )
    parser.add_argument('input_file', metavar='INPUT_FILE', type=str, 
                        help='input file name')

    args = parser.parse_args()
    hmap = Heightmap.from_txt(args.input_file)
    risk = hmap.get_risk()
    print(f'Risk = {risk}')
    size = hmap.fill_basins()
    print(f'Product of top 3 sizes = {size[-3:].prod()}')
