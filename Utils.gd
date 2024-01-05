extends Node

class_name Utils

static func round_to_dec(num, digit):
    return round(num * pow(10.0, digit)) / pow(10.0, digit)

static func format_num(number: float):
    var _exp = str(number).split(".")[0].length() - 1
    var _dec = number / pow(10,_exp)
    if _exp > 2:
        return "{dec}e{exp}".format({"dec":("%1.2f" % _dec), "exp":str(_exp) })
    elif _exp == 1:
        return "%1.0f" % number
    elif _exp <= 0:
        return str(round_to_dec(number, 2))
    
static func format_currency(amount: float):
    if is_zero_approx(amount):
        amount = 0
    return "%1.0f" % amount

static func geq(f1: float, f2: float):
    return f1 > f2 || is_equal_approx(f1, f2)

static func leq(f1: float, f2: float):
    return f1 < f2 || is_equal_approx(f1, f2)
