import math
from pprint import pprint
n = 10
mesh = [0]*n**2

def from_degree_to_score(d):
    if d == -1:
        return 0
    step = 18
    score = [20, 1, 18, 4, 13, 6, 10, 15, 2, 17, 3, 19, 7, 16, 8, 11, 14, 9, 12, 5, 20]
    d = (d+270+9)%360
    idx = int(d/step)
    return score[idx]
# -->x
# |
# v
# y
central_point = (n/2-0.5, n/2-0.5)
normal_vector = (0, -1)
for x in range(n):
    for y in range(n):
        now_vector = (x-central_point[0], y-central_point[0])
        ll = math.sqrt(now_vector[0]**2 + now_vector[1]**2)
        inner_product = now_vector[0]*normal_vector[0] + now_vector[1]*normal_vector[1]
        cos = inner_product/ll
        if ll**2 > central_point[0]**2:
            mesh[x*n+y] = -1
        else:
            if x >= n//2:
                mesh[x*n+y] = 360-round(math.acos(cos) / (math.pi) * 180, 2)
            else:
                mesh[x*n+y] = round(math.acos(cos) / (math.pi) * 180, 2)
mesh = [from_degree_to_score(p) for p in mesh]
print("graph:")
for start in range(0, n**2, 10):
    print(mesh[start:start+10])
print()
print("for copy:")
print(mesh)