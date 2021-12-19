import numpy as np

def load_input(file_name):
    with open(file_name, 'r') as file:
        s = file.read()
    return s

def target_from_str(s):
    """Gets bottom-left and top-right corners of target."""
    target = [i.split('=')[1] for i in s.split(', ')]
    target = [i.split('..') for i in target]
    target = [[int(i), int(j)] for i, j in zip(*target)]
    return np.array(target)

@np.vectorize
def maximum_displacement(initial_velocity):
    """Derived from s = 0.5 u + u t + 0.5 a t^2 at t = u and a = -1.
    The (0.5 u) term comes from the order of rules of the motion of the 
    probe, the displacement changes before the velocities are
    updated."""
    return int(0.5 * initial_velocity * (1 + initial_velocity))

def get_x_velocities(target):
    """Get all valid initial x velocities which could hit target."""
    x_velocities = np.arange(0, target[1, 0] + 1)
    x_max = maximum_displacement(x_velocities)
    return x_velocities[x_max >= target[0, 0]]

def find_target(x_vel, y_vel, target):
    """Returns true if target is found, returns false if missed target"""
    x_pos, y_pos = (0, 0)
    while True:
        # Advance projectile by one step
        # This shouldn't go on forever unless something horrible happens!
        x_pos += x_vel
        y_pos += y_vel
        x_vel -= np.sign(x_vel)
        y_vel -= 1
        if x_pos > target[1, 0] or y_pos < target[0, 1]:
            return False
        elif x_pos >= target[0, 0] and y_pos <= target[1, 1]:
            return True

def find_maximum_height(target, x_velocities):
    """Find maximum height of projectile which hits target for range of 
    initial x velocities"""
    y_vel = - (target[0, 1] + 1) # All velocities greater than this will always miss 
    while True:
        for x_vel in x_velocities:
            if hits_target:=find_target(x_vel, y_vel, target):
                break
        if hits_target:
            return maximum_displacement(y_vel), (x_vel, y_vel)
        y_vel -= 1  # Decrease y velocity by 1

def get_y_velocities(target, max_y_velocity):
    """Get range of y velocities for which it is possible to hit the target,
    given max_y_velocity."""
    return np.arange(target[0, 1], max_y_velocity+1)

def find_all_valid_velocities(target, x_velocities, y_velocities):
    """Find valid initial velocities in x velocities and y velocities"""
    valid_velocities = []
        
    for x_vel in x_velocities:
        for y_vel in y_velocities:
            if find_target(x_vel, y_vel, target):
                valid_velocities.append([x_vel, y_vel])
    
    return np.array(valid_velocities)

if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(
        description='Determine trick shot initial velocity and max height'
    )
    parser.add_argument('input_file', metavar='INPUT_FILE', type=str, 
                        help='input file name')
    parser.add_argument('-a', '--all', action='store_true',
                        help='find all possible initial velocities')
    parser.add_argument('-p', '--plot', action='store_true',
                        help='plot initial velocities')

    args = parser.parse_args()
    target = target_from_str(load_input(args.input_file))
    x_velocities = get_x_velocities(target)
    y_max, max_init_vel = find_maximum_height(target, x_velocities)
    print('Max height =', y_max)
    print('Max initial velocity =', max_init_vel)

    if args.all:
        y_velocities = get_y_velocities(target, max_init_vel[1])
        valid_vel = find_all_valid_velocities(target, x_velocities, y_velocities)
        print('Number of valid initial velocities =', valid_vel.shape[0])
        if args.plot:
            import matplotlib.pyplot as plt
            plt.scatter(*valid_vel.T)
            plt.xlabel('x velocity')
            plt.ylabel('y velocity')
            plt.title('Initial Velocities')
            plt.show()
