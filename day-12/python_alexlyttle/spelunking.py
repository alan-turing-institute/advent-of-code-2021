"""Uses networkx as a handy way to make and store the cave graph
"""
import networkx as nx

def load_input(file_name):
    with open(file_name, 'r') as file:
        s = file.read()
    return s

def graph_from_str(s):
    graph = nx.Graph()
    for line in s.splitlines():
        graph.add_edge(*line.split('-'))
    return graph

      
def path_generator(graph, max_visits=1):
    """Adapted from 
    https://networkx.org/documentation/stable/_modules/networkx/algorithms/\
    simple_paths.html#all_simple_paths
    
    Can be improved but trying to catch up on the puzzles from a few days
    behind!
    """
    original_max_visits = max_visits
    targets = {'end'}
    visited = ['start']
    stack = [iter(graph['start'])]
    is_twice = False
    
    while stack:
        children = stack[-1]
        child = next(children, None)
        if child is None:
            stack.pop()
            discarded = visited.pop() 
            if discarded in visited and discarded.islower():
                max_visits = original_max_visits
        else:
            if child == 'start' or \
                (child.islower() and visited.count(child) > max_visits - 1):
                continue
            if child in targets:
                yield visited + [child]

            visited.append(child)
            if visited.count(child) == original_max_visits and child.islower():
                max_visits = 1

            if targets - set(visited):  # expand stack until find all targets
                stack.append(iter(graph[child]))
            else:
                discarded = visited.pop()
                if discarded in visited and discarded.islower():
                    max_visits = original_max_visits

def count_paths(graph, max_visits=1):
    paths = list(path_generator(graph, max_visits=max_visits))
    return len(paths)

if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(
        description='Count paths in cave system'
    )
    parser.add_argument('input_file', metavar='INPUT_FILE', type=str, 
                        help='input file name')
    parser.add_argument('-m', '--max-visits', type=int, default=1)


    args = parser.parse_args()
    s = load_input(args.input_file)
    graph = graph_from_str(s)
    count = count_paths(graph, max_visits=args.max_visits)
    print(f'Number of paths = {count}')
