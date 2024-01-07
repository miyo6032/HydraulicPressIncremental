extends Node

class_name Utils

static func round_to_dec(num, digit):
    return round(num * pow(10.0, digit)) / pow(10.0, digit)

static func format_whole(number):
    return "%.0f" % number

static func format_num(number: float):
    var _exp = str(number).split(".")[0].length() - 1
    var _dec = number / pow(10,_exp)
    if _exp > 3:
        return "{dec}e{exp}".format({"dec":("%1.2f" % _dec), "exp":str(_exp) })
    elif _exp >= 2:
        return "%.0f" % round_to_dec(number, 0)
    else:
        return "%1.2f" % round_to_dec(number, 2)

static func format_currency(number: float):
    var _exp = str(number).split(".")[0].length() - 1
    var _dec = number / pow(10,_exp)
    if _exp > 3:
        return "{dec}e{exp}".format({"dec":("%1.2f" % _dec), "exp":str(_exp) })
    else:
        return "%1.2f" % round_to_dec(number, 2)

static func geq(f1: float, f2: float):
    return f1 > f2 || is_equal_approx(f1, f2)

static func leq(f1: float, f2: float):
    return f1 < f2 || is_equal_approx(f1, f2)
