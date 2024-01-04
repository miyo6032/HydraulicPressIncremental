extends Node

class_name Utils

static func format_num(n: float):
    return str(n)
    
static func format_currency(amount: float):
    if is_zero_approx(amount):
        amount = 0
    return "%1.0f" % amount

static func geq(f1: float, f2: float):
    return f1 > f2 || is_equal_approx(f1, f2)

static func leq(f1: float, f2: float):
    return f1 < f2 || is_equal_approx(f1, f2)
