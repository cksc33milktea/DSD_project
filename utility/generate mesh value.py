import math
n = 31
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

# BULL: 2/20 -> 10%
# T: 10~12 / 20 -> 50~60%
# D: 17.5~20 / 20 -> 87.5%
central_point = (n/2-0.5, n/2-0.5)
normal_vector = (0, -1)
for x in range(n):
    for y in range(n):
        now_vector = (x-central_point[0], y-central_point[0])
        ll = math.sqrt(now_vector[0]**2 + now_vector[1]**2)
        inner_product = now_vector[0]*normal_vector[0] + now_vector[1]*normal_vector[1]
        try:
            cos = inner_product/ll
        except ZeroDivisionError:
            mesh[x*n+y] = 50
            continue
        if ll**2 > central_point[0]**2:
            mesh[x*n+y] = 0
        elif ll**2 >= central_point[0]**2 * 0.875:
            if x >= n//2:
                mesh[x*n+y] = 2 * from_degree_to_score(360-round(math.acos(cos) / (math.pi) * 180, 2))
            else:
                mesh[x*n+y] = 2 * from_degree_to_score(round(math.acos(cos) / (math.pi) * 180, 2))
        elif ll**2 < central_point[0]**2 *0.65 and ll**2 > central_point[0]**2 *0.55:
            if x >= n//2:
                mesh[x*n+y] = 3 * from_degree_to_score(360-round(math.acos(cos) / (math.pi) * 180, 2))
            else:
                mesh[x*n+y] = 3 * from_degree_to_score(round(math.acos(cos) / (math.pi) * 180, 2))
        elif ll**2 < central_point[0]**2 *0.03:
            mesh[x*n+y] = 50
        else:
            if x >= n//2:
                mesh[x*n+y] = from_degree_to_score(360-round(math.acos(cos) / (math.pi) * 180, 2))
            else:
                mesh[x*n+y] = from_degree_to_score(round(math.acos(cos) / (math.pi) * 180, 2))
print(f"n = {n}:")
print("{", end=None)
for x in range(n):
    for y in range(n):
        print(f"9'd{mesh[x*n+y]}", end=","+" "*(3-len(str(mesh[x*n+y]))))
    print()
print("}", end=None)